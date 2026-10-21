import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/login_page.dart';
import 'pages/start_mission_page.dart';
import 'pages/view_missions_page.dart';
import 'pages/settings_page.dart';
import 'pages/location_map.dart';
import 'services/location_service.dart';

// Global state
final ValueNotifier<ThemeMode> appTheme = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> preferredLanguage = ValueNotifier('English');

final locationService = LocationService();

/// Background task handler
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "updateLocation") {
      await _saveCurrentLocation();
    }
    return Future.value(true);
  });
}

/// Saves current location to SharedPreferences
Future<void> _saveCurrentLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final locationData = await locationService.getCurrentLocation();

  await prefs.setDouble('latitude', locationData.latitude);
  await prefs.setDouble('longitude', locationData.longitude);
  await prefs.setString('locationSource', locationData.source);

  print(
      "Location saved: ${locationData.latitude}, ${locationData.longitude} via ${locationData.source}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved preferences
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'light';
  final savedLang = prefs.getString('language') ?? 'English';

  appTheme.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  preferredLanguage.value = savedLang;

  // Initialize location on startup
  await _saveCurrentLocation();

  // Initialize Workmanager for background tasks
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "updateLocationTask",
    "updateLocation",
    frequency: const Duration(minutes: 15),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appTheme,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Cruizer Health AI',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          routes: {
            '/start_mission': (context) => const StartMissionPage(),
            'view_missions': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return ViewMissionsPage(username: args);
            },
            '/settings': (context) => const SettingsPage(),
            'view_places': (context) => const LocationMapPage(),
          },
          home: LoginPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
