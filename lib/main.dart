import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Per kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:marapp/utils/push_notification_service.dart';
import 'package:marapp/utils/theme.dart';
import 'package:marapp/views/presentation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marapp/views/splash.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'package:marapp/views/home.dart';
import 'package:marapp/views/registration_view.dart';
import 'firebase_options.dart'; // Importa il file di configurazione
import  'package:marapp/views/passwordReset.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:marapp/views/presentation.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Firebase
  await initializeFirebase();
  await dotenv.load();

if(!kIsWeb) {
  // Impostazione della gestione notifiche
  await OneSignal.shared.setAppId(
      dotenv.env['ONE_SIGNAL_APP_ID']!); // Sostituisci con il tuo App ID

  OneSignal.shared.setNotificationWillShowInForegroundHandler((
      OSNotificationReceivedEvent event) {
    // Mostra la notifica, invia null per non mostrarla, invia la notifica per mostrarla
    event.complete(event.notification);
  });

  // Gestione delle notifiche aperte
  OneSignal.shared.setNotificationOpenedHandler((
      OSNotificationOpenedResult result) {
    // Utilizza i metodi disponibili nella nuova API
    OSNotification notification = result.notification;
    String? title = notification.title;
    String? body = notification.body;

    print('OneSignal: notification opened: $title - $body');
  });
}


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
                theme: getTheme(false), // Usa il tuo tema personalizzato per la modalità chiara
                darkTheme: getTheme(true), // Usa il tuo tema personalizzato per la modalità scura
                themeMode: themeMode, // Gestisce il tema basato su `themeNotifier`
                initialRoute: '/splash',
                routes: {
                  '/presentation': (context) => PresentationPage(),
                  '/splash': (context) => SplashScreen(),
                  '/register': (context) => RegistrationScreen(),
                  '/home': (context) => HomeScreen(),
                  '/passwordReset': (context) => PasswordResetScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}