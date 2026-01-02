import 'package:celia_flutter/providers/navigation_provider.dart';
import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:celia_flutter/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

bool _isCenteredOnScreen(WidgetTester tester, Finder finder) {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final center = tester.getCenter(finder);
  return center.dx >= 0 && center.dx <= size.width && center.dy >= 0 && center.dy <= size.height;
}

void main() {
  testWidgets('MainScreen reacts to NavigationProvider.setIndex() from outside', (tester) async {
    final nav = NavigationProvider();
    final theme = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NavigationProvider>.value(value: nav),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ],
        child: const MaterialApp(
          home: MainScreen(
            screens: [
              Center(child: Text('SCREEN_0')),
              Center(child: Text('SCREEN_1')),
              Center(child: Text('SCREEN_2')),
              Center(child: Text('SCREEN_3')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('SCREEN_0'), findsOneWidget);
    expect(_isCenteredOnScreen(tester, find.text('SCREEN_0')), isTrue);

    // Simulate a different widget (e.g., Home quick action) setting the index.
    nav.setIndex(3);
    await tester.pump(); // start animation
    await tester.pump(const Duration(milliseconds: 350)); // let it complete

    expect(find.text('SCREEN_3'), findsOneWidget);
    expect(_isCenteredOnScreen(tester, find.text('SCREEN_3')), isTrue);
  });
}


