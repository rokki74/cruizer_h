import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../loading_dialog.dart'; // adjust the path if needed

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _fullName = '';
  DateTime? _birthday;
  String _email = '';
  String _phoneNumber = '';
  String _password = '';

  // Change to your FastAPI server URL
  final String apiBaseUrl = "http://127.0.0.1:9000";

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showLoadingDialog(context, message: "Creating account...");

      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": _username,
            "name": _fullName,
            "birthday":
                _birthday != null
                    ? _birthday!.toIso8601String().split("T")[0]
                    : null,
            "email": _email,
            "phone": _phoneNumber,
            "password": _password,
          }),
        );

        Navigator.pop(context); // Close loading dialog

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Signup successful!')));
          Navigator.pop(context); // Go back to login
        } else {
          final msg = jsonDecode(response.body)["detail"] ?? "Signup failed";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator:
                    (value) => value!.isEmpty ? 'Enter a username' : null,
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter your full name' : null,
                onSaved: (value) => _fullName = value!,
              ),
              GestureDetector(
                onTap: () => _selectBirthday(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      hintText:
                          _birthday == null
                              ? 'Select your birthday'
                              : '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}',
                    ),
                    validator:
                        (value) =>
                            _birthday == null ? 'Select a birthday' : null,
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value!.isEmpty || !value.contains('@')
                            ? 'Enter a valid email'
                            : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) => value!.isEmpty ? 'Enter a phone number' : null,
                onSaved: (value) => _phoneNumber = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.visiblePassword,
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
