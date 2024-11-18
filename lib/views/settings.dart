import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart'; // Import the main.dart file to access the themeNotifier

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  bool _darkMode = false;
  bool _notifications = false;

  @override
  void initState() {
    super.initState();
    // Remove _darkMode initialization from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _darkMode = Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
      MarappState.themeNotifier.value = _darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode'),
                Platform.isIOS || Platform.isMacOS
                  ? CupertinoSwitch(
                    value: _darkMode,
                    onChanged: _toggleDarkMode,
                    )
                  : Switch(
                    value: _darkMode,
                    onChanged: _toggleDarkMode,
                    ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications'),
                Platform.isIOS || Platform.isMacOS
                  ? CupertinoSwitch(
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                      _notifications = value;
                      });
                    },
                    )
                  : Switch(
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                      _notifications = value;
                      });
                    },
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}