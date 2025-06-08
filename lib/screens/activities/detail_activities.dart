import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// Helper untuk format data
class FormatUtils {
  static String formatDateTime(Timestamp ts) {
    try {
      return DateFormat('EEEE, d MMMM yyyy, HH:mm:ss', 'id_ID').format(ts.toDate());
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  static String formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return '--:-- /km';
    final double totalSecondsPerKm = durationSeconds / distanceKm;
    if (totalSecondsPerKm.isInfinite || totalSecondsPerKm.isNaN || totalSecondsPerKm < 0) {
      return '--:-- /km';
    }
    final int minutesPerKm = totalSecondsPerKm ~/ 60;
    final int secondsRemainderPerKm = (totalSecondsPerKm % 60).round();
    return "$minutesPerKm:${secondsRemainderPerKm.toString().padLeft(2, '0')} /km";
  }

  static String formatDuration(int durationSeconds) {
    if (durationSeconds <= 0) return '0s';
    final duration = Duration(seconds: durationSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('activities')
          .doc(userId)
          .collection('runs')
          .doc(runId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
          return const Center(child: Text("Gagal memuat detail aktivitas."));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // Parsing data
        final String runTitle = data['runTitle'] as String? ?? 'Aktivitas Lari';
        final Timestamp timestamp = data['startTime'] as Timestamp? ?? Timestamp.now();
        final double distanceKm = (data['distance'] as num?)?.toDouble() ?? 0.0;
        final int durationSeconds = (data['duration'] as num?)?.toInt() ?? 0;
        
        final List<LatLng> routeCoordinates = [];
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
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapView(routeCoordinates),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(runTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(FormatUtils.formatDateTime(timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatInfo(label: 'Jarak', value: '${distanceKm.toStringAsFixed(2)} km'),
                        _StatInfo(label: 'Waktu', value: FormatUtils.formatDuration(durationSeconds)),
                        _StatInfo(label: 'Pace', value: FormatUtils.formatPace(distanceKm, durationSeconds)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<LatLng> routeCoordinates) {
    if (routeCoordinates.isEmpty) {
      return Container(
        height: 350,
        alignment: Alignment.center,
        color: Colors.grey[200],
        child: const Text("Data rute tidak tersedia."),
      );
    }

    final LatLngBounds bounds = _boundsFromLatLngList(routeCoordinates);

    return SizedBox(
      height: 350,
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
          Marker(
            markerId: const MarkerId('end'),
            position: routeCoordinates.last,
            infoWindow: const InfoWindow(title: 'Selesai'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
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
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}

class _StatInfo extends StatelessWidget {
  final String label;
  final String value;

  const _StatInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}