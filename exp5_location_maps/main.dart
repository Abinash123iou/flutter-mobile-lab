import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() => runApp(const MapsApp());

class MapsApp extends StatelessWidget {
  const MapsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Based App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(13.0827, 80.2707); // Chennai
  bool _isLoading = false;
  bool _locationFetched = false;
  String _locationInfo = 'Tap the button to get your location';

  void _getCurrentLocation() {
    setState(() {
      _isLoading = true;
      _locationInfo = 'Fetching location...';
    });
    html.window.navigator.geolocation.getCurrentPosition().then((pos) {
      final lat = pos.coords!.latitude!.toDouble();
      final lng = pos.coords!.longitude!.toDouble();
      setState(() {
        _currentPosition = LatLng(lat, lng);
        _locationInfo = 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
        _locationFetched = true;
        _isLoading = false;
      });
      _mapController.move(_currentPosition, 15.0);
    }).catchError((e) {
      setState(() {
        _locationInfo = 'Permission denied or location unavailable.';
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Based App'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _currentPosition, initialZoom: 12.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.exp5_location_maps',
                ),
                if (_locationFetched)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition,
                        width: 50, height: 50,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 50),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_locationInfo, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location),
                    label: Text(_isLoading ? 'Getting Location...' : 'Get My Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// pubspec.yaml dependencies:
// flutter_map: ^7.0.2
// latlong2: ^0.9.1
