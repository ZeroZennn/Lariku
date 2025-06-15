import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan di pubspec.yaml
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _email;
  String? _photoURL;
  File? _pickedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    _email = user?.email ?? '';

    // Get name from Firestore or displayName
    final uid = user?.uid;
    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();
      if (data != null && data['displayName'] != null) {
        _nameController.text = data['displayName'];
      } else if (user?.displayName != null) {
        _nameController.text = user!.displayName!;
      }
      setState(() {
        _photoURL = data?['photoURL'] ?? user?.photoURL;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file, String uid) async {
  final storage = Supabase.instance.client.storage.from('profile-photos');
  final fileName = '$uid.jpg';
  // Upload ke Supabase Storage
  final res = await storage.upload(fileName, file);
  if (res.isEmpty) return null;

  // Generate public URL (atau gunakan getPublicUrl jika bucketnya public)
  final publicURL = storage.getPublicUrl(fileName);
  return publicURL;
}

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    String? photoURL = _photoURL;

    // Upload foto kalau dipilih
    if (_pickedImage != null && uid != null) {
      photoURL = await _uploadImage(_pickedImage!, uid);
      await user?.updatePhotoURL(photoURL);
    }

    // Update nama di auth dan Firestore
    await user?.updateDisplayName(_nameController.text);

    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'displayName': _nameController.text,
        'photoURL': photoURL,
      });
    }

    setState(() => _loading = false);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (_photoURL != null && _photoURL!.isNotEmpty)
                                  ? NetworkImage(_photoURL!)
                                  : null as ImageProvider?,
                          child: (_pickedImage == null && (_photoURL == null || _photoURL!.isEmpty))
                              ? const Icon(Icons.person, size: 62, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt, size: 26),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nama
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            validator: (val) => (val == null || val.trim().isEmpty) ? "Nama tidak boleh kosong" : null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                              hintText: 'Nama',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade400, width: 2.5),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.1),
                          ),
                          const SizedBox(height: 16),
                          // Email (disable)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'E-Mail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: _email ?? '-',
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        child: const Text("SAVE"),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
