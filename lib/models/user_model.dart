import 'package:cloud_firestore/cloud_firestore.dart';

// UserModel class untuk merepresentasikan data pengguna
class UserModel {
  final String uid; // User ID
  final String email; // Email pengguna
  final String name; // Nama pengguna
  final String? photoUrl; // URL foto profil (opsional)

  // Konstruktor untuk UserModel
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  // Factory constructor untuk membuat instance UserModel dari DocumentSnapshot Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Mengambil data dari dokumen
    return UserModel(
      uid: doc.id, // Menggunakan ID dokumen sebagai UID
      email: data['email'] ?? '', // Mengambil email, default string kosong jika null
      // Gunakan 'name' atau 'displayName' atau default 'No Name' jika tidak ada
      name: data['name'] ?? data['displayName'] ?? 'No Name', 
      photoUrl: data['photoUrl'] ?? data['photoURL'], // Tangani 'photoUrl' atau 'photoURL'
    );
  }

  // Metode untuk mengkonversi instance UserModel ke format JSON (Map) untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
