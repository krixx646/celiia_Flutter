import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to Dark Mode

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Custom Colors - Dark Theme (Glassmorphism)
  static const Color darkBackground = Color(0xFF0F111A);
  static const Color darkSurface = Color(0xFF1A1D2D);
  static const Color darkSurfaceGlass = Color(0xCC1A1D2D); // Translucent
  static const Color darkAccentOrange = Color(0xFFFF6F00);
  static const Color darkAccentGreen = Color(0xFF00E676);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkBorder = Color(0xFF2C3142);

  // Custom Colors - Light Theme (Classic)
  static const Color lightBackground = Color(0xFFFDFDFD);
  static const Color lightSurface = Colors.white;
  static const Color lightAccentOrange = Color(0xFFF57C00);
  static const Color lightTextPrimary = Colors.black87;
  static const Color lightTextSecondary = Colors.grey;

  // Getters for current theme colors
  Color get background => isDarkMode ? darkBackground : lightBackground;
  Color get surface => isDarkMode ? darkSurface : lightSurface;
  Color get surfaceGlass => isDarkMode ? darkSurfaceGlass : lightSurface;
  Color get accentOrange => isDarkMode ? darkAccentOrange : lightAccentOrange;
  Color get textPrimary => isDarkMode ? darkTextPrimary : lightTextPrimary;
  Color get textSecondary => isDarkMode ? darkTextSecondary : lightTextSecondary;
  Color get border => isDarkMode ? darkBorder : Colors.grey[200]!;
  
  // Helper for glass decoration
  BoxDecoration get glassDecoration => isDarkMode 
      ? BoxDecoration(
          color: const Color(0xFF1E2235).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF363D52).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        )
      : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        );
}

