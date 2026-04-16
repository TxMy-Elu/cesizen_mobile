import 'package:flutter/material.dart';

class CesizenColors {
  static const background = Color(0xFFF4F6F2);
  static const foreground = Color(0xFF1F2A24);
  static const primary = Color(0xFF4B6B59);
  static const destructive = Color(0xFFC75F42);
  static const border = Color(0xFFE3EBE2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7FAF6);
}

ThemeData buildCesizenTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: CesizenColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: CesizenColors.primary,
    secondary: const Color(0xFF6BA382),
    error: CesizenColors.destructive,
    surface: CesizenColors.surface,
    onSurface: CesizenColors.foreground,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: CesizenColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: CesizenColors.background,
      foregroundColor: CesizenColors.foreground,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: CesizenColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: CesizenColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CesizenColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CesizenColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CesizenColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CesizenColors.primary, width: 1.4),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      side: const BorderSide(color: CesizenColors.border),
      backgroundColor: CesizenColors.surface,
      selectedColor: CesizenColors.primary.withValues(alpha: 0.16),
    ),
  );
}
