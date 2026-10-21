import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/mission_store.dart';

class ViewMissionsPage extends StatefulWidget {
  final String username;
  const ViewMissionsPage({super.key, required this.username});

  @override
  State<ViewMissionsPage> createState() => _ViewMissionsPageState();
}

class _ViewMissionsPageState extends State<ViewMissionsPage> {
  List<Map<String, dynamic>> missions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:9000/missions/${widget.username}'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          missions = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load missions");
      }
    } catch (e) {
      print("Error fetching missions: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteMission(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('http://localhost:9000/missions/$id'),
      );
      if (res.statusCode == 200) {
        setState(() {
          missions.removeWhere((m) => m['id'] == id);
        });
      }
    } catch (e) {
      print("Error deleting mission: $e");
    }
  }

  Future<void> editMission(int id, Map<String, dynamic> updatedMission) async {
    try {
      final res = await http.put(
        Uri.parse('http://localhost:9000/missions/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedMission),
      );
      if (res.statusCode == 200) {
        fetchMissions(); // refresh
      }
    } catch (e) {
      print("Error editing mission: $e");
    }
  }

  void useMission(Map<String, dynamic> mission) {
    MissionStore().addMission(mission);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Mission '${mission['mission_name']}' added for use!"),
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> mission) {
    final titleController = TextEditingController(
      text: mission['mission_name'],
    );
    final descController = TextEditingController(text: mission['description']);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Mission"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedMission = {
                    "title": titleController.text,
                    "description": descController.text,
                  };
                  editMission(mission['id'], updatedMission);
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}'s Missions")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : missions.isEmpty
              ? Center(child: Text("No missions found."))
              : ListView.builder(
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission['mission_name'] ?? "Untitled",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(mission['description'] ?? ""),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showEditDialog(mission),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteMission(mission['id']),
                              ),
                              ElevatedButton(
                                onPressed: () => useMission(mission),
                                child: Text("Use Mission"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
