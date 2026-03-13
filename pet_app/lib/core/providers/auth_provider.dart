/// Auth Provider - Manages authentication state

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _apiService.isAuthenticated && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Set this in main.dart / app root to navigate to login when session expires.
  void Function()? onSessionExpired;

  // Initialize - restore existing session
  Future<void> init() async {
    await _apiService.initTokens();

    // Wire up session-expiry callback from ApiService
    _apiService.onSessionExpired = () {
      _user = null;
      notifyListeners();
      onSessionExpired?.call();
    };

    if (_apiService.isAuthenticated) {
      try {
        await fetchProfile();
      } catch (_) {
        // Stored token is invalid — clear and treat as logged out
        await _apiService.clearTokens();
        _user = null;
        notifyListeners();
      }
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['success']) {
        await fetchProfile();
        _isLoading = false;
        if (_user == null) {
          _error = 'Failed to load profile after login';
          notifyListeners();
          return false;
        }
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.register({
        'username': username,
        'email': email,
        'password': password,
        'password2': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      _isLoading = false;
      
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch user profile
  Future<void> fetchProfile() async {
    try {
      final data = await _apiService.get(ApiConstants.profile);
      _user = User.fromJson(data);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> profileData, {XFile? profileImage}) async {
    _isLoading = true;
    notifyListeners();

    try {
      dynamic data;
      if (profileImage != null) {
        // Use multipart request
        final Map<String, String> stringFields = {};
        profileData.forEach((key, value) {
          if (value != null) {
            stringFields[key] = value.toString();
          }
        });
        
        data = await _apiService.multipart(
          'PUT', 
          ApiConstants.profile, 
          stringFields,
          xFiles: {'profile_image': profileImage}
        );
      } else {
        data = await _apiService.put(ApiConstants.profile, profileData);
      }
      
      _user = User.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout — blacklists refresh token on server then clears local storage
  Future<void> logout() async {
    await _apiService.serverLogout();
    _user = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
