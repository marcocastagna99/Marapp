import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:marapp/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // prepare FirebaseOptions from the JSON file
    

    final options = FirebaseOptions(
      apiKey: 'your-api-key',
      appId: 'your-app-id',
      messagingSenderId: 'your-messaging-sender-id',
      projectId: 'your-project-id',
    );
    await Firebase.initializeApp(name: 'test', options: options);
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
