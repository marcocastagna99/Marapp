// https://www.flaticon.com

import 'package:flutter/material.dart';

// Define constant colors
const Color primary = Colors.cyan;
const Color primaryWhite = Colors.white;
const Color primaryBlack = Colors.black;

// Define constant text styles for light theme
const TextStyle lightAppBarTextStyle = TextStyle(
  color: primaryWhite,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

// Define constant text styles for dark theme
const TextStyle darkAppBarTextStyle = TextStyle(
  color: primaryBlack,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

bool isDarkMode = false; // TODO: add dark mode

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primary,
  hintColor: Colors.orange[50],
  scaffoldBackgroundColor: primaryWhite,
  
  appBarTheme: const AppBarTheme(
    backgroundColor: primary,
    iconTheme: IconThemeData(color: primaryWhite),
    titleTextStyle: lightAppBarTextStyle,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: primaryWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.blue[900],
      splashFactory: NoSplash.splashFactory,
    ),
  ),

  outlinedButtonTheme: const OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll<Color>(primary),
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: primaryBlack,
    ),
    titleMedium: TextStyle(fontSize: 18, color: Colors.grey),
  ),
);