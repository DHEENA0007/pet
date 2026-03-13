/// API Configuration Constants

class ApiConstants {
  // Base URL - Change this to your Django server URL
  //static const String baseUrl = 'https://pet-vew4.onrender.com/api';
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // Auth Endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String refreshToken = '/auth/refresh/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  
  // Dashboard Endpoints
  static const String adminDashboard = '/dashboard/admin/';
  static const String userDashboard = '/dashboard/user/';
  
  // Pet Endpoints
  static const String pets = '/pets/';
  static const String myPosts = '/pets/my_posts/';
  static const String myAdopted = '/pets/my_adopted/';
  
  // Category Endpoints
  static const String categories = '/categories/';
  
  // Adoption Endpoints
  static const String adoptionRequests = '/adoption-requests/';
  static const String returnRequests = '/return-requests/';
  
  // Health Endpoints
  static const String vaccinations = '/vaccinations/';
  static const String medicalRecords = '/medical-records/';
  static const String careLogs = '/care-logs/';
  static const String careSchedules = '/care-schedules/';
  
  // AI Endpoints
  static const String recommendations = '/recommendations/';
  
  // Notifications
  static const String notifications = '/notifications/';
}
