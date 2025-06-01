import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _checkAuthStatus);
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika user masih login, arahkan ke Home
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      // Jika belum login, arahkan ke onboarding
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/wind.json', // pastikan path benar
          width: 1000,
          height: 1000,
        ),
      ),
    );
  }
}
