import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

class RunTrackerApp extends StatelessWidget {
  const RunTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: SplashScreen.routeName,
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
