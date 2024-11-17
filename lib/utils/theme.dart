// https://www.flaticon.com

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
      backgroundColor: WidgetStateProperty.all<Color>(primaryCyan),
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
  ),
);

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final Color? borderColor;

  const RoundedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.onChanged,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

