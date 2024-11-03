import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to main screen after 3 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
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
            Text(
              "Marapp",
              style: TextStyle(
                fontSize: 32,  // Fixed size that works well across devices
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
