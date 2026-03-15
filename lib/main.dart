import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_reading_screen.dart';
import 'screens/analysis_screen.dart';
import 'providers/bp_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BPProvider(),
      child: MaterialApp(
        title: 'HeartSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add': (context) => const AddReadingScreen(),
          '/analytics': (context) => const AnalysisScreen(),
        },
      ),
    );
  }
}
