import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';
import 'views/home_screen.dart';
import 'views/signup.dart';
import 'views/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize themeNotifier with the device's current theme mode, if there are no saved preferences
  final prefs = await SharedPreferences.getInstance();
  final Brightness deviceBrightnessMode =
      PlatformDispatcher.instance.platformBrightness;
  final ThemeMode initialThemeMode;

  if (prefs.containsKey('darkMode')) {
    initialThemeMode =
        prefs.getBool('darkMode')! ? ThemeMode.dark : ThemeMode.light;
  } else {
    initialThemeMode = deviceBrightnessMode == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  runApp(Marapp(initialThemeMode: initialThemeMode));
}

class Marapp extends StatefulWidget {
  const Marapp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  MarappState createState() => MarappState();
}

class MarappState extends State<Marapp> {
  // Create a ValueNotifier to manage the theme state
  static late final ValueNotifier<ThemeMode> themeNotifier;

  @override
  void initState() {
    super.initState();
    themeNotifier = ValueNotifier(widget.initialThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, ThemeMode currentMode, child) {
          return MaterialApp(
            title: 'Marapp',
            theme: getTheme(false),
            darkTheme: getTheme(true),
            themeMode: currentMode,
            home: SplashScreen(),
            routes: {
              '/home': (context) => AuthWrapper(),
              '/login': (context) => RegistrationFlow(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // User is logged in
        } else {
          return RegistrationFlow(); // User needs to register or log in
        }
      },
    );
  }
}
