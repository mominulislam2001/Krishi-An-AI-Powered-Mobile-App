import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/disease_guidance_screen.dart';
import 'screens/disease_detection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';


void main() {
  runApp(const KrishiApp());
}

class KrishiApp extends StatelessWidget {
  const KrishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krishi',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash':   (context) => const SplashScreen(),
        '/login':    (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const HomeScreen(),
        '/disease': (context) =>  DiseaseGuidanceScreen(),
        '/detect': (context) => const DiseaseDetectionScreen(),
        '/profile':  (context) => const ProfileScreen(),
      },
    );
  }
}
