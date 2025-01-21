import 'package:flutter/material.dart';

// Define constant colors
const Color primaryPink = Color(0xFFE58F91); // Rosa (Pink[300])
const Color primaryCyan = Color(0xFF76B6FE); // Blu (Blue[300])
const Color primaryWhite = Colors.white;
const Color primaryBlack = Colors.black;

// Define constant text styles
const TextStyle appBarTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

ThemeData getTheme(bool isDarkMode) {
  final primaryColor = isDarkMode ? primaryCyan : primaryPink; // Cambia colore principale
  final secondaryColor = isDarkMode ? primaryPink : primaryCyan; // Colore secondario invertito

  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    primaryColor: primaryColor, // Usa il colore principale dinamico
    scaffoldBackgroundColor: isDarkMode ? primaryBlack : primaryWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor, // Cambia colore AppBar
      iconTheme: IconThemeData(color: isDarkMode ? primaryWhite : primaryBlack),
      titleTextStyle: appBarTextStyle.copyWith(
        color: isDarkMode ? primaryWhite : primaryBlack,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent, // Sfondo trasparente
      selectedItemColor: primaryColor, // Colore icone selezionate
      unselectedItemColor: Colors.grey, // Colore icone non selezionate
      elevation: 0, // Nessuna ombra
      type: BottomNavigationBarType.fixed, // Layout fisso
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.pressed)) {
              return secondaryColor; // Usa il colore secondario quando premuto
            }
            return primaryColor; // Colore principale di default
          },
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          isDarkMode ? primaryBlack : primaryWhite,
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        elevation: MaterialStateProperty.all(4.0),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: isDarkMode ? primaryWhite : primaryBlack,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: isDarkMode ? primaryWhite : primaryBlack,
        fontSize: 14,
      ),
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? primaryWhite : primaryBlack,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: secondaryColor,
      selectionColor: const Color(0xFFB2EBF2), // Cyan[100]
      selectionHandleColor: const Color(0xFF006064), // Cyan[900]
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor, // Cambia colore FAB
      foregroundColor: isDarkMode ? primaryBlack : primaryWhite,
    ),
  );
}
