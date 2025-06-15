import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ranking/ranking_screen.dart';
import '../screens/run_tracker/run_screen.dart';
import '../screens/run_tracker/run_summary_screen.dart';
import '../screens/friendship/friends_screen.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';


final Map<String, WidgetBuilder> appRoutes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  OnboardingScreen.routeName: (context) => const OnboardingScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  RankingScreen.routeName: (context) => const RankingScreen(),
  RunScreen.routeName: (context) => const RunScreen(),
  FriendsScreen.routeName: (context) => const FriendsScreen(),
  ActivitiesScreen.routeName: (context) => const ActivitiesScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  EditProfileScreen.routeName: (context) => const EditProfileScreen(),
};
