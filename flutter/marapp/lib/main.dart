import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Usa alias per FirebaseAuth
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';
import 'views/login_signup_view.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Il tuo AuthProvider
      ],
      child: MaterialApp(
        title: 'Mara’s Sweets and Savory',
        theme: appTheme,
        home: AuthWrapper(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginSignupView(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // Se l'utente è autenticato, vai alla Home
        } else {
          return LoginSignupView(); // Se non è autenticato, vai al Login
        }
      },
    );
  }
}
