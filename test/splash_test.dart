import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:marapp/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockFirebaseOptions extends Mock implements FirebaseOptions {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final mockApp = MockFirebaseApp();
    final mockOptions = MockFirebaseOptions();
    when(mockApp.name).thenReturn('test');
    when(mockApp.options).thenReturn(mockOptions);
    when(mockOptions.apiKey).thenReturn('test');
    when(mockOptions.appId).thenReturn('test');
    when(mockOptions.messagingSenderId).thenReturn('test');
    when(mockOptions.projectId).thenReturn('test');
    await Firebase.initializeApp(name: 'test', options: mockOptions);
  });

  testWidgets('Splash screen has Marapp text', (WidgetTester tester) async {
    // Launch the app
    app.main();

    // Allow the app to settle
    await tester.pumpAndSettle();

    // Add a delay to ensure the splash screen has time to load
    await Future.delayed(const Duration(seconds: 3));

    // Allow the app to settle again after the delay
    await tester.pumpAndSettle();

    // Print the widget tree to debug
    debugDumpApp();

    // Check if the text 'Marapp' is found
    expect(find.text('Marapp'), findsOneWidget);
  });
}
