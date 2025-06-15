import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Pastikan menyimpan 'name' di sini
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'name': name, // Pastikan ini 'name'
          'photoUrl': user.photoURL,
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

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
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
        DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // Pastikan menyimpan 'name' dan gunakan user.displayName
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName, // Ambil dari displayName Google
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error during Google sign in: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during Google sign in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  Future<UserModel?> getCurrentUserFromFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        // Logika di UserModel.fromFirestore akan menangani 'name'
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
