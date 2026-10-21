import 'package:flutter/material.dart';
import '../widgets/live_map.dart'; // The polling-based map widget we built

class LocationMapPage extends StatelessWidget {
  const LocationMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mission Locations")),
      body: const LiveMap(),
    );
  }
}
