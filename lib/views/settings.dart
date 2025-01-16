import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  bool _followSystem = true; // Default: follow the system
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _followSystem = prefs.getBool('followSystem') ?? true;
      if (_followSystem) {
        _selectedTheme = ThemeMode.system;
      } else {
        final isDarkMode = prefs.getBool('darkMode') ?? false;
        _selectedTheme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystem', _followSystem);
    if (!_followSystem) {
      await prefs.setBool('darkMode', _selectedTheme == ThemeMode.dark);
    }
  }

  void _toggleFollowSystem(bool value) {
    setState(() {
      _followSystem = value;
      _selectedTheme = value ? ThemeMode.system : ThemeMode.light;
    });
    _saveThemeSettings();
    MarappState.themeNotifier.value = _selectedTheme;
  }

  void _setThemeMode(ThemeMode theme) {
    setState(() {
      _selectedTheme = theme;
    });
    _saveThemeSettings();
    MarappState.themeNotifier.value = _selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to go to Theme Settings
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ThemeSettingsView()),
                );
              },
              child: const Text('Theme Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSettingsView extends StatefulWidget {
  const ThemeSettingsView({super.key});

  @override
  State<ThemeSettingsView> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView> {
  bool _followSystem = true;
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _followSystem = prefs.getBool('followSystem') ?? true;
      if (_followSystem) {
        _selectedTheme = ThemeMode.system;
      } else {
        final isDarkMode = prefs.getBool('darkMode') ?? false;
        _selectedTheme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystem', _followSystem);
    if (!_followSystem) {
      await prefs.setBool('darkMode', _selectedTheme == ThemeMode.dark);
    }
  }

  void _toggleFollowSystem(bool value) {
    setState(() {
      _followSystem = value;
      _selectedTheme = value ? ThemeMode.system : ThemeMode.light;
    });
    _saveThemeSettings();
    MarappState.themeNotifier.value = _selectedTheme;
  }

  void _setThemeMode(ThemeMode theme) {
    setState(() {
      _selectedTheme = theme;
    });
    _saveThemeSettings();
    MarappState.themeNotifier.value = _selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Follow System Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Follow the system'),
                CupertinoSwitch(
                  value: _followSystem,
                  onChanged: _toggleFollowSystem,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Dark/Light Mode Buttons
            if (!_followSystem)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Light Mode Button
                  ElevatedButton.icon(
                    onPressed: () => _setThemeMode(ThemeMode.light),
                    icon: const Icon(Icons.wb_sunny),
                    label: const Text('Light Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTheme == ThemeMode.light
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  // Dark Mode Button
                  ElevatedButton.icon(
                    onPressed: () => _setThemeMode(ThemeMode.dark),
                    icon: const Icon(Icons.nightlight_round),
                    label: const Text('Dark Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTheme == ThemeMode.dark
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
