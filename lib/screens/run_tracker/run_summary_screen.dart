import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/activity_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';

class RunSummaryScreen extends StatelessWidget {
  static const routeName = '/run-summary';

  final RunActivity activity;

  const RunSummaryScreen({super.key, required this.activity});

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final formattedDuration = formatDuration(
      Duration(seconds: activity.duration),
    );
    final distance = activity.distance.toStringAsFixed(2);
    String formatPace(double paceInSeconds) {
      final minutes = paceInSeconds ~/ 60;
      final seconds = (paceInSeconds % 60).round();
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }

    final pace = formatPace(activity.pace);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    activity.coordinates.first['lat']!,
                    activity.coordinates.first['lng']!,
                  ),
                  zoom: 15,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.blue,
                    width: 5,
                    points:
                        activity.coordinates
                            .map(
                              (coord) => LatLng(coord['lat']!, coord['lng']!),
                            )
                            .toList(),
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: LatLng(
                      activity.coordinates.first['lat']!,
                      activity.coordinates.first['lng']!,
                    ),
                    infoWindow: const InfoWindow(title: 'Start'),
                  ),
                  Marker(
                    markerId: const MarkerId('end'),
                    position: LatLng(
                      activity.coordinates.last['lat']!,
                      activity.coordinates.last['lng']!,
                    ),
                    infoWindow: const InfoWindow(title: 'End'),
                  ),
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDuration,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Duration'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.location_on),
                        Text(
                          '$distance km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Distance'),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.timer),
                        Text(
                          '$pace/km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Pace'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Discard',
                        color: Colors.pinkAccent,
                        icon: Icons.delete,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        color: Colors.lightBlueAccent,
                        icon: Icons.save,
                        onPressed: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          print('Saving activity for user: $userId');

                          if (userId != null) {
                            if (activity.distance <= 0 ||
                                activity.pace.isNaN ||
                                activity.pace.isInfinite ||
                                activity.coordinates.isEmpty ||
                                activity.coordinates.any(
                                  (coord) =>
                                      coord['lat'] == null ||
                                      coord['lng'] == null,
                                )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data aktivitas tidak valid."),
                                ),
                              );
                              return;
                            }

                            try {
                              final data = activity.toMap();
                              print("Activity to be saved: $data");

                              await FirestoreService().saveActivity(
                                activity,
                                userId,
                              );
                              print('Activity saved successfully');

                              Navigator.pushReplacementNamed(context, '/home');
                            } catch (e) {
                              print('Error saving activity: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Gagal menyimpan aktivitas: $e",
                                  ),
                                ),
                              );
                            }
                          } else {
                            print("User not authenticated");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User tidak terautentikasi."),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
