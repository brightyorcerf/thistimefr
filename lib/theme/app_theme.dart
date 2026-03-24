// lib/theme/app_theme.dart
//
// "Tactile Digital Sanctuary" — every token is tuned for matte clay softness.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Palette ───────────────────────────────────────────────────────────────
  static const Color cream      = Color(0xFFFDF0D5);
  static const Color softPink   = Color(0xFFFDE2E4);
  static const Color mint       = Color(0xFFE2ECE9);
  static const Color plum       = Color(0xFF735F65);
  static const Color plumLight  = Color(0xFFA08A90);
  static const Color plumFaint  = Color(0xFFD4C8CB);

  static const Color ginghamRed = Color(0xFFB22234);
  static const Color yarnPink   = Color(0xFFFFB6C1);
  static const Color parchment  = Color(0xFFF5E6C8);
  static const Color starDust   = Color(0xFFFFD166);
  static const Color coinGold   = Color(0xFFDAA520);
  static const Color feltSage   = Color(0xFFD4E4DF);
  static const Color stampRed   = Color(0xFFCC2233);
  static const Color neonVial   = Color(0xFFB8F0FF);
  static const Color neonGlow   = Color(0xFF6FECFF);
  static const Color heartRed   = Color(0xFFE8838F);

  // ─── Clay Shadow Factory ───────────────────────────────────────────────────
  /// Returns layered box-shadows that simulate a matte clay / plushie surface.
  static List<BoxShadow> clayShadow({
    Color? color,
    double elevation = 1.0,
    bool invert = false,
  }) {
    final base = color ?? plum;
    if (invert) {
      // Pressed / recessed clay
      return [
        BoxShadow(
          color: base.withOpacity(0.22),
          blurRadius: 6,
          spreadRadius: -2,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      // Main drop shadow
      BoxShadow(
        color: base.withOpacity(0.16 * elevation),
        blurRadius: 24 * elevation,
        spreadRadius: 1 * elevation,
        offset: Offset(0, 7 * elevation),
      ),
      // Soft diffuse shadow
      BoxShadow(
        color: base.withOpacity(0.08 * elevation),
        blurRadius: 40 * elevation,
        spreadRadius: 4 * elevation,
        offset: Offset(0, 12 * elevation),
      ),
      // Top highlight edge (simulates matte clay inner rim)
      BoxShadow(
        color: Colors.white.withOpacity(0.80),
        blurRadius: 6,
        spreadRadius: -3,
        offset: const Offset(0, -2),
      ),
    ];
  }

  /// Quick-access clay BoxDecoration.
  static BoxDecoration clayBox({
    Color? color,
    double radius = 32,
    double elevation = 1.0,
    Gradient? gradient,
    Border? border,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? cream) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: clayShadow(color: color, elevation: elevation),
    );
  }

  // ─── Text Styles ───────────────────────────────────────────────────────────
  static TextStyle displayStyle({double size = 28, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? plum,
        letterSpacing: -0.5,
        shadows: const [
          Shadow(
            color: Colors.white,
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      );

  static TextStyle headlineStyle({double size = 20, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? plum,
      );

  static TextStyle bodyStyle({double size = 14, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? plum,
      );

  static TextStyle captionStyle({double size = 11, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? plumLight,
        letterSpacing: 0.4,
      );

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme {
    final baseText = GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: softPink,
        secondary: mint,
        tertiary: starDust,
        surface: cream,
        onPrimary: plum,
        onSecondary: plum,
        onSurface: plum,
        error: heartRed,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: plum, fontWeight: FontWeight.w900, letterSpacing: -1,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: plum, fontWeight: FontWeight.w800,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: plum, fontWeight: FontWeight.w700,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(color: plum),
        labelLarge: baseText.labelLarge?.copyWith(
          color: plum, fontWeight: FontWeight.w700, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.nunito(
          color: plum, fontSize: 22, fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: plum),
      ),
    );
  }
}
