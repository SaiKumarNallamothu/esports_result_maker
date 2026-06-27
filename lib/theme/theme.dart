import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF0C0D10);
  static const Color surface = Color(0xFF161920);
  static const Color surfaceCard = Color(0xFF1E222D);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldDark = Color(0xFFAA8010);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFB5179E);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color dividerColor = Color(0xFF2D313E);

  // Gradient definitions
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF1C40F), Color(0xFFD4AF37), Color(0xFF9A7B1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A1D26), Color(0xFF11131A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonPurpleGradient = LinearGradient(
    colors: [Color(0xFF7209B7), Color(0xFFB5179E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentGold,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: neonBlue,
        background: background,
        surface: surface,
      ),
      dividerColor: dividerColor,
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bebasNeue(
          fontSize: 24,
          letterSpacing: 1.5,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.bebasNeue(
          fontSize: 32,
          letterSpacing: 2,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.bebasNeue(
          fontSize: 24,
          letterSpacing: 1.5,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: accentGold, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.bebasNeue(
            fontSize: 18,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Predefined team avatar gradients (for placeholder logos)
  static final List<LinearGradient> avatarGradients = [
    const LinearGradient(
      colors: [Color(0xFFE74C3C), Color(0xFF9B2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF3498DB), Color(0xFF2B6CB0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF2ECC71), Color(0xFF2F855A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFF1C40F), Color(0xFFB7791F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF9B59B6), Color(0xFF6B46C1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF1ABC9C), Color(0xFF319795)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFE67E22), Color(0xFFC05621)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF34495E), Color(0xFF2D3748)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static LinearGradient getGradientForTeam(String teamName) {
    if (teamName.isEmpty) return avatarGradients[0];
    final int index = teamName.codeUnits.reduce((a, b) => a + b) % avatarGradients.length;
    return avatarGradients[index];
  }
}
