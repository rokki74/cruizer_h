import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cruizer_h/loading_dialog.dart';

class StartMissionPage extends StatefulWidget {
  const StartMissionPage({super.key});

  @override
  State<StartMissionPage> createState() => _StartMissionPageState();
}

class _StartMissionPageState extends State<StartMissionPage> {
  final _formKey = GlobalKey<FormState>();

  String _missionName = '';
  String _category = 'Mental Wellbeing';
  String _duration = '3 Months';
  String _description = '';
  double? _weight;
  double? _height;
  String? _allergens;

  final List<String> _categories = [
    'Fitness',
    'Nutrition',
    'Mental Wellbeing',
    'General',
  ];
  final List<String> _durations = ['3 Months', '6 Months'];

  Future<void> _submitMission() async {
    showLoadingDialog(context, message: "Submitting your mission...");

    final url = Uri.parse('http://localhost:9000/submit-mission');
    const username = "japheth";

    int durationValue = int.tryParse(_duration.split(' ')[0]) ?? 0;

    final Map<String, dynamic> missionData = {
      'username': username,
      'mission_name': _missionName,
      'category': _category,
      'duration': durationValue,
      'description': _description.isNotEmpty ? _description : null,
      'weight': _weight,
      'height': _height,
      'allergens': _allergens?.isNotEmpty == true ? _allergens : null,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(missionData),
      );

      hideLoadingDialog(context);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } catch (e) {
      hideLoadingDialog(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a Mission')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mission Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a mission name'
                            : null,
                onChanged: (val) => _missionName = val,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items:
                    _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              DropdownButtonFormField<String>(
                value: _duration,
                items:
                    _durations
                        .map(
                          (dur) =>
                              DropdownMenuItem(value: dur, child: Text(dur)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _duration = value!),
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _weight = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _height = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Allergens (if any)',
                ),
                onChanged: (val) => _allergens = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mission Description',
                  hintText:
                      'e.g. planning to relieve stress and boost mental health',
                ),
                maxLines: 3,
                onChanged: (val) => _description = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitMission();
                  }
                },
                child: const Text('Submit Mission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
