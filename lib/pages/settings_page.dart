import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // to access appTheme & preferredLanguage

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<String> supportedLanguages = const ['English', 'Swahili'];

  Future<void> _changeTheme(bool darkMode) async {
    appTheme.value = darkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', darkMode ? 'dark' : 'light');
  }

  Future<void> _changeLanguage(String lang) async {
    preferredLanguage.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: <Widget>[
          // App Preferences Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appTheme,
            builder: (context, theme, _) {
              return ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Theme'),
                trailing: Switch(
                  value: theme == ThemeMode.dark,
                  onChanged: (value) async {
                    await _changeTheme(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Theme is now ${value ? 'Dark' : 'Light'}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: preferredLanguage,
            builder: (context, lang, _) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: lang,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.blueAccent),
                  underline: Container(height: 2, color: Colors.blueAccent),
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      await _changeLanguage(newValue);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to $newValue'),
                        ),
                      );
                    }
                  },
                  items:
                      supportedLanguages
                          .map<DropdownMenuItem<String>>(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Note: Language settings are currently only for AI coach and chats.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy tapped!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
