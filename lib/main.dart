import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marapp/views/splash.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'package:marapp/views/home.dart';
import 'package:marapp/views/registration_view.dart';
import 'firebase_options.dart'; // Importa il file di configurazione

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Passa le opzioni di configurazione
  );

  final Brightness deviceBrightnessMode = PlatformDispatcher.instance.platformBrightness;
  final ThemeMode initialThemeMode = deviceBrightnessMode == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

  runApp(Marapp(initialThemeMode: initialThemeMode));
}

class Marapp extends StatefulWidget {
  const Marapp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Marapp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/register': (context) => RegistrationScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }

  @override
  MarappState createState() => MarappState();
}
class MarappState extends State<Marapp> {

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Marapp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/register': (context) => RegistrationScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}