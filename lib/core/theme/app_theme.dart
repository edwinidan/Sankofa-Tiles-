import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sankofa_game_theme.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SankofaGameTheme.backgroundTop,
        colorScheme: const ColorScheme.dark(
          primary: SankofaGameTheme.antiqueGold,
          secondary: SankofaGameTheme.mutedGold,
          surface: SankofaGameTheme.boardSurface,
          onPrimary: SankofaGameTheme.darkText,
          onSecondary: SankofaGameTheme.darkText,
          onSurface: SankofaGameTheme.parchmentLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: SankofaGameTheme.backgroundTop,
          foregroundColor: SankofaGameTheme.antiqueGold,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SankofaGameTheme.appParchment,
            foregroundColor: SankofaGameTheme.darkText,
            side: const BorderSide(
              color: SankofaGameTheme.antiqueGold,
              width: 1.5,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            foregroundColor: SankofaGameTheme.antiqueGold,
          ),
        ),
        iconTheme: const IconThemeData(color: SankofaGameTheme.antiqueGold),
        dividerColor: SankofaGameTheme.mutedGold,
        textTheme:
            GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: SankofaGameTheme.antiqueGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return SankofaGameTheme.antiqueGold;
            }
            return SankofaGameTheme.mutedLightText;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return SankofaGameTheme.mutedGold;
            }
            return SankofaGameTheme.boardSurfaceAlt;
          }),
        ),
      );
}
