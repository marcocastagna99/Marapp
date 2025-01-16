import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Per kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marapp/views/splash.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'package:marapp/views/home.dart';
import 'package:marapp/views/registration_view.dart';
import 'firebase_options.dart'; // Importa il file di configurazione

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Firebase
  await initializeFirebase();

  // Avvio dell'app con tema iniziale
  runApp(Marapp(initialThemeMode: await getInitialThemeMode()));
}

// Funzione per inizializzare Firebase
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Passa le opzioni di configurazione
  );
}

// Funzione per ottenere il tema iniziale
Future<ThemeMode> getInitialThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final followSystem = prefs.getBool('followSystem') ?? true;

  if (followSystem) {
    // Se segue il tema di sistema, ritorna quello corrispondente
    final Brightness deviceBrightnessMode = PlatformDispatcher.instance.platformBrightness;
    return deviceBrightnessMode == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  } else {
    // Se non segue il sistema, usa il tema salvato
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

class Marapp extends StatefulWidget {
  const Marapp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

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
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Marapp',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                darkTheme: ThemeData.dark(), // Tema scuro opzionale
                themeMode: themeMode,
                initialRoute: '/splash',
                routes: {
                  '/splash': (context) => SplashScreen(),
                  '/register': (context) => RegistrationScreen(),
                  '/home': (context) => HomeScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
