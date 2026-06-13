import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.cardLight,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // أزرار وردية/ماجنتا كهوية التطبيق الذهبي
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppColors.magenta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
      // زر الإضافة العائم أخضر
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.fabGreen,
        foregroundColor: Colors.white,
      ),
      // حقول إدخال pill بحواف دائرية كبيرة
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.magenta : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.magenta.withValues(alpha: 0.5) : null,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.cardDark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppColors.magenta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.fabGreen,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }
}
