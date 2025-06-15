import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_activities.dart';
import 'package:animate_do/animate_do.dart';

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

    return Column(
      children: [
        // Bagian Header - Salam dan Foto Profil Dinamis
        FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .get(),
          builder: (context, snapshot) {
            String nama = 'Runner!';
            String? photoURL;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              photoURL = data['photoURL'];
            }

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 90,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Teks salam
                  Text(
                    "My Activities",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF414141),
                    ),
                  ),

                  // Avatar pengguna
                  photoURL != null && photoURL.isNotEmpty
                      ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(photoURL),
                          radius: 26,
                        ),
                      )
                      : GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFD7D7D7),
                          radius: 26,
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),

        // Expanded untuk isi ListView aktivitas
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
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
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada aktivitas lari yang tersimpan.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final activities = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 30.0,
                ),
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
                  final Timestamp validTimestamp =
                      activityTimestamp ??
                      (activityData['date'] as Timestamp? ?? Timestamp.now());
                  final double distanceKm =
                      (activityData['distance'] as num?)?.toDouble() ?? 0.0;
                  final int durationSeconds =
                      (activityData['duration'] as num?)?.toInt() ?? 0;

                  return SlideInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 120 * index),
                    child: _ActivityItemCard(
                      runId: activityDoc.id,
                      userId: currentUser.uid,
                      userName: userName,
                      runTitle: runTitle,
                      timestamp: validTimestamp,
                      distanceKm: distanceKm,
                      durationSeconds: durationSeconds,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Komponen kartu aktivitas (Activity Card)
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

  // Format tanggal
  String _formatDateTime(Timestamp ts) {
    try {
      return DateFormat(
        'EEEE, d MMMM yyyy, HH:mm:ss',
        'id_ID',
      ).format(ts.toDate());
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  // Format pace
  String _formatPace() {
    if (distanceKm <= 0 || durationSeconds <= 0) return '--:-- /km';
    final double totalSecondsPerKm = durationSeconds / distanceKm;
    final int minutesPerKm = totalSecondsPerKm ~/ 60;
    final int secondsRemainderPerKm = (totalSecondsPerKm % 60).round();
    return "$minutesPerKm:${secondsRemainderPerKm.toString().padLeft(2, '0')} /km";
  }

  // Format durasi
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DetailActivitiesScreen(runId: runId, userId: userId),
          ),
        );
      },

      child: Card(
        // Warna background kartu diubah menjadi light blue
        color: Colors.lightBlue.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian atas kartu: avatar dan nama
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blue[400],
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(timestamp),
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // Judul aktivitas
              Text(
                runTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 18.0),

              // Statistik jarak, pace, dan durasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: 'Jarak',
                    value: '${distanceKm.toStringAsFixed(2)} km',
                  ),
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

// Widget kecil untuk menampilkan label dan value statistik
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.white70;

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
