import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.cinzel(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.kenteGold,
    letterSpacing: 2,
  );

  static TextStyle get displayMedium => GoogleFonts.cinzel(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.kenteGold,
    letterSpacing: 1.5,
  );

  static TextStyle get displaySmall => GoogleFonts.cinzel(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.kenteGold,
    letterSpacing: 1,
  );

  static TextStyle get headlineMedium => GoogleFonts.cinzel(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static TextStyle get labelSmall => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonText => GoogleFonts.cinzel(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.kenteGold,
    letterSpacing: 1,
  );

  static TextStyle get tileSymbol => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.navyDeep,
  );

  static TextStyle get tileName => GoogleFonts.nunito(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.navyDeep,
  );
}
