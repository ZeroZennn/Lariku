import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_activities.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});
  static const String routeName = '/activities';

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          "Silakan login untuk melihat riwayat aktivitas Anda.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final String currentUserId = currentUser.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .doc(currentUserId)
          .collection('runs')
          .orderBy('startTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Terjadi kesalahan saat memuat data.\nError: ${snapshot.error}',
            textAlign: TextAlign.center,
          ));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            'Belum ada aktivitas lari yang tersimpan.',
            style: TextStyle(fontSize: 16),
          ));
        }

        final activities = snapshot.data!.docs;

        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activityDoc = activities[index];
            final activityData =
                activityDoc.data() as Map<String, dynamic>? ?? {};

            final String userName =
                activityData['userName'] as String? ?? 'Pengguna';
            final String runTitle =
                activityData['runTitle'] as String? ?? 'Aktivitas Lari';
            final Timestamp? activityTimestamp =
                activityData['startTime'] as Timestamp?;
            final Timestamp validTimestamp = activityTimestamp ??
                (activityData['date'] as Timestamp? ?? Timestamp.now());
            final double distanceKm =
                (activityData['distance'] as num?)?.toDouble() ?? 0.0;
            final int durationSeconds =
                (activityData['duration'] as num?)?.toInt() ?? 0;

            return _ActivityItemCard(
              runId: activityDoc.id,
              userId: currentUserId,
              userName: userName,
              runTitle: runTitle,
              timestamp: validTimestamp,
              distanceKm: distanceKm,
              durationSeconds: durationSeconds,
            );
          },
        );
      },
    );
  }
}

class _ActivityItemCard extends StatelessWidget {
  final String runId;
  final String userId;
  final String userName;
  final String runTitle;
  final Timestamp timestamp;
  final double distanceKm;
  final int durationSeconds;

  const _ActivityItemCard({
    super.key,
    required this.runId,
    required this.userId,
    required this.userName,
    required this.runTitle,
    required this.timestamp,
    required this.distanceKm,
    required this.durationSeconds,
  });

  String _formatDateTime(Timestamp ts) {
    try {
      return DateFormat('EEEE, d MMMM yyyy, HH:mm:ss', 'id_ID')
          .format(ts.toDate());
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String _formatPace() {
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

  String _formatDuration() {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Logika navigasi yang benar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Detail Aktivitas"),
                  centerTitle: true,
                  // Atur style AppBar ini agar sama dengan AppBar di HomeScreen
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
                body: DetailActivitiesScreen(
                  runId: runId,
                  userId: userId,
                ),
              );
            },
          ),
        );
      },
      child: Card(
        color: const Color(0xFF2C2C2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[600],
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(timestamp),
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Text(
                runTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 18.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(label: 'Jarak', value: '${distanceKm.toStringAsFixed(2)} km'),
                  _StatItem(label: 'Pace', value: _formatPace()),
                  _StatItem(label: 'Waktu', value: _formatDuration()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.grey[400]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}