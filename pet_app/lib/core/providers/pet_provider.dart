/// Pet Provider - Manages pet data state

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../../models/pet.dart';
import '../../models/category.dart';

class PetProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Pet> _pets = [];
  List<Pet> _myPets = [];
  List<Pet> _adoptedPets = [];
  List<PetCategory> _categories = [];
  Pet? _selectedPet;
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  List<Pet> get myPets => _myPets;
  List<Pet> get adoptedPets => _adoptedPets;
  List<PetCategory> get categories => _categories;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all available pets
  Future<void> fetchPets({String? status, int? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = ApiConstants.pets;
      List<String> params = [];
      
      if (status != null) params.add('status=$status');
      if (category != null) params.add('category=$category');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final data = await _apiService.get(endpoint);
      final results = data is List ? data : (data['results'] ?? []);
      _pets = results.map<Pet>((json) => Pet.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch pet details
  Future<void> fetchPetDetails(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.get('${ApiConstants.pets}$id/');
      _selectedPet = Pet.fromJson(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch my posted pets
  Future<void> fetchMyPets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConstants.myPosts);
      final results = data is List ? data : (data['results'] ?? []);
      _myPets = results.map<Pet>((json) => Pet.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch my adopted pets
  Future<void> fetchAdoptedPets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConstants.myAdopted);
      final results = data is List ? data : (data['results'] ?? []);
      _adoptedPets = results.map<Pet>((json) => Pet.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      final data = await _apiService.get(ApiConstants.categories);
      final results = data is List ? data : (data['results'] ?? []);
      _categories = results.map<PetCategory>((json) => PetCategory.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create new pet post
  Future<bool> createPet(Map<String, dynamic> petData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiConstants.pets, petData);
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

  // Approve pet (admin)
  Future<bool> approvePet(int petId) async {
    try {
      await _apiService.post('${ApiConstants.pets}$petId/approve/', {});
      await fetchPets();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject pet (admin)
  Future<bool> rejectPet(int petId, String reason) async {
    try {
      await _apiService.post('${ApiConstants.pets}$petId/reject/', {'reason': reason});
      await fetchPets();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear selected pet
  void clearSelectedPet() {
    _selectedPet = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
