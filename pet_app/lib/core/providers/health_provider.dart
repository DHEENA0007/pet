/// Health Provider - Manages vaccination, medical records, and care data

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../../models/health_models.dart';

class HealthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Vaccination> _vaccinations = [];
  List<MedicalRecord> _medicalRecords = [];
  List<CareSchedule> _careSchedules = [];
  List<Owner> _owners = [];
  List<ReturnRequest> _returnRequests = [];
  
  bool _isLoading = false;
  String? _error;

  List<Vaccination> get vaccinations => _vaccinations;
  List<MedicalRecord> get medicalRecords => _medicalRecords;
  List<CareSchedule> get careSchedules => _careSchedules;
  List<Owner> get owners => _owners;
  List<ReturnRequest> get returnRequests => _returnRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== VACCINATIONS ====================
  
  Future<void> fetchVaccinations({int? petId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = ApiConstants.vaccinations;
      if (petId != null) {
        endpoint += '?pet=$petId';
      }
      final data = await _apiService.get(endpoint);
      final results = data is List ? data : (data['results'] ?? []);
      _vaccinations = results.map<Vaccination>((json) => Vaccination.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDueVaccinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.get('${ApiConstants.vaccinations}due_soon/');
      final results = data is List ? data : (data['results'] ?? []);
      _vaccinations = results.map<Vaccination>((json) => Vaccination.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVaccination(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.vaccinations, data);
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

  Future<bool> deleteVaccination(int id) async {
    try {
      final success = await _apiService.delete('${ApiConstants.vaccinations}$id/');
      if (success) {
        _vaccinations.removeWhere((v) => v.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== MEDICAL RECORDS ====================
  
  Future<void> fetchMedicalRecords({int? petId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = ApiConstants.medicalRecords;
      if (petId != null) {
        endpoint += '?pet=$petId';
      }
      final data = await _apiService.get(endpoint);
      final results = data is List ? data : (data['results'] ?? []);
      _medicalRecords = results.map<MedicalRecord>((json) => MedicalRecord.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMedicalRecord(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.medicalRecords, data);
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

  // ==================== CARE SCHEDULES ====================
  
  Future<void> fetchCareSchedules({int? categoryId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = ApiConstants.careSchedules;
      if (categoryId != null) {
        endpoint += '?category=$categoryId';
      }
      final data = await _apiService.get(endpoint);
      final results = data is List ? data : (data['results'] ?? []);
      _careSchedules = results.map<CareSchedule>((json) => CareSchedule.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCareSchedule(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.careSchedules, data);
      await fetchCareSchedules();
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

  Future<bool> deleteCareSchedule(int id) async {
    try {
      final success = await _apiService.delete('${ApiConstants.careSchedules}$id/');
      if (success) {
        _careSchedules.removeWhere((c) => c.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== OWNERS/SHELTERS ====================
  
  Future<void> fetchOwners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/owners/');
      final results = data is List ? data : (data['results'] ?? []);
      _owners = results.map<Owner>((json) => Owner.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOwner(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/owners/', data);
      await fetchOwners();
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

  Future<bool> updateOwner(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.put('/owners/$id/', data);
      await fetchOwners();
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

  Future<bool> deleteOwner(int id) async {
    try {
      final success = await _apiService.delete('/owners/$id/');
      if (success) {
        _owners.removeWhere((o) => o.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== RETURN REQUESTS ====================
  
  Future<void> fetchReturnRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConstants.returnRequests);
      final results = data is List ? data : (data['results'] ?? []);
      _returnRequests = results.map<ReturnRequest>((json) => ReturnRequest.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReturnRequest(int petId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.returnRequests, {
        'pet': petId,
        'reason': reason,
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

  Future<bool> processReturnRequest(int id, String status, String? notes) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('${ApiConstants.returnRequests}$id/process/', {
        'status': status,
        'admin_notes': notes,
      });
      await fetchReturnRequests();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
