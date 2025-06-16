import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart'; // File ini diasumsikan mendefinisikan kelas RunActivity
import '../models/user_model.dart'; // Import UserModel

// FirestoreService bertanggung jawab untuk semua operasi database Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Operasi terkait Aktivitas Lari ---

  // Menyimpan data aktivitas lari ke Firestore
  // Menggunakan RunActivity yang telah diimpor
  Future<void> saveActivity(RunActivity activity, String userId) async { // Menggunakan RunActivity
    try {
      await _firestore
          .collection('activities')
          .doc(userId)
          .collection('runs')
          .add(activity.toMap()); // Gunakan toMap() dari RunActivity
      print('FirestoreService: Activity saved successfully for user $userId.');
    } catch (e) {
      print('FirestoreService: Failed to save activity: $e');
      throw Exception('Gagal menyimpan aktivitas: $e');
    }
  }
  
  // --- Operasi terkait Pertemanan ---

  // Mengirim permintaan pertemanan
  // Menambahkan status 'pending' pada permintaan baru
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    print('FirestoreService: Sending request from $fromUserId to $toUserId');
    await _firestore.collection('friend_requests').add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': FieldValue.serverTimestamp(), // Timestamp permintaan
      'status': 'pending', // Status awal permintaan adalah 'pending'
    });
    print('FirestoreService: Request added to Firestore with status pending.');
  }

  // Menerima permintaan pertemanan
  // Mengubah status permintaan menjadi 'accepted' dan menambahkan ke subkoleksi teman
  Future<void> acceptFriendRequest(String requestId, String fromUserId, String toUserId) async {
    print('FirestoreService: Accepting request ID $requestId from $fromUserId by $toUserId');
    
    // 1. Ubah status permintaan di koleksi 'friend_requests' menjadi 'accepted'
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(), // Optional: catat waktu penerimaan
    });
    print('FirestoreService: Request status updated to accepted.');

    // 2. Tambahkan 'fromUserId' ke subkoleksi teman 'toUserId'
    // Struktur Firestore: friends/{toUserId}/friends/{fromUserId}
    await _firestore
        .collection('friends')
        .doc(toUserId)
        .collection('friends')
        .doc(fromUserId)
        .set({'acceptedAt': FieldValue.serverTimestamp()});
    print('FirestoreService: Added $fromUserId to $toUserId friends subcollection.');

    // 3. Tambahkan 'toUserId' ke subkoleksi teman 'fromUserId'
    // Struktur Firestore: friends/{fromUserId}/friends/{toUserId}
    await _firestore
        .collection('friends')
        .doc(fromUserId)
        .collection('friends')
        .doc(toUserId)
        .set({'acceptedAt': FieldValue.serverTimestamp()});
    print('FirestoreService: Added $toUserId to $fromUserId friends subcollection.');
  }

  // Menolak permintaan pertemanan
  // Mengubah status permintaan menjadi 'rejected'
  Future<void> rejectFriendRequest(String requestId) async {
    print('FirestoreService: Rejecting request ID $requestId');
    // Ubah status permintaan di koleksi 'friend_requests' menjadi 'rejected'
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(), // Optional: catat waktu penolakan
    });
    print('FirestoreService: Request status updated to rejected.');
  }

  // Membatalkan permintaan pertemanan yang telah dikirim
  // Mengubah status permintaan menjadi 'cancelled'
  Future<void> cancelSentFriendRequest(String requestId) async {
    print('FirestoreService: Cancelling sent request ID $requestId');
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
    print('FirestoreService: Sent request status updated to cancelled.');
  }

  // Mendapatkan stream permintaan pertemanan yang diterima oleh pengguna saat ini
  // Hanya ambil permintaan yang statusnya 'pending'
  Stream<QuerySnapshot> getFriendRequestsToUser(String userId) {
    print('FirestoreService: Listening for pending requests to $userId');
    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending') // Filter hanya yang berstatus 'pending'
        .snapshots();
  }

  // Mendapatkan stream permintaan pertemanan yang dikirim oleh pengguna saat ini
  // Hanya ambil permintaan yang statusnya 'pending'
  Stream<QuerySnapshot> getSentFriendRequests(String userId) {
    print('FirestoreService: Listening for pending sent requests from $userId');
    return _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending') // Filter hanya yang berstatus 'pending'
        .snapshots();
  }

  // Mendapatkan stream daftar teman untuk pengguna tertentu
  Stream<QuerySnapshot> getFriends(String userId) {
    print('FirestoreService: Listening for friends of $userId');
    return _firestore
        .collection('friends')
        .doc(userId)
        .collection('friends')
        .snapshots();
  }

  // Mencari pengguna berdasarkan nama atau email
  Future<List<UserModel>> searchUsers(String query) async {
    print('FirestoreService: Searching users with query "$query"');
    List<UserModel> users = [];
    if (query.isEmpty) return users;

    // Jika query mengandung '@', diasumsikan itu adalah email dan dicari berdasarkan email
    if (query.contains('@')) {
      QuerySnapshot emailSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: query)
          .get();
      for (var doc in emailSnapshot.docs) {
        users.add(UserModel.fromFirestore(doc));
      }
    } else {
      // Jika tidak mengandung '@', diasumsikan itu adalah nama dan dicari berdasarkan nama (prefix)
      QuerySnapshot nameSnapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      for (var doc in nameSnapshot.docs) {
        users.add(UserModel.fromFirestore(doc));
      }
      // Opsi: Jika ingin juga mencari email bahkan jika tidak ada '@', bisa tambahkan:
      // QuerySnapshot emailAsNameSearch = await _firestore
      //    .collection('users')
      //    .where('email', isGreaterThanOrEqualTo: query)
      //    .where('email', isLessThanOrEqualTo: query + '\uf8ff')
      //    .get();
      // for (var doc in emailAsNameSearch.docs) {
      //   if (!users.any((user) => user.uid == doc.id)) {
      //     users.add(UserModel.fromFirestore(doc));
      //   }
      // }
    }
    
    print('FirestoreService: Search found ${users.length} users.');
    return users;
  }

  // Memeriksa apakah dua pengguna sudah berteman
  Future<bool> areFriends(String userId1, String userId2) async {
    final doc = await _firestore.collection('friends').doc(userId1).collection('friends').doc(userId2).get();
    print('FirestoreService: Are $userId1 and $userId2 friends? ${doc.exists}');
    return doc.exists;
  }

  // Memeriksa apakah pengguna 'fromUserId' sudah mengirim permintaan 'pending' ke 'toUserId'
  Future<bool> hasSentFriendRequest(String fromUserId, String toUserId) async {
    final querySnapshot = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending') // Hanya periksa permintaan yang masih pending
        .get();
    print('FirestoreService: Has $fromUserId sent PENDING request to $toUserId? ${querySnapshot.docs.isNotEmpty}');
    return querySnapshot.docs.isNotEmpty;
  }

  // Memeriksa apakah pengguna 'toUserId' sudah menerima permintaan 'pending' dari 'fromUserId'
  Future<bool> hasReceivedFriendRequest(String fromUserId, String toUserId) async {
    final querySnapshot = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: toUserId) // Pengirim adalah toUserId di sini
        .where('toUserId', isEqualTo: fromUserId) // Penerima adalah fromUserId di sini
        .where('status', isEqualTo: 'pending') // Hanya periksa permintaan yang masih pending
        .get();
    print('FirestoreService: Has $fromUserId received PENDING request from $toUserId? ${querySnapshot.docs.isNotEmpty}');
    return querySnapshot.docs.isNotEmpty;
  }

  // Mengambil detail pengguna berdasarkan ID dari Firestore
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        // Logika di UserModel.fromFirestore akan menangani 'name'/'displayName'
        print('FirestoreService: User found for UID: $uid - Data: ${doc.data()}'); // Tambahkan print data mentah
        return UserModel.fromFirestore(doc);
      } else {
        print('FirestoreService: User NOT found for UID: $uid');
      }
    } catch (e) {
      print('FirestoreService: ERROR getting user by ID ($uid): $e');
    }
    return null;
  }
}
