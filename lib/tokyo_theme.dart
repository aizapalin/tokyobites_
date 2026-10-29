import 'package:flutter/material.dart';

/// Colors taken from the Tokyo Twist landing page CSS variables,
/// applied over layered dark surfaces for the mobile dashboard.
class TokyoTheme {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFFCD7B6);
  static const Color cream = Color(0xFFFFF1E8);
  static const Color background = Color(0xFF16120F);
  static const Color surface = Color(0xFF1C1612);
  static const Color cardDark = Color(0xFF2A211C);
  static const Color elevated = Color(0xFF322820);
  static const Color textMedium = Color(0xFFD4B8A0);
  static const Color darkText = Color(0xFFFFF1E8);

  /// Kept so existing FoodCard / tab references continue to compile.
  static const Color cardLight = cardDark;

  static ThemeData material() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: cream,
        onSecondary: Color(0xFF1A1410),
        onSurface: cream,
      ),
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      cardColor: cardDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14100D),
        foregroundColor: primary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary.withValues(alpha: 0.28),
        backgroundColor: const Color(0xFF14100D),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textMedium);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: textMedium);
        }),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.28),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
        modalBackgroundColor: cardDark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cream,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: elevated,
        contentTextStyle: TextStyle(color: cream),
      ),
    );
  }
}
