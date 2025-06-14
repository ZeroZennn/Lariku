import 'package:flutter/material.dart';
import '../activities/activities_screen.dart';
import '../friendship/friends_screen.dart';
import '../ranking/ranking_screen.dart';
import '../run_tracker/run_screen.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Gunakan getter agar context bisa dipakai di dalam tombol!
  List<Widget> get _pages => [
    // --- INI HALAMAN HOME BARU SESUAI DESAIN GAMBAR ---
    ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Salam & Foto Profil DINAMIS
        FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
          builder: (context, snapshot) {
            String nama = 'Runner!';
            String? photoURL;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              nama = data['displayName'] ?? nama;
              photoURL = data['photoURL'];
            }
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 38,
                bottom: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Halo, $nama!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                  photoURL != null && photoURL.isNotEmpty
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(photoURL),
                        radius: 26,
                      )
                      : CircleAvatar(
                        backgroundColor: const Color(0xFFD7D7D7),
                        radius: 26,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                ],
              ),
            );
          },
        ),

        // 2. Personal Best (tetap sama, sudah dinamis)
        const PersonalBestCard(),

        // 3. Tombol Mulai Lari (tidak perlu diubah)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 24, top: 36, bottom: 28),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 2; // index 2 adalah "Run"
              });
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
              backgroundColor: const Color(0xFFD7D7D7),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mulai Lari",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 22),
              ],
            ),
          ),
        ),

        // 4. Suggested Goal DINAMIS
        FutureBuilder<QuerySnapshot?>(
          future: _fetchWeeklyRuns(),
          builder: (context, snapshot) {
            double goalDistance = 5.0;
            double totalDistance = 0.0;
            final data = snapshot.data;
            if (data != null) {
              for (var doc in data.docs) {
                final run = doc.data() as Map<String, dynamic>;
                totalDistance += (run['distance'] as num?)?.toDouble() ?? 0.0;
              }
            }
            return Container(
              color: const Color(0xFF686868),
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggested Goal",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_run,
                            size: 36,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 13),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$goalDistance Km per week",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "${totalDistance.toStringAsFixed(2)} Km / $goalDistance Km run",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFD7D7D7),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text("Set Goal"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    ),

    // --- END OF CUSTOM HOME PAGE ---
    const RankingScreen(),
    const RunScreen(),
    const FriendsScreen(),
    const ActivitiesScreen(),
  ];

  final List<String> _titles = [
    'Beranda',
    'Peringkat',
    'Lari',
    'Teman',
    'Aktivitas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Activities',
          ),
        ],
      ),
    );
  }
}

class PersonalBestCard extends StatefulWidget {
  const PersonalBestCard({Key? key}) : super(key: key);

  @override
  State<PersonalBestCard> createState() => _PersonalBestCardState();
}

class _PersonalBestCardState extends State<PersonalBestCard> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Container(
        color: const Color(0xFF686868),
        padding: const EdgeInsets.all(24),
        child: const Text(
          "Login untuk melihat personal best.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    final userId = currentUser.uid;

    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('activities')
              .doc(userId)
              .collection('runs')
              .orderBy('distance', descending: true)
              .limit(1)
              .get(),
      builder: (context, snapshot) {
        String distanceText = '--';
        String paceText = '--:-- /km';
        List<LatLng> routeCoordinates = [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFF686868),
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final double distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
          final int duration = (data['duration'] as num?)?.toInt() ?? 0;
          distanceText = "${distance.toStringAsFixed(2)} Km";
          paceText = _formatPace(distance, duration);

          // Ambil koordinat jika ada
          if (data['coordinates'] != null && data['coordinates'] is List) {
            final coordsList = data['coordinates'] as List<dynamic>;
            for (var coord in coordsList) {
              if (coord is Map) {
                final lat = (coord['lat'] as num?)?.toDouble();
                final lng = (coord['lng'] as num?)?.toDouble();
                if (lat != null && lng != null) {
                  routeCoordinates.add(LatLng(lat, lng));
                }
              }
            }
          }
        }
        return Container(
          color: const Color(0xFF686868),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 18,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Personal Best",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jarak",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              distanceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 36),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              paceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Map polyline section (atau icon jika tidak ada data)
              Container(
                width: double.infinity,
                height: 240,
                color: const Color(0xFFD7D7D7),
                alignment: Alignment.center,
                child:
                    routeCoordinates.length >= 2
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: routeCoordinates[0],
                              zoom: 16,
                            ),
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('best_run'),
                                color: Colors.blue,
                                width: 4,
                                points: routeCoordinates,
                              ),
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('start'),
                                position: routeCoordinates.first,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ),
                                infoWindow: const InfoWindow(title: 'Mulai'),
                              ),
                              Marker(
                                markerId: const MarkerId('end'),
                                position: routeCoordinates.last,
                                infoWindow: const InfoWindow(title: 'Selesai'),
                              ),
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            scrollGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            liteModeEnabled: true, // Lebih ringan
                            onMapCreated: (controller) async {
                              _mapController.complete(controller);
                              // Zoom agar semua jalur terlihat:
                              if (routeCoordinates.length >= 2) {
                                LatLngBounds bounds = _boundsFromLatLngList(
                                  routeCoordinates,
                                );
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                ); // tunggu sedikit
                                controller.animateCamera(
                                  CameraUpdate.newLatLngBounds(bounds, 24),
                                );
                              }
                            },
                          ),
                        )
                        : Icon(
                          Icons.map_outlined,
                          size: 74,
                          color: Colors.black,
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return '--:-- /km';
    final double totalSecondsPerKm = durationSeconds / distanceKm;
    if (totalSecondsPerKm.isInfinite ||
        totalSecondsPerKm.isNaN ||
        totalSecondsPerKm < 0) {
      return '--:-- /km';
    }
    final int minutesPerKm = totalSecondsPerKm ~/ 60;
    final int secondsRemainderPerKm = (totalSecondsPerKm % 60).round();
    return "$minutesPerKm:${secondsRemainderPerKm.toString().padLeft(2, '0')} /km";
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }
}

Future<QuerySnapshot?> _fetchWeeklyRuns() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Future.value(null);
  final uid = user.uid;
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return FirebaseFirestore.instance
      .collection('activities')
      .doc(uid)
      .collection('runs')
      .where('date', isGreaterThanOrEqualTo: weekStart)
      .where('date', isLessThan: weekEnd)
      .get();
}
