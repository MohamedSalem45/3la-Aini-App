import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

const String kFont = 'IBMPlexSansArabic';

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => const TextTheme(
        displayLarge: TextStyle(fontFamily: kFont, fontSize: 32,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
        displayMedium: TextStyle(fontFamily: kFont, fontSize: 26,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
        headlineMedium: TextStyle(fontFamily: kFont, fontSize: 22,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontFamily: kFont, fontSize: 18,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontFamily: kFont, fontSize: 16,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontFamily: kFont, fontSize: 15,
            fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.7),
        bodyMedium: TextStyle(fontFamily: kFont, fontSize: 13,
            fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.7),
        labelLarge: TextStyle(fontFamily: kFont, fontSize: 14,
            fontWeight: FontWeight.w600),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: kFont,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
              fontFamily: kFont, fontSize: 18,
              fontWeight: FontWeight.w700, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontFamily: kFont, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontFamily: kFont, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          hintStyle: const TextStyle(
              fontFamily: kFont, fontSize: 14, color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
            color: AppColors.divider, thickness: 1, space: 0),
      );
}
