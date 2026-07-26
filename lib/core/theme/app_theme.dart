import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color palette matching views/layouts/base.html (Tailwind Brand Violet & Slate-950)
  static const Color brandViolet = Color(0xFF8B5CF6); // Brand 500 (#8b5cf6) - Primary Accent
  static const Color brandDeep = Color(0xFF7C3AED);   // Brand 600 (#7c3aed) - Primary Buttons & Highlights
  static const Color brandDark = Color(0xFF4C1D95);   // Brand 900 (#4c1d95) - Category Badge Backgrounds
  static const Color brandLight = Color(0xFFEDE9FE);  // Brand 100 (#ede9fe) - Category Text
  static const Color accentEmerald = Color(0xFF10B981); // Emerald 500 (#10b981) - Approved / Success

  // Aliases for seamless compatibility across features
  static const Color skyBlue = brandViolet;
  static const Color seaGreen = accentEmerald;
  
  static const Color darkBg = Color(0xFF020617);      // Slate 950 (#020617) - Dark mode background
  static const Color lightBg = Color(0xFFF8FAFC);     // Slate 50 (#f8fafc) - Light mode background
  static const Color cardBg = Color(0xFF0F172A);      // Slate 900 (#0f172a) - Dark card background
  static const Color cardBgLight = Color(0xFFFFFFFF); // White (#ffffff) - Light card background
  
  static const Color textLight = Color(0xFFF8FAFC);    // Light text for dark mode
  static const Color textDark = Color(0xFF0F172A);     // Dark text for light mode
  static const Color textMuted = Color(0xFF94A3B8);    // Slate 400 (#94a3b8) - Muted secondary text
  
  static const Color borderDark = Color(0xFF1E293B);   // Slate 800 (#1e293b)
  static const Color borderLight = Color(0xFFE2E8F0);  // Slate 200 (#e2e8f0)

  // Organic Glassmorphic Decoration for Dark Mode (24px rounded corners)
  static BoxDecoration get darkGlassDecoration => BoxDecoration(
        color: cardBg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: brandViolet.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Glassmorphic Decoration for Light Mode
  static BoxDecoration get lightGlassDecoration => BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
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
      primaryColor: brandViolet,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: brandViolet,
        secondary: brandDeep,
        surface: cardBg,
        onSurface: textLight,
        error: Colors.redAccent,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
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
        color: cardBg.withValues(alpha: 0.45),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandViolet, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
      primaryColor: brandViolet,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: brandViolet,
        secondary: brandDeep,
        surface: cardBgLight,
        onSurface: textDark,
        error: Colors.redAccent,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.w800,
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
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandViolet, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
