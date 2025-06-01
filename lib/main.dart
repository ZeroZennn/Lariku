import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RunTrackerApp());
}

void testFirestore() {
  FirebaseFirestore.instance.collection('debug').add({
    'timestamp': DateTime.now(),
    'message': 'Firebase is working!',
  });
}
