import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/activity_model.dart';
import '../run_tracker/run_summary_screen.dart'; // PASTIKAN import ini ada!

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
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Merekam lokasi setiap pergerakan 1 meter
      ),
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

  void _stopRun() {
    _timer?.cancel();
    _positionStream?.cancel();

    // Validasi: Apakah run sudah benar-benar dimulai?
    if (_startTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Run belum dimulai.")));
      return;
    }

    // Validasi: Apakah posisi cukup untuk dihitung?
    if (_positions.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data posisi tidak cukup.")));
      return;
    }

    // Validasi: Jarak harus lebih dari 0 untuk menghindari division by zero
    if (_totalDistance == 0.0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jarak tempuh masih nol.")));
      return;
    }

    // Coba navigasi, jika route belum ada, tangkap error-nya
    try {
      final activity = RunActivity(
        date: DateTime.now(),
        startTime: _startTime!,
        duration: _seconds,
        distance: double.parse(_totalDistance.toStringAsFixed(2)),
        pace: _seconds / _totalDistance,
        coordinates:
            _positions
                .map((e) => {'lat': e.latitude, 'lng': e.longitude})
                .toList(),
      );

      Navigator.pushReplacementNamed(
        context,
        RunSummaryScreen.routeName,
        arguments: activity,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat menyimpan run: $e")),
      );
      return;
    }

    // Reset state setelah navigasi berhasil
    setState(() {
      _isRunning = false;
      _seconds = 0;
      _totalDistance = 0.0;
      _positions.clear();
      _startTime = null;
    });
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
      backgroundColor: Colors.white, // ✅ Latar belakang putih
      body: SafeArea(
        child: Column(
          children: [
            // 🔙 Bagian AppBar custom: tombol kembali
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 📏 Section Distance
            const Text("Distance (km)", style: TextStyle(fontSize: 16)),
            Text(
              _totalDistance.toStringAsFixed(2),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 🗺️ Section Map dengan margin & rounded corners
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 400,
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
              ),
            ),

            const SizedBox(height: 40),

            // ⏱️ Section Time
            const Text("Time", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // 🎮 Section Control Buttons (Stop - Play/Pause - Location)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ⏹️ Tombol STOP dengan outline
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      onPressed: _isRunning ? _stopRun : null,
                    ),
                  ),

                  // ⏯️ Tombol Play / Pause dengan warna light blue
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFB3E5FC), // light blue
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 70,
                      onPressed: _toggleRun,
                    ),
                  ),

                  // 📍 Tombol lokasi (go to current) dengan outline
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.location_on),
                      iconSize: 32,
                      onPressed: () async {
                        if (_positions.isNotEmpty) {
                          await _mapController?.animateCamera(
                            CameraUpdate.newLatLng(_positions.last),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
