/// Adoption Provider - Manages adoption requests state

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../../models/adoption_request.dart';

class AdoptionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AdoptionRequest> _requests = [];
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<AdoptionRequest> get requests => _requests;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AdoptionRequest> get pendingRequests => 
      _requests.where((r) => r.isPending).toList();

  // Fetch adoption requests
  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConstants.adoptionRequests);
      final results = data is List ? data : (data['results'] ?? []);
      _requests = results.map<AdoptionRequest>((json) => AdoptionRequest.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create adoption request
  Future<bool> createRequest(int petId, String? message) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.adoptionRequests, {
        'pet': petId,
        'request_message': message,
      });
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

  // Process adoption request (admin)
  Future<bool> processRequest(int requestId, String status, {String? notes, String? reason}) async {
    try {
      await _apiService.post('${ApiConstants.adoptionRequests}$requestId/process/', {
        'status': status,
        'admin_notes': notes,
        'rejection_reason': reason,
      });
      await fetchRequests();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch AI recommendations
  Future<void> fetchRecommendations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConstants.recommendations);
      _recommendations = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
