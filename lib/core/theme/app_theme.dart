import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.peacockDark,
        secondary: AppColors.peacock,
        surface: AppColors.cardColor,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.peacockDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.black),
        bodyMedium: TextStyle(color: AppColors.black),
        bodySmall: TextStyle(color: AppColors.black54),
        titleLarge: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(color: AppColors.black),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.peacock,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.peacockDark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.peacockDark,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: AppColors.black),
        prefixIconColor: AppColors.peacockDark,
        suffixIconColor: AppColors.peacockDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.peacock),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.peacockDark,
            width: 2,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.black,
        iconColor: AppColors.peacockDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.peacockDark),
      dividerTheme: const DividerThemeData(color: AppColors.peacock),
    );
  }
}
