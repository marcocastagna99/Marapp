import 'package:flutter/material.dart';

// Define constant colors
const Color primaryCyan = Colors.cyan;
const Color primaryWhite = Colors.white;
const Color primaryBlack = Colors.black;

// Define constant text styles
const TextStyle appBarTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

ThemeData getTheme(bool isDarkMode) => ThemeData(
  brightness: isDarkMode ? Brightness.dark : Brightness.light,
  primaryColor: primaryCyan,
  hintColor: Colors.grey,
  scaffoldBackgroundColor: isDarkMode ? primaryBlack : primaryWhite,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryCyan,
    iconTheme: IconThemeData(color: isDarkMode ? primaryBlack : primaryWhite),
    titleTextStyle: appBarTextStyle.copyWith(
        color: isDarkMode ? primaryBlack : primaryWhite),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryCyan,
      foregroundColor: isDarkMode ? primaryBlack : primaryWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: isDarkMode ? Colors.blue[100] : Colors.blue[900],
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(primaryCyan),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        color: isDarkMode ? primaryWhite : primaryBlack, fontSize: 16),
    bodyMedium: TextStyle(
        color: isDarkMode ? primaryWhite : primaryBlack, fontSize: 14),
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? primaryWhite : primaryBlack,
    ),
    titleMedium: TextStyle(
        fontSize: 18, color: isDarkMode ? Colors.grey : Colors.grey),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryCyan,
    selectionColor: Colors.cyan[100],
    selectionHandleColor: Colors.cyan[900], // flutter bug, handles remain purple
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.grey,
    ),
    floatingLabelStyle: TextStyle(
      color: Colors.grey,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: MaterialStateProperty.all<Color>(
          isDarkMode ? primaryWhite : primaryBlack),
      backgroundColor: MaterialStateProperty.all<Color>(primaryCyan),
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(8.0)),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryCyan,
    foregroundColor: isDarkMode ? primaryBlack : primaryWhite,
  ),
);

