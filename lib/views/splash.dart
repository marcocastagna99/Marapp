import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("SplashScreen initialized");
    // Navigate to main screen after 3 seconds
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        print("Checking authentication...");
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        print("Is user authenticated: ${authProvider.isAuthenticated}");

        if (authProvider.isAuthenticated) {
          print("User is authenticated, navigating to Home");
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print("User is not authenticated, navigating to Registration");
          Navigator.pushReplacementNamed(context, '/register');
        }
      } else {
        print("SplashScreen is no longer mounted");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset(
              'assets/icon.png',
              width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
              height: MediaQuery.of(context).size.width * 0.4, // Keep aspect ratio square
            ),
            const SizedBox(height: 20),
            // App name text
            const Text(
              "Marapp",
              style: TextStyle(
                fontSize: 32,  // Fixed size that works well across devices
                fontWeight: FontWeight.bold,
                // color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primary,
                color: primaryCyan,
              ),
            ),
            const Text(
              "Mara's sweets and savory",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
