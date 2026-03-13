/// API Service - HTTP client for Django backend

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  // Mutex: prevent concurrent token refreshes
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshQueue = [];

  // Notify AuthProvider when session expires
  void Function()? onSessionExpired;

  // ── Headers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  // ── Token persistence ─────────────────────────────────────────────────────

  Future<void> initTokens() async {
    _accessToken = await _storage.read(key: _keyAccess);
    _refreshToken = await _storage.read(key: _keyRefresh);
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: _keyAccess, value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  bool get isAuthenticated => _accessToken != null;

  // ── Token refresh (mutex-protected) ──────────────────────────────────────

  Future<bool> refreshAccessToken() async {
    // Queue concurrent callers instead of spawning multiple refresh requests
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    if (_refreshToken == null) {
      _expireSession();
      return false;
    }

    _isRefreshing = true;
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ROTATE_REFRESH_TOKENS=True => server sends a new refresh token
        await _saveTokens(
          data['access'],
          data['refresh'] ?? _refreshToken!,
        );
        _resolveQueue(true);
        return true;
      } else {
        await clearTokens();
        _expireSession();
        _resolveQueue(false);
        return false;
      }
    } catch (_) {
      _resolveQueue(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _resolveQueue(bool result) {
    for (final c in _refreshQueue) {
      c.complete(result);
    }
    _refreshQueue.clear();
  }

  void _expireSession() => onSessionExpired?.call();

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      return {'success': true};
    }
    final error = jsonDecode(response.body);
    return {'success': false, 'error': error['detail'] ?? 'Login failed'};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) return {'success': true};
    final error = jsonDecode(response.body);
    return {'success': false, 'error': error.toString()};
  }

  /// Blacklists the refresh token on the server, then wipes local storage.
  Future<void> serverLogout() async {
    if (_refreshToken != null) {
      try {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
          headers: _headers,
          body: jsonEncode({'refresh': _refreshToken}),
        );
      } catch (_) {
        // Best-effort — always clear locally regardless
      }
    }
    await clearTokens();
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Future<dynamic> get(String endpoint) async {
    var response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 401) {
      if (!await refreshAccessToken()) throw Exception('Session expired');
      response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
    }

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('GET failed: \${response.statusCode}');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    var response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      if (!await refreshAccessToken()) throw Exception('Session expired');
      response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
    }
    throw Exception('POST failed: \${response.body}');
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    var response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      if (!await refreshAccessToken()) throw Exception('Session expired');
      response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('PUT failed: \${response.body}');
  }

  Future<bool> delete(String endpoint) async {
    var response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 401) {
      if (!await refreshAccessToken()) throw Exception('Session expired');
      response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
    }

    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<dynamic> multipart(
    String method,
    String endpoint,
    Map<String, String> fields, {
    Map<String, String>? files,
    Map<String, dynamic>? xFiles,
  }) async {
    var response = await _sendMultipart(method, endpoint, fields,
        files: files, xFiles: xFiles);

    if (response.statusCode == 401) {
      if (!await refreshAccessToken()) throw Exception('Session expired');
      response = await _sendMultipart(method, endpoint, fields,
          files: files, xFiles: xFiles);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('Multipart failed: \${response.statusCode} - \${response.body}');
  }

  Future<http.Response> _sendMultipart(
    String method,
    String endpoint,
    Map<String, String> fields, {
    Map<String, String>? files,
    Map<String, dynamic>? xFiles,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest(method, uri)
      ..headers['Authorization'] = 'Bearer $_accessToken';

    fields.forEach((k, v) => request.fields[k] = v);

    if (files != null) {
      for (final e in files.entries) {
        if (e.value.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(e.key, e.value));
        }
      }
    }

    if (xFiles != null) {
      for (final e in xFiles.entries) {
        if (e.value != null) {
          final bytes = await e.value.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(e.key, bytes, filename: e.value.name),
          );
        }
      }
    }

    return http.Response.fromStream(await request.send());
  }
}
