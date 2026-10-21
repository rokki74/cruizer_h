import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String source;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.source,
  });
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return await _getLocationFromIp();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return await _getLocationFromIp();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return await _getLocationFromIp();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        source: 'GPS',
      );
    } catch (e) {
      print('Error getting GPS location: $e');
      return await _getLocationFromIp();
    }
  }

  Future<LocationData> _getLocationFromIp() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LocationData(
          latitude: data['lat'],
          longitude: data['lon'],
          source: 'IP',
        );
      } else {
        throw Exception('Failed to load location from IP');
      }
    } catch (e) {
      print('Error getting location from IP: $e');
      return LocationData(latitude: 0.0, longitude: 0.0, source: 'Unknown');
    }
  }
}
