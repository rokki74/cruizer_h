import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewProfilePage extends StatefulWidget {
  final String username;
  const ViewProfilePage({super.key, required this.username});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  Map<String, dynamic>? profileData; // now a single dict
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:9000/profile/${widget.username}'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } else {
        throw Exception("Cannot fetch profile details");
      }
    } catch (e) {
      print("Error fetching profile details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> editProfile(
    String username,
    Map<String, dynamic> updatedProfile,
  ) async {
    try {
      final res = await http.put(
        Uri.parse('http://localhost:9000/profile/$username'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedProfile),
      );
      if (res.statusCode == 200) {
        fetchProfileData(); // refresh
      } else {
        print("Failed to update profile: ${res.body}");
      }
    } catch (e) {
      print("Error editing profile: $e");
    }
  }

  void showEditDialog(Map<String, dynamic> profile) {
    final nameController = TextEditingController(text: profile['name'] ?? "");
    final emailController = TextEditingController(text: profile['email'] ?? "");
    final phoneController = TextEditingController(text: profile['phone'] ?? "");
    final birthdayController = TextEditingController(
      text: profile['birthday'] ?? "",
    );
    final locationController = TextEditingController(
      text: profile['location'] ?? "",
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Profile"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Your Name"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone No"),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  TextField(
                    controller: birthdayController,
                    decoration: const InputDecoration(labelText: "Birthday"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedProfile = {
                    "name": nameController.text,
                    "email": emailController.text,
                    "phone": phoneController.text,
                    "birthday": birthdayController.text,
                    "location": locationController.text,
                  };
                  editProfile(
                    profile['username'] ?? widget.username,
                    updatedProfile,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}'s profile")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : profileData == null
              ? const Center(child: Text("No profile data found."))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData!['username'] ?? "No Username",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Name: ${profileData!['name'] ?? ''}"),
                        Text("Email: ${profileData!['email'] ?? ''}"),
                        Text("Phone: ${profileData!['phone'] ?? ''}"),
                        Text("Birthday: ${profileData!['birthday'] ?? ''}"),
                        Text("Location: ${profileData!['location'] ?? ''}"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => showEditDialog(profileData!),
                          child: const Text("Edit Profile"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
