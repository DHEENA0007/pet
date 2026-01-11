/// AI-Enabled Pet Adoption & Care Management System
/// Main entry point for the Flutter application

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/pet_provider.dart';
import 'core/providers/adoption_provider.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PetAdoptionApp());
}

class PetAdoptionApp extends StatelessWidget {
  const PetAdoptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => AdoptionProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Pet Adoption',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
