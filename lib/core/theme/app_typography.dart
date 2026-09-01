import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// الخطوط والأنماط الطباعية لتطبيق مرور السودان الذكي (خط Cairo)
class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        height: 1.25,
      );

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get goldAccent => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.goldPrimary,
      );

  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      );

  static TextStyle get plateText => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      );
}
