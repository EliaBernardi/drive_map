import 'package:flutter/material.dart';

/// Shared palette for screens, charts and the app shell.
abstract final class DriveColors {
  static const background = Color(0xFFEEF1EB);
  static const surface = Color(0xFFFCFDF9);
  static const border = Color(0xFFD3DCD0);
  static const ink = Color(0xFF27382E);
  static const accent = Color(0xFF32754A);
  static const grass = Color(0xFF79BE72);
  static const mint = Color(0xFFE0EED9);
  static const muted = Color(0xFF657369);
  static const amber = Color(0xFF99651B);
  static const red = Color(0xFFBA4541);
}

abstract final class AppTheme {
  static const cardRadius = 20.0;
  static const controlRadius = 14.0;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: DriveColors.accent,
        brightness: Brightness.light,
        primary: DriveColors.accent,
        onPrimary: Colors.white,
        primaryContainer: DriveColors.mint,
        onPrimaryContainer: DriveColors.ink,
        surface: DriveColors.surface,
        onSurface: DriveColors.ink,
        outline: DriveColors.muted,
        outlineVariant: DriveColors.border,
        error: DriveColors.red,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: DriveColors.background,
      dividerColor: DriveColors.border,
      textTheme: base.textTheme
          .apply(bodyColor: DriveColors.ink, displayColor: DriveColors.ink)
          .copyWith(
            headlineSmall: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
              color: DriveColors.ink,
            ),
            titleLarge: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: DriveColors.ink,
            ),
            titleMedium: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DriveColors.ink,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DriveColors.mint,
        foregroundColor: DriveColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: DriveColors.ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      cardTheme: CardThemeData(
        color: DriveColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: DriveColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: const BorderSide(color: DriveColors.border, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DriveColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: DriveColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: DriveColors.border),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: DriveColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
