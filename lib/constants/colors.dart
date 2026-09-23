import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBackground = Color(0xFF05070C);
  static const Color colorSurface = Color(0xFF10151E);
  static const Color colorSurfaceElevated = Color(0xFF171E2A);
  static const Color colorPrimary = Color(0xFFE8B931);
  static const Color colorPrimaryLight = Color(0xFF3EC6E0);
  static const Color colorPrimaryDark = Color(0xFFB8860B);
  static const Color colorAccent = Color(0xFF1493D6);
  static const Color colorNavShadow = Color(0xFF020308);
  static const Color colorHint = Color(0xFF7E8694);
  static const Color colorTextSecondary = Color(0xFFB7BCC6);
  static const Color colorTextMuted = Color(0xFF6E7684);
  static const Color colorGold = Color(0xFFF0C14A);
  static const Color colorOnGold = Color(0xFF1A1406);
  static const Color colorInputFill = Color(0xFF0C1018);
  static const Color colorInputBorder = Color(0xFF2C3548);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF6D56A), Color(0xFFE0A820), Color(0xFFC8960C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1A2433), Color(0xFF121820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [Color(0xFFF6D56A), Color(0xFFFFFFFF), Color(0xFF3EC6E0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Deep navy wash with a warm gold base, matching the logo.
  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF17324C),
      Color(0xFF0C1524),
      Color(0xFF070C14),
      Color(0xFF161108),
    ],
    stops: [0.0, 0.32, 0.68, 1.0],
  );
}
