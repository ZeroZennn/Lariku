import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Pastikan ini diimpor untuk UserModel

// AuthService bertanggung jawab untuk semua operasi otentikasi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Menggunakan instance GoogleSignIn
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Menggunakan _db untuk konsistensi

  // Stream untuk memantau perubahan status otentikasi pengguna
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Fungsi untuk mendaftar pengguna baru dengan email dan kata sandi
  // Juga menyimpan data pengguna ke koleksi 'users' di Firestore
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Pastikan menyimpan 'name' di sini
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'name': name, // Gunakan 'name' yang diberikan saat sign up
          'photoUrl': user.photoURL, // photoURL dari Firebase Auth (mungkin null)
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error during sign up: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return null;
    }
  }

  // Fungsi untuk masuk pengguna dengan email dan kata sandi
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error during sign in: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return null;
    }
  }

  // Fungsi untuk masuk dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Menggunakan _googleSignIn
      if (googleUser == null) {
        // Pengguna membatalkan proses masuk Google
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get(); // Menggunakan _db
        if (!userDoc.exists) {
          // Pastikan menyimpan 'name' dari displayName Google dan 'photoUrl'
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName, // Ambil dari displayName Google dan simpan sebagai 'name'
            'photoUrl': user.photoURL, // photoURL dari Google
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error during Google sign in: ${e.message}'); // Konsisten dengan error handling lain
      return null;
    } catch (e) {
      print('Unexpected error during Google sign in: $e');
      return null;
    }
  }

  // Fungsi untuk keluar dari akun pengguna saat ini
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Keluar dari Google Sign-In
      await _auth.signOut(); // Keluar dari Firebase Authentication
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Mendapatkan detail pengguna saat ini dari Firestore berdasarkan UID yang login
  Future<UserModel?> getCurrentUserFromFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(currentUser.uid).get(); // Menggunakan _db
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  // Mengambil detail pengguna berdasarkan ID dari Firestore
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get(); // Menggunakan _db
      if (doc.exists) {
        // Logika di UserModel.fromFirestore akan menangani 'name' atau 'displayName'
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
