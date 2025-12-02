import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF8C50);
  static const Color primaryOrangeDark = Color(0xFFFF6030);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0D0D0F);
  static const Color backgroundMedium = Color(0xFF1A1A1F);
  static const Color surfaceLight = Color(0xFF252530);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF); // 60% opacity
  static const Color textTertiary = Color(0x66FFFFFF); // 40% opacity
  
  // Accent Colors
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFEF4444);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primaryOrangeDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundMedium, backgroundDark],
  );
  
  // Text Styles
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );
  
  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  static TextStyle get labelSmall => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  // Theme Data
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryOrange,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: primaryOrangeDark,
      surface: surfaceLight,
      background: backgroundDark,
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineMedium: headlineMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelSmall: labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headlineMedium,
    ),
  );
}
