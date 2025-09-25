import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final ColorScheme _lightScheme =
    ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.purple,
      onPrimary: Colors.white,
      secondary: AppColors.orange,
      onSecondary: AppColors.text,
      surface: Colors.white, // نستخدم surface بدل background
      onSurface: AppColors.text,
    );

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: _lightScheme,
    // لا تعتمد على background في الـ scheme
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: InkRipple.splashFactory,
  );

  final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme).copyWith(
    titleLarge: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w500),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _lightScheme.surface,
      foregroundColor: AppColors.text,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.text),
      iconTheme: const IconThemeData(color: AppColors.text),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightScheme.secondary,
        foregroundColor: _lightScheme.onSecondary,
        minimumSize: const Size(64, 52),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _lightScheme.primary,
        foregroundColor: _lightScheme.onPrimary,
        minimumSize: const Size(64, 52), // ✅
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.mutedPurple.withValues(alpha: .35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.mutedPurple.withValues(alpha: .35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.purple, width: 1.6),
      ),
      prefixIconColor: AppColors.purple,
      suffixIconColor: AppColors.purple,
      labelStyle: const TextStyle(color: AppColors.purple),
      floatingLabelStyle: const TextStyle(color: AppColors.purple),
      hintStyle: const TextStyle(color: AppColors.text),
    ),
    iconTheme: const IconThemeData(color: AppColors.purple),
    dividerColor: AppColors.mutedPurple.withValues(alpha: .35),
  );
}

ThemeData buildDarkTheme() {
  const surface = Color(0xFF1B1724);
  const bg = Color(0xFF13101A);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.purple,
        onPrimary: Colors.white,
        secondary: AppColors.orange,
        onSecondary: AppColors.text,
        surface: surface,
        onSurface: Colors.white,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    splashFactory: InkRipple.splashFactory,
  );

  final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.mutedPurple.withValues(alpha: .35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.mutedPurple.withValues(alpha: .35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.purple, width: 1.6),
      ),
      prefixIconColor: AppColors.mutedPurple,
      suffixIconColor: AppColors.mutedPurple,
      labelStyle: const TextStyle(color: Colors.white),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: bg,
      selectedColor: AppColors.purple.withValues(alpha: .15),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerColor: AppColors.mutedPurple.withValues(alpha: .20),
  );
}
