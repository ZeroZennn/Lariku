import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveActivity(RunActivity activity, String userId) async {
    try {
      await _firestore
          .collection('activities')
          .doc(userId)
          .collection('runs')
          .add(activity.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan aktivitas: $e');
    }
  }
}
