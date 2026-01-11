/// App Color Constants
/// Based on Color Psychology from Application.txt

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF6FCF97);      // Care Green
  static const Color secondaryBlue = Color(0xFF56CCF2);     // Trust Blue
  static const Color accentAmber = Color(0xFFF2C94C);       // Warm Amber
  static const Color criticalRed = Color(0xFFEB5757);       // Soft Red
  static const Color backgroundWhite = Color(0xFFF9FAFB);   // Comfort White
  static const Color textCharcoal = Color(0xFF333333);      // Charcoal Black
  
  // Status Colors
  static const Color statusApproved = Color(0xFF6FCF97);
  static const Color statusPending = Color(0xFFF2C94C);
  static const Color statusRejected = Color(0xFFEB5757);
  static const Color statusAdopted = Color(0xFF56CCF2);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [secondaryBlue, Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  
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
