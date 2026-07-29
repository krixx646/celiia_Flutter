import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to dark mode and exposes themeMode + derived colors', () {
    final p = ThemeProvider();
    expect(p.themeMode, ThemeMode.dark);
    expect(p.isDarkMode, isTrue);
    expect(p.background, ThemeProvider.darkBackground);
    expect(p.surface, ThemeProvider.darkSurface);
    expect(p.accentOrange, ThemeProvider.darkAccentOrange);
    expect(p.textPrimary, ThemeProvider.darkTextPrimary);
    expect(p.textSecondary, ThemeProvider.darkTextSecondary);
    expect(p.border, ThemeProvider.darkBorder);

    // dark glass decoration branch
    final d = p.glassDecoration;
    expect(d.borderRadius, BorderRadius.circular(24));
  });

  test(
    'toggleTheme switches to light mode and light glassDecoration branch',
    () {
      final p = ThemeProvider();
      p.toggleTheme(false);

      expect(p.themeMode, ThemeMode.light);
      expect(p.isDarkMode, isFalse);
      expect(p.background, ThemeProvider.lightBackground);
      expect(p.surface, ThemeProvider.lightSurface);
      expect(p.accentOrange, ThemeProvider.lightAccentOrange);
      expect(p.textPrimary, ThemeProvider.lightTextPrimary);
      expect(p.textSecondary, ThemeProvider.lightTextSecondary);

      // light glass decoration branch
      final d = p.glassDecoration;
      expect(d.color, Colors.white);
      expect(d.borderRadius, BorderRadius.circular(24));
    },
  );
}
