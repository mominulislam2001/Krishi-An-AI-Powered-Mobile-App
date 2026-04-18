import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/disease_guidance_screen.dart';
import 'screens/disease_detection_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/advisory': (context) => const AdvisoryScreen(),
        '/disease': (context) => const DiseaseGuidanceScreen(),
        '/detect': (context) => const DiseaseDetectionScreen(),
      },
    );
  }
}
