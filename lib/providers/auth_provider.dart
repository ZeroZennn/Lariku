import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart'; // Import UserModel karena provider ini juga mengelola UserModel

// AuthProvider mengelola status otentikasi pengguna
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(); // Instance AuthService untuk interaksi dengan Firebase Auth
  User? _user; // Objek pengguna Firebase saat ini (dari FirebaseAuth)
  UserModel? _currentUserModel; // Objek UserModel kustom pengguna saat ini (dari Firestore)

  // Getter untuk objek pengguna Firebase. Digunakan untuk mengecek apakah user sudah login.
  User? get user => _user;

  // Getter untuk objek UserModel pengguna. Berisi detail profil dari Firestore.
  UserModel? get currentUserModel => _currentUserModel;

  // Konstruktor AuthProvider
  AuthProvider() {
    // Memantau perubahan status otentikasi dari Firebase
    // Ini memastikan _user dan _currentUserModel selalu up-to-date
    _authService.user.listen((user) async {
      _user = user; // Perbarui objek pengguna Firebase

      if (user != null) {
        // Jika pengguna masuk (tidak null), ambil data UserModel lengkap dari Firestore
        _currentUserModel = await _authService.getCurrentUserFromFirestore();
      } else {
        // Jika pengguna keluar (null), reset UserModel
        _currentUserModel = null;
      }
      notifyListeners(); // Beri tahu semua widget yang mendengarkan tentang perubahan ini
    });
  }

  // Fungsi untuk mendaftar pengguna baru dengan email dan kata sandi
  // Memanggil signUpWithEmailAndPassword dari AuthService
  // Mengembalikan null jika berhasil, string error jika gagal
  Future<String?> signUp(String email, String password, String name) async {
    User? user = await _authService.signUpWithEmailAndPassword(email, password, name);
    if (user != null) {
      // UserModel akan diupdate otomatis melalui listener di konstruktor
      return null; // Pendaftaran berhasil
    } else {
      return "Pendaftaran gagal. Periksa kembali email dan kata sandi Anda atau coba lagi."; // Pendaftaran gagal
    }
  }

  // Fungsi untuk masuk pengguna dengan email dan kata sandi
  // Memanggil signInWithEmailAndPassword dari AuthService
  // Mengembalikan null jika berhasil, string error jika gagal
  Future<String?> signIn(String email, String password) async {
    User? user = await _authService.signInWithEmailAndPassword(email, password);
    if (user != null) {
      // UserModel akan diupdate otomatis melalui listener di konstruktor
      return null; // Masuk berhasil
    } else {
      return "Login gagal. Periksa kembali email dan kata sandi Anda."; // Masuk gagal
    }
  }

  // Fungsi untuk masuk dengan Google
  // Memanggil signInWithGoogle dari AuthService
  // Mengembalikan null jika berhasil, string error jika gagal
  Future<String?> signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      // UserModel akan diupdate otomatis melalui listener di konstruktor
      return null; // Masuk dengan Google berhasil
    } else {
      return "Login dengan Google gagal."; // Masuk dengan Google gagal
    }
  }

  // Fungsi untuk keluar dari akun pengguna
  // Memanggil signOut dari AuthService
  Future<void> signOut() async {
    await _authService.signOut(); // Panggil fungsi signOut dari AuthService
    // _user dan _currentUserModel akan direset otomatis melalui listener
  }
}