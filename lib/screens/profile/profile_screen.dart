import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  ProfileScreen({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn
        .signOut(); // <--- penting untuk reset akun Google terakhir
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '-';
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child:
                    photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
