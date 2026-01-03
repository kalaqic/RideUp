import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6B55D3);
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
  static const Color titleBlue = Color(0xFF6B55D3);
  
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
  
  // Background color - subtle pink/white gradient
  static const Color backgroundColor = Color(0xFFFFF5F8);
  
  static RadialGradient radialGradient = RadialGradient(
    center: const Alignment(0.7, -0.6),
    radius: 2,
    colors: [
      Colors.white,
      pastelPink.withValues(alpha: 0.15),
      pastelPink.withValues(alpha: 0.08),
      Colors.white,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );
  
  // Neomorphic Box Decorations
  static BoxDecoration neomorphicRaised({
    double borderRadius = 16,
    Color? color,
  }) {
    final baseColor = color ?? Colors.white;
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  static BoxDecoration neomorphicPressed({
    double borderRadius = 16,
    Color? color,
  }) {
    final baseColor = color ?? Colors.white;
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  static BoxDecoration neomorphicFlat({
    double borderRadius = 16,
    Color? color,
  }) {
    final baseColor = color ?? Colors.white;
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.5),
          offset: const Offset(-3, -3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(3, 3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  // Neomorphic button decoration for colored buttons
  static BoxDecoration neomorphicButton({
    required Color color,
    double borderRadius = 16,
    bool pressed = false,
  }) {
    if (pressed) {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );
    }
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.3),
          offset: const Offset(-3, -3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(3, 3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  // Text Styles - Using clean secondary font (Inter) for body text
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
    height: 1.2,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Title Styles using Custom Font
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 42,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    height: 1.2,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 32,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.3,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'SimpleSerenitySerif',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    height: 1.3,
  );
}
