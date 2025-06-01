import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RunScreen extends StatefulWidget {
  static const String routeName = '/run';
  const RunScreen({super.key});
  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  Timer? _timer;
  int _seconds = 0;
  double _totalDistance = 0.0;
  List<LatLng> _positions = [];
  GoogleMapController? _mapController;
  bool _isRunning = false;
  DateTime? _startTime;
  StreamSubscription<Position>? _positionStream;

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  void _toggleRun() async {
    if (_isRunning) {
      _pauseRun();
    } else {
      await _startRun();
    }
  }

  Future<void> _startRun() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isRunning = true;
      _startTime ??= DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      if (_positions.isNotEmpty) {
        final distance = Geolocator.distanceBetween(
          _positions.last.latitude,
          _positions.last.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        _totalDistance += distance / 1000; // convert to km
      }
      setState(() {
        _positions.add(newPosition);
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
      });
    });
  }

  void _pauseRun() {
    setState(() => _isRunning = false);
    _timer?.cancel();
    _positionStream?.pause();
  }

  void _stopRun() async {
    _timer?.cancel();
    _positionStream?.cancel();

    if (_startTime == null || _positions.length < 2) return;

    final runData = {
      'date': Timestamp.now(),
      'startTime': Timestamp.fromDate(_startTime!),
      'duration': _seconds,
      'distance': double.parse(_totalDistance.toStringAsFixed(2)),
      'pace': _seconds / _totalDistance, // seconds per km
      'coordinates':
          _positions
              .map((e) => {'lat': e.latitude, 'lng': e.longitude})
              .toList(),
    };

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(userId)
          .collection('runs')
          .add(runData);
    }

    setState(() {
      _isRunning = false;
      _seconds = 0;
      _totalDistance = 0.0;
      _positions.clear();
      _startTime = null;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Run saved successfully!")));
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return true;
  }

  String get formattedTime {
    final duration = Duration(seconds: _seconds);
    return [
      duration.inHours.toString().padLeft(2, '0'),
      (duration.inMinutes % 60).toString().padLeft(2, '0'),
      (duration.inSeconds % 60).toString().padLeft(2, '0'),
    ].join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text("Distance (km)", style: TextStyle(fontSize: 16)),
            Text(
              _totalDistance.toStringAsFixed(2),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.200000, 106.816666),
                  zoom: 16,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("run"),
                    color: Colors.blue,
                    width: 5,
                    points: _positions,
                  ),
                },
                myLocationEnabled: true,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
            const Text("Time", style: TextStyle(fontSize: 16)),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.stop),
                    iconSize: 36,
                    onPressed: _isRunning ? _stopRun : null,
                  ),
                  ElevatedButton(
                    onPressed: _toggleRun,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    iconSize: 36,
                    onPressed: () async {
                      if (_positions.isNotEmpty) {
                        await _mapController?.animateCamera(
                          CameraUpdate.newLatLng(_positions.last),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
