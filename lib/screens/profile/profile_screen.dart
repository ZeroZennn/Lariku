import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _notificationOn = true;

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '-';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profil Saya'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 68,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      (photoUrl == null || photoUrl.isEmpty)
                          ? const Icon(
                            Icons.person,
                            size: 62,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 18),
              // Nama
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              // Email
              Text(
                email,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 18),
              // Tombol Edit Profile
              SizedBox(
                width: 170,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: tambahkan edit profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Card Settings
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.09),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_none, size: 28),
                      title: const Text(
                        'Push Notification',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Switch(
                        value: _notificationOn,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _notificationOn = val;
                          });
                        },
                      ),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, size: 28),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // TODO: tambahkan change password
                      },
                    ),
                    const Divider(
                      height: 2,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.question_answer_outlined,
                        size: 28,
                      ),
                      title: const Text(
                        'FAQs',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // TODO: tambahkan FAQ
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 38),
              // Contact
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Text(
                      'if you have any other query you\ncan reach out to us.',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    SelectableText(
                      'lariku@gmail.com',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              // Logout button (optional: tambahkan di bawah)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
    if (shouldLogout == true) {
      _signOut(context);
    }
  }
}
