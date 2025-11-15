import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screen/admin/admin_dashboard.dart';
import 'screen/auth/login_screen.dart';
import 'screen/auth/splash_screen.dart';
import 'screen/user/user_dashboard.dart';
import 'providers/dashboard_provider.dart';
import 'providers/waste_provider.dart';
import 'providers/report_provider.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => WasteProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/user': (_) => const UserDashboard(),
      },
      home: const SplashScreen(),
    );
  }
}