import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(
    BuildContext context, {
    String fontFamily = 'Poppins',
    Color primaryColor = AppColors.primaryBlue,
  }) {
    final textTheme = _buildTextTheme(fontFamily, AppColors.titleText);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.charcoalGrey,
        error: AppColors.red,
        onError: AppColors.pureWhite,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: _buttonTheme(
        textTheme,
        primaryColor,
        AppColors.pureWhite,
      ),
      inputDecorationTheme: _inputTheme(
        context,
        textTheme,
        AppColors.pureWhite,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.pureWhite,
      ),
    );
  }

  static ThemeData darkTheme(
    BuildContext context, {
    String fontFamily = 'Poppins',
    Color primaryColor = AppColors.primaryBlue,
  }) {
    final textTheme = _buildTextTheme(fontFamily, AppColors.pureWhite);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: AppColors.pureWhite,
        surface: const Color(0xFF1E1E1E),
        onSurface: AppColors.pureWhite,
        error: AppColors.red,
        onError: AppColors.pureWhite,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: _buttonTheme(
        textTheme,
        primaryColor,
        AppColors.pureWhite,
      ),
      inputDecorationTheme: _inputTheme(
        context,
        textTheme,
        const Color(0xFF1E1E1E),
      ),
    );
  }

  static TextTheme _buildTextTheme(String fontFamily, Color color) {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ).apply(fontFamily: fontFamily, bodyColor: color, displayColor: color);
  }

  static ElevatedButtonThemeData _buttonTheme(
    TextTheme textTheme,
    Color bgColor,
    Color fgColor,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(20),
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        textStyle: textTheme.bodyMedium,
      ),
    );
  }

  static InputDecorationTheme _inputTheme(
    BuildContext context,
    TextTheme textTheme,
    Color fillColor,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
      labelStyle: textTheme.bodyMedium,
      floatingLabelStyle: textTheme.bodyMedium,
      counterStyle: textTheme.bodyMedium,
      helperStyle: textTheme.bodyMedium!.copyWith(color: AppColors.primaryBlue),
      errorStyle: textTheme.bodyMedium!.copyWith(color: AppColors.red),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}
