import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const SensorsApp());

class SensorsApp extends StatelessWidget {
  const SensorsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Integration App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const SensorScreen(),
    );
  }
}

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});
  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  double _accX = 0, _accY = 0, _accZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      accelerometerEventStream().listen((AccelerometerEvent e) {
        setState(() { _accX = e.x; _accY = e.y; _accZ = e.z; });
      }),
    );
    _subscriptions.add(
      gyroscopeEventStream().listen((GyroscopeEvent e) {
        setState(() { _gyroX = e.x; _gyroY = e.y; _gyroZ = e.z; });
      }),
    );
  }

  @override
  void dispose() {
    for (var s in _subscriptions) s.cancel();
    super.dispose();
  }

  Widget _axisRow(String axis, double val, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Axis $axis', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${val.toStringAsFixed(4)} $unit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _card(String title, IconData icon, Color color, double x, double y, double z, String unit) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ]),
            const Divider(height: 20),
            _axisRow('X', x, unit, color),
            const SizedBox(height: 8),
            _axisRow('Y', y, unit, color),
            const SizedBox(height: 8),
            _axisRow('Z', z, unit, color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Integration App'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _card('Accelerometer', Icons.speed, Colors.deepPurple, _accX, _accY, _accZ, 'm/s²'),
            const SizedBox(height: 16),
            _card('Gyroscope', Icons.rotate_90_degrees_ccw, Colors.teal, _gyroX, _gyroY, _gyroZ, 'rad/s'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'Values update in real-time. Run on a physical device for live sensor data.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// pubspec.yaml dependencies:
// sensors_plus: ^4.0.2
