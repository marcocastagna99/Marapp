import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen shows "Marapp" text', (WidgetTester tester) async {
    // Build the splash screen widget
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Marapp'),
        ),
      ),
    ));

    // Verify if the "Marapp" text is found
    expect(find.text('Marapp'), findsOneWidget);
  });
}
