import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/run_tracker/run_summary_screen.dart';
import 'models/activity_model.dart'; // pastikan ini sesuai path model RunActivity kamu

class RunTrackerApp extends StatelessWidget {
  const RunTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: SplashScreen.routeName,
      routes: appRoutes,
      onGenerateRoute: (settings) {
        // Tangani route yang butuh parameter
        if (settings.name == RunSummaryScreen.routeName) {
          final activity = settings.arguments as RunActivity;
          return MaterialPageRoute(
            builder: (context) => RunSummaryScreen(activity: activity),
          );
        }

        // Fallback (optional)
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
