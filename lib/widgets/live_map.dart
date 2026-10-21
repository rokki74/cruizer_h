import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  double? latitude;
  double? longitude;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCoordinates();

    // Poll SharedPreferences every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkForCoordinateChange();
    });
  }

  Future<void> _loadCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude');
    final lon = prefs.getDouble('longitude');

    if (lat != latitude || lon != longitude) {
      setState(() {
        latitude = lat;
        longitude = lon;
      });
    }
  }

  Future<void> _checkForCoordinateChange() async {
    await _loadCoordinates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
        center: LatLng(latitude!, longitude!),
        zoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latitude!, longitude!),
              width: 80,
              height: 80,
              builder: (ctx) => const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}