import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/colors.dart';

class AppTheme {
  static const String fontFamily = 'Mulish';

  static ThemeData dark() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.6,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.colorTextSecondary,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.colorPrimary,
        secondary: AppColors.colorPrimaryDark,
        surface: AppColors.colorSurface,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      dividerColor: Colors.white12,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.colorSurfaceElevated,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.colorPrimary,
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle displayTitle = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.05,
    letterSpacing: -0.4,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle seeAll = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.colorGold,
  );

  static const TextStyle meta = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.colorTextSecondary,
  );
}
