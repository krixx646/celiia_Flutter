import 'package:flutter_test/flutter_test.dart';

import 'package:celia_flutter/providers/theme_provider.dart';

void main() {
  test('ThemeProvider toggles dark mode', () {
    final theme = ThemeProvider();
    expect(theme.isDarkMode, isFalse);
    theme.toggleTheme(true);
    expect(theme.isDarkMode, isTrue);
    theme.toggleTheme(false);
    expect(theme.isDarkMode, isFalse);
  });
}
