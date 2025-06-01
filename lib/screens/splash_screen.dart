// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../routes/app_routes.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(child: Lottie.asset('assets/lottie/wind.json', width: 500)),
//     );
//   }
// }
