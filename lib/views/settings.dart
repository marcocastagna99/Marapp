import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../main.dart';

// Definizione dei colori
const Color pink = Color(0xFFE58F91);
const Color blue = Color(0xFF76B6FE);
const Color grey = Colors.grey;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  bool _followSystem = true; // Default: follow the system
  bool _notifications = false;
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
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

  void _sendTestNotification() {
    if (kDebugMode) {
      print('Test push notification sent');
    }
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
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ThemeSettingsView()),
                );
              },
              title: const Text('Theme Settings'),
              leading: const Icon(Icons.color_lens),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),

            ListTile(
              onTap: _sendTestNotification,
              title: const Text('Test Push Notification'),
              leading: const Icon(Icons.notifications),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),

            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScreenOrientationView()),
                );
              },
              title: const Text('Screen Orientation'),
              leading: const Icon(Icons.screen_rotation),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

// ---------------------- THEME SETTINGS ----------------------

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
          children: [
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
          ],
        ),
      ),
    );
  }
}

// ---------------------- SCREEN ORIENTATION SETTINGS ----------------------

class ScreenOrientationView extends StatefulWidget {
  const ScreenOrientationView({super.key});

  @override
  State<ScreenOrientationView> createState() => _ScreenOrientationViewState();
}

class _ScreenOrientationViewState extends State<ScreenOrientationView> {
  bool _followSystem = true;

  @override
  void initState() {
    super.initState();
    _loadOrientationSettings();
  }

  Future<void> _loadOrientationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _followSystem = prefs.getBool('followSystemOrientation') ?? true;
    });
  }

  Future<void> _saveOrientationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemOrientation', _followSystem);
  }

  void _toggleFollowSystem(bool value) {
    setState(() {
      _followSystem = value;
    });
    _saveOrientationSettings();
    if (value) {
      SystemChrome.setPreferredOrientations([]); // Sistema gestisce l'orientamento
    }
  }

  void _setOrientation(bool isPortrait) {
    if (!mounted) return;
    setState(() {
      _followSystem = false;
    });
    _saveOrientationSettings();
    SystemChrome.setPreferredOrientations(
      isPortrait
          ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Orientation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            if (!_followSystem)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.stay_primary_portrait),
                        onPressed: () => _setOrientation(true),
                      ),
                      const Text('Portrait'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.stay_primary_landscape),
                        onPressed: () => _setOrientation(false),
                      ),
                      const Text('Landscape'),
                    ],
                  ),
                ],
              ),

          ],
        ),
      ),
    );
  }
}
