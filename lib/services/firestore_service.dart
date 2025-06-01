import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRunData({
    required String userId,
    required DateTime startTime,
    required Duration duration,
    required double distance,
    required List<Map<String, double>> coordinates,
  }) async {
    final runData = {
      'date': Timestamp.now(),
      'startTime': Timestamp.fromDate(startTime),
      'duration': duration.inSeconds,
      'distance': distance,
      'coordinates': coordinates,
    };

    await _db
        .collection('activities')
        .doc(userId)
        .collection('runs')
        .add(runData);
  }
}
