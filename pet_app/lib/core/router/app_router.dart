/// App Router - Navigation configuration using go_router

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/pets/pet_list_screen.dart';
import '../../screens/pets/pet_detail_screen.dart';
import '../../screens/pets/add_pet_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/adoption/my_requests_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/pending_approvals_screen.dart';
import '../../screens/admin/category_management_screen.dart';
import '../../screens/admin/admin_adoption_requests_screen.dart';
import '../../screens/admin/owner_management_screen.dart';
import '../../screens/admin/return_requests_screen.dart';
import '../../screens/health/vaccination_management_screen.dart';
import '../../screens/health/medical_records_screen.dart';
import '../../screens/health/care_schedule_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/pets/my_adopted_pet_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/help/help_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pets',
        name: 'pets',
        builder: (context, state) => const PetListScreen(),
      ),
      GoRoute(
        path: '/pets/:id',
        name: 'petDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PetDetailScreen(petId: id);
        },
      ),
      GoRoute(
        path: '/my-pets/:id',
        name: 'myAdoptedPet',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MyAdoptedPetScreen(petId: id);
        },
      ),
      GoRoute(
        path: '/add-pet',
        name: 'addPet',
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-requests',
        name: 'myRequests',
        builder: (context, state) => const MyRequestsScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/pending',
        name: 'pendingApprovals',
        builder: (context, state) => const PendingApprovalsScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        name: 'categoryManagement',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/admin/adoptions',
        name: 'adminAdoptions',
        builder: (context, state) => const AdminAdoptionRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/owners',
        name: 'ownerManagement',
        builder: (context, state) => const OwnerManagementScreen(),
      ),
      GoRoute(
        path: '/admin/returns',
        name: 'returnRequests',
        builder: (context, state) => const ReturnRequestsScreen(),
      ),
      
      // Health Routes
      GoRoute(
        path: '/vaccinations',
        name: 'vaccinations',
        builder: (context, state) => const VaccinationManagementScreen(),
      ),
      GoRoute(
        path: '/vaccinations/:petId',
        name: 'petVaccinations',
        builder: (context, state) {
          final petId = int.parse(state.pathParameters['petId']!);
          final petName = state.uri.queryParameters['name'];
          return VaccinationManagementScreen(petId: petId, petName: petName);
        },
      ),
      GoRoute(
        path: '/medical-records',
        name: 'medicalRecords',
        builder: (context, state) => const MedicalRecordsScreen(),
      ),
      GoRoute(
        path: '/medical-records/:petId',
        name: 'petMedicalRecords',
        builder: (context, state) {
          final petId = int.parse(state.pathParameters['petId']!);
          final petName = state.uri.queryParameters['name'];
          return MedicalRecordsScreen(petId: petId, petName: petName);
        },
      ),
      GoRoute(
        path: '/care-schedules',
        name: 'careSchedules',
        builder: (context, state) => const CareScheduleManagementScreen(),
      ),
      
      // Reports
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      
      // Settings & Help
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
    
    // Redirect logic
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      // Allow splash screen
      if (isSplash) return null;

      // If not logged in, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and trying to access login, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

