/// API Service - HTTP client for Django backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Initialize tokens from storage
  Future<void> initTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Save tokens to storage
  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  // Clear tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  bool get isAuthenticated => _accessToken != null;

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      return {'success': true};
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'error': error['detail'] ?? 'Login failed',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  // Refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], _refreshToken!);
      return true;
    }
    return false;
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    var response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );

    // Try refresh token if unauthorized
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: _headers,
        );
      }
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    var response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    // Try refresh token if unauthorized
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(data),
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {'success': true};
    } else {
      throw Exception('Failed to post data: ${response.body}');
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    var response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(data),
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.body}');
    }
  }

  // Generic DELETE request
  Future<bool> delete(String endpoint) async {
    var response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: _headers,
        );
      }
    }

    return response.statusCode == 204 || response.statusCode == 200;
  }
}
