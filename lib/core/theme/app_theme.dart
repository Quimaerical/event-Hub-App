import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color palette (Tailwind Slate / Sky Blue / Sea Green)
  static const Color skyBlue = Color(
    0xFF0EA5E9,
  ); // Sky Blue (#0ea5e9) - Primary accent
  static const Color seaGreen = Color(
    0xFF0D9488,
  ); // Sea Green (#0d9488) - Secondary / Success
  static const Color darkBg = Color(
    0xFF020617,
  ); // Dark Slate (#020617) - Dark mode background
  static const Color lightBg = Color(
    0xFFF8FAFC,
  ); // Light Slate (#f8fafc) - Light mode background
  static const Color cardBg = Color(
    0xFF0F172A,
  ); // Surface Slate (#0f172a) - Dark card background
  static const Color cardBgLight = Color(
    0xFFFFFFFF,
  ); // Surface White (#ffffff) - Light card background
  static const Color textLight = Color(0xFFF8FAFC); // Light text for dark mode
  static const Color textDark = Color(0xFF0F172A); // Dark text for light mode
  static const Color textMuted = Color(
    0xFF64748B,
  ); // Muted Slate (#64748b) - Secondary text / subtle borders
  static const Color borderDark = Color(0xFF1E293B); // Slate-800
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200

  // Glassmorphic Decoration for Dark Mode
  static BoxDecoration get darkGlassDecoration => BoxDecoration(
    color: cardBg.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Glassmorphic Decoration for Light Mode
  static BoxDecoration get lightGlassDecoration => BoxDecoration(
    color: cardBgLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderLight, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Dark Theme Definition
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: skyBlue,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: skyBlue,
        secondary: seaGreen,
        surface: cardBg,
        onSurface: textLight,
        error: Colors.redAccent,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.outfit(color: textLight, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        bodySmall: GoogleFonts.outfit(color: textMuted, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: cardBg.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: skyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg.withValues(alpha: 0.6),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: skyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  // Light Theme Definition
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: skyBlue,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: skyBlue,
        secondary: seaGreen,
        surface: cardBgLight,
        onSurface: textDark,
        error: Colors.redAccent,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.outfit(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        bodySmall: GoogleFonts.outfit(color: textMuted, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: cardBgLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: skyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBgLight,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textDark, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: skyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
