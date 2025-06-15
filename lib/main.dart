import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://zmmskhacszfveivxbrys.supabase.co', // Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbXNraGFjc3pmdmVpdnhicnlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMDI1MDQsImV4cCI6MjA2NTU3ODUwNH0.kxAeJH32FoehuFgpvicnuoxJ0ozo-CuU6bbris9QURo', // Public API Key
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ActivityProvider())],
      child: const RunTrackerApp(),
    ),
  );
}

void testFirestore() {
  FirebaseFirestore.instance.collection('debug').add({
    'timestamp': DateTime.now(),
    'message': 'Firebase is working!',
  });
}
