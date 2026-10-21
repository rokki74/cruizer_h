import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

const fastapiBackendIp = "localhost:9000";

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Weather Forecast', home: WeatherHome());
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String location = "Loading...";
  Map<String, dynamic>? forecastData;
  final String backendUrl =
      'http://$fastapiBackendIp/weather'; // Replace with your actual IP

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || !serviceEnabled) {
        print("Location not available, falling back to Nairobi");
        await fetchFromBackend();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("User location: ${position.latitude}, ${position.longitude}");

      await fetchFromBackend(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      await fetchFromBackend(); // fallback to default city
    }
  }

  Future<void> fetchFromBackend({double? lat, double? lon}) async {
    String url = backendUrl;
    if (lat != null && lon != null) {
      url += '?lat=$lat&lon=$lon';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        location = decoded['location'];
        forecastData = decoded['forecast'];
      });
    } else {
      setState(() {
        location = "Error fetching data";
        forecastData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather for $location')),
      body:
          forecastData == null
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children:
                    forecastData!.entries.map((entry) {
                      String date = entry.key;
                      var day = entry.value;
                      return ListTile(
                        title: Text("$date - ${day['condition']}"),
                        subtitle: Text(
                          "Avg: ${day['avg_temp_c']}°C | Max: ${day['max_temp_c']}°C | Min: ${day['min_temp_c']}°C",
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}
