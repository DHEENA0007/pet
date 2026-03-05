/// App Color Constants
/// Based on Color Psychology from Application.txt

import 'package:flutter/material.dart';

class AppColors {
  // Premium Milky Palette
  static const Color primaryWarmBrown = Color(0xFFD6A473);  // Warm Golden Brown (Puppy)
  static const Color secondarySoftOrange = Color(0xFFFFCC99); // Soft Orange (Kitten)
  static const Color milkyCream = Color(0xFFFFF8F0);        // Milky White Background
  static const Color accentDarkBrown = Color(0xFF5D4037);   // Dark Brown Accent/Text
  static const Color softSage = Color(0xFFAED581);          // Soft Nature Green
  
  // Mapping to role-based names
  static const Color primaryColor = primaryWarmBrown;
  static const Color secondaryColor = secondarySoftOrange;
  static const Color backgroundColor = milkyCream;
  static const Color textPrimary = accentDarkBrown;
  
  // Primary Colors - Warm & Friendly (Updated mappings)
  static const Color primaryGreen = softSage;               // Replaced with Soft Sage
  static const Color secondaryBlue = Color(0xFF90CAF9);     // Softer Blue
  static const Color warmAmber = primaryWarmBrown;          // Mapped to Warm Brown
  static const Color softPeach = secondarySoftOrange;       // Mapped to Soft Orange
  static const Color backgroundCream = milkyCream;          // Mapped to Milky Cream
  
  // Neutral Colors
  static const Color textDark = accentDarkBrown;            // Mapped to Dark Brown
  static const Color textGrey = Color(0xFF8D6E63);          // Warm Grey/Brown
  static const Color borderLight = Color(0xFFEFEBE9);       // Light Warm Grey
  
  // Status Colors
  static const Color statusApproved = softSage;
  static const Color statusPending = primaryWarmBrown;
  static const Color statusRejected = Color(0xFFEF9A9A);    // Soft Red
  static const Color statusAdopted = secondaryBlue;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryWarmBrown, Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [secondarySoftOrange, primaryWarmBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF2D241E);    // Dark Warm Brown
  static const Color darkSurface = Color(0xFF3E3229);       // Lighter Dark Brown
  static const Color darkCard = Color(0xFF4E4035);          // Card Brown

  // Colors from the old palette needed for compatibility
  static const Color criticalRed = Color(0xFFE57373); 
  static const Color textCharcoal = Color(0xFF4A4A4A);
  
  // Aliases for backward compatibility
  static const Color backgroundWhite = Color(0xFFFFF9F0); // Maps to new cream background
  static const Color accentAmber = Color(0xFFFFCC80);     // Maps to new warm amber

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return statusApproved;
      case 'pending':
        return statusPending;
      case 'rejected':
        return statusRejected;
      case 'adopted':
        return statusAdopted;
      default:
        return textCharcoal;
    }
  }
}
