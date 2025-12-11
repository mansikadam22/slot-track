import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splashscreeen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => const SplashScreen(),
  '/home': (context) => const HomeScreen(),
};