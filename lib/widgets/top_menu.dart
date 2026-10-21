import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/profile_page.dart';
import '../screens/login_page.dart';
import '../pages/settings_page.dart';

class TopMenu extends StatelessWidget {
  final String username;

  const TopMenu({super.key, required this.username});

  // A private async function to handle the logout process
  Future<void> _logoutUser(BuildContext context) async {
    // Access the local storage instance
    final prefs = await SharedPreferences.getInstance();

    // Clear the stored username to signify the user is no longer logged in.
    // This is the core of the client-side logout logic.
    await prefs.remove('username');

    // Navigate to the LoginPage and remove all previous screens from the stack.
    // This prevents the user from being able to press the back button to get back
    // to a logged-in state.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        if (value == "profile") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfilePage(username: username),
            ),
          );
        } else if (value == "settings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        } else if (value == "logout") {
          // Call the _logoutUser function when the "logout" option is selected.
          _logoutUser(context);
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: "settings", child: Text("Settings")),
            PopupMenuItem(value: "profile", child: Text("Profile")),
            PopupMenuItem(value: "logout", child: Text("Logout")),
          ],
    );
  }
}
