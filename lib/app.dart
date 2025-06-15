import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/run_tracker/run_summary_screen.dart';
import 'models/activity_model.dart'; 
import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/friend_provider.dart';

class RunTrackerApp extends StatelessWidget {
  const RunTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // MultiProvider harus di atas MaterialApp
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FriendProvider>(
          create: (context) => FriendProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousFriendProvider) => FriendProvider(auth),
        ),
      ],
      child: MaterialApp(
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
    ),
    );
  }
}
