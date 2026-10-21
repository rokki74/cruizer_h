import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../loading_dialog.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      // Skip login and go to HomePage directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(username: savedUsername)),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    showLoadingDialog(context); // show loading animation

    try {
      final response = await http.post(
        Uri.parse("http://localhost:9000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      Navigator.pop(context); // close loading dialog

      if (response.statusCode == 200) {
        // Save username to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(username: username)),
        );
      } else {
        setState(() => error = "Invalid credentials or server error");
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() => error = "Could not connect to server");
    }
  }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter username"
                            : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter password"
                            : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _login, child: const Text("Login")),
              const SizedBox(height: 5),
              OutlinedButton(
                onPressed: _goToSignup,
                child: const Text("Sign Up"),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
