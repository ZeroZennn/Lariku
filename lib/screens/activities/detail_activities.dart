import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDateTime(Timestamp ts) {
    try {
      return DateFormat(
        'EEEE, d MMMM yyyy, HH:mm:ss',
        'id_ID',
      ).format(ts.toDate());
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  static String formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return '--:-- /km';
    final double totalSecondsPerKm = durationSeconds / distanceKm;
    final int minutesPerKm = totalSecondsPerKm ~/ 60;
    final int secondsRemainderPerKm = (totalSecondsPerKm % 60).round();
    return "$minutesPerKm:${secondsRemainderPerKm.toString().padLeft(2, '0')} /km";
  }

  static String formatDuration(int durationSeconds) {
    final duration = Duration(seconds: durationSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }
}

class DetailActivitiesScreen extends StatelessWidget {
  final String runId;
  final String userId;

  const DetailActivitiesScreen({
    super.key,
    required this.runId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('activities')
                .doc(userId)
                .collection('runs')
                .doc(runId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data?.data() == null) {
            return const Center(child: Text("Gagal memuat detail aktivitas."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String runTitle = data['runTitle'] ?? 'Aktivitas Lari';
          final Timestamp timestamp = data['startTime'] ?? Timestamp.now();
          final double distanceKm =
              (data['distance'] as num?)?.toDouble() ?? 0.0;
          final int durationSeconds = (data['duration'] as num?)?.toInt() ?? 0;

          final List<LatLng> routeCoordinates = [];
          if (data['coordinates'] != null && data['coordinates'] is List) {
            for (var coord in data['coordinates']) {
              if (coord is Map) {
                final lat = (coord['lat'] as num?)?.toDouble();
                final lng = (coord['lng'] as num?)?.toDouble();
                if (lat != null && lng != null) {
                  routeCoordinates.add(LatLng(lat, lng));
                }
              }
            }
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header Salam & Profil Dinamis
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                    builder: (context, userSnapshot) {
                      String nama = 'Runner!';
                      String? photoURL;
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        nama = userData['displayName'] ?? nama;
                        photoURL = userData['photoURL'];
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 50,
                          bottom: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Detail Activities",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () =>
                                      Navigator.pushNamed(context, '/profile'),
                              child:
                                  photoURL != null && photoURL.isNotEmpty
                                      ? CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(photoURL),
                                      )
                                      : const CircleAvatar(
                                        backgroundColor: Color(0xFFD7D7D7),
                                        radius: 24,
                                        child: Icon(
                                          Icons.person,
                                          size: 28,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // 🔹 Map dengan padding + rounded corner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildMapView(routeCoordinates),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🔹 Info Detail Aktivitas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          runTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FormatUtils.formatDateTime(timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatInfo(
                              icon: Icons.place,
                              label: 'Jarak',
                              value: '${distanceKm.toStringAsFixed(2)} km',
                            ),
                            _StatInfo(
                              icon: Icons.timer_outlined,
                              label: 'Waktu',
                              value: FormatUtils.formatDuration(
                                durationSeconds,
                              ),
                            ),
                            _StatInfo(
                              icon: Icons.directions_run,
                              label: 'Pace',
                              value: FormatUtils.formatPace(
                                distanceKm,
                                durationSeconds,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        ); // atau gunakan pushReplacementNamed jika perlu
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text("Kembali"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.lightBlue.shade200,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Map View dengan Polyline dan Marker
  Widget _buildMapView(List<LatLng> routeCoordinates) {
    if (routeCoordinates.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text("Data rute tidak tersedia."),
      );
    }

    final LatLngBounds bounds = _boundsFromLatLngList(routeCoordinates);

    return SizedBox(
      height: 400,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: routeCoordinates.first,
          zoom: 15,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId('run_route'),
            color: Colors.blueAccent,
            width: 5,
            points: routeCoordinates,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId('start'),
            position: routeCoordinates.first,
            infoWindow: const InfoWindow(title: 'Mulai'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
          Marker(
            markerId: const MarkerId('end'),
            position: routeCoordinates.last,
            infoWindow: const InfoWindow(title: 'Selesai'),
          ),
        },
        onMapCreated: (controller) {
          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        },
      ),
    );
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

// 🔹 Widget Info Statistik (dengan icon)
class _StatInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
