import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navyDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.kenteGold,
      secondary: AppColors.kenteGoldDim,
      surface: AppColors.navyMid,
      onPrimary: AppColors.navyDeep,
      onSecondary: AppColors.navyDeep,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDeep,
      foregroundColor: AppColors.kenteGold,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyMid,
        foregroundColor: AppColors.kenteGold,
        side: const BorderSide(color: AppColors.kenteGold, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.cinzel(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.kenteGold,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.kenteGold),
    dividerColor: AppColors.kenteGoldDim,
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.cinzel(
        color: AppColors.kenteGold,
        fontWeight: FontWeight.bold,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.kenteGold;
        return AppColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.kenteGoldDim;
        return AppColors.navyLight;
      }),
    ),
  );
}
