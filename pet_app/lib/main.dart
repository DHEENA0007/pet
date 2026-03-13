/// AI-Enabled Pet Adoption & Care Management System
/// Main entry point for the Flutter application

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/pet_provider.dart';
import 'core/providers/adoption_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PetAdoptionApp());
}

class PetAdoptionApp extends StatefulWidget {
  const PetAdoptionApp({super.key});

  @override
  State<PetAdoptionApp> createState() => _PetAdoptionAppState();
}

class _PetAdoptionAppState extends State<PetAdoptionApp> {
  final AuthProvider _authProvider = AuthProvider();
  late final GoRouter _router = AppRouter.createRouter(_authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => AdoptionProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: MaterialApp.router(
        title: 'Pet Adoption',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
