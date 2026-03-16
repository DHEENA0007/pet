/// Adoption Provider - Manages adoption requests state

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../../models/adoption_request.dart';

class AdoptionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AdoptionRequest> _requests = [];
  List<AdoptionRequest> _allRequests = [];
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<AdoptionRequest> get requests => _requests;
  List<AdoptionRequest> get allRequests => _allRequests;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AdoptionRequest> get pendingRequests => 
      _requests.where((r) => r.isPending).toList();

  // Fetch my adoption requests (user)
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

  // Fetch all adoption requests (admin)
  Future<void> fetchAllRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('${ApiConstants.adoptionRequests}?all=true');
      final results = data is List ? data : (data['results'] ?? []);
      _allRequests = results.map<AdoptionRequest>((json) => AdoptionRequest.fromJson(json)).toList();
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

  // Reapply for a rejected adoption request (user)
  Future<bool> reapplyRequest(int requestId, String? message) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('${ApiConstants.adoptionRequests}$requestId/reapply/', {
        'request_message': message,
      });
      await fetchRequests();
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
  Future<bool> processRequest(int requestId, String status, String? notes, String? reason) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.post('${ApiConstants.adoptionRequests}$requestId/process/', {
        'status': status,
        'admin_notes': notes,
        'rejection_reason': reason,
      });
      await fetchAllRequests();
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

