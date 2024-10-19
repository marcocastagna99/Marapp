import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.lightBlue,
  hintColor: Colors.orange[50],
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.lightBlue,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlue,   // Colore di sfondo
      foregroundColor: Colors.white,       // Colore del testo
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.transparent, // Colore di sfondo
      foregroundColor: Colors.blue[900],
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.lightBlue,           // Colore del bordo e del testo
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18, color: Colors.grey),
  ),
);
