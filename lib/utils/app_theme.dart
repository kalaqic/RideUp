import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6B4AFF);
  static const Color primaryLight = Color(0xFF9B7FFF);
  static const Color primaryDark = Color(0xFF5035E0);
  
  // Pastel Background Colors
  static const Color pastelPink = Color(0xFFFFBBD0);
  static const Color pastelPeach = Color(0xFFFFE4B8);
  static const Color pastelLavender = Color(0xFFE8DFFF);
  
  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color titleBlue = Color(0xFF2563EB);
  
  // Utility Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE91E63);
  
  // Gradient Background
  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      pastelPink.withValues(alpha: 0.3),
      pastelPeach.withValues(alpha: 0.3),
      Colors.white,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );
  
  static RadialGradient radialGradient = RadialGradient(
    center: const Alignment(0.7, -0.6),
    radius: 2,
    colors: [
      pastelPink.withValues(alpha: 0.4),
      pastelPeach.withValues(alpha: 0.3),
      Colors.white,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
  
  // Text Styles
  static TextStyle displayLarge = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
    height: 1.2,
  );
  
  static TextStyle displayMedium = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    height: 1.3,
  );
  
  static TextStyle displaySmall = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.2,
    height: 1.3,
  );
  
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.5,
  );
  
  static TextStyle bodySmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );
  
  static TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  // Title Styles using Custom Font
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 42,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
    height: 1.2,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    height: 1.3,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 24,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.2,
    height: 1.3,
  );
}
