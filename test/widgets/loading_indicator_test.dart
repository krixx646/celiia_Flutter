import 'package:celia_flutter/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoadingIndicator builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(message: 'Loading...'),
        ),
      ),
    );
    expect(find.text('Loading...'), findsOneWidget);
  });
}

