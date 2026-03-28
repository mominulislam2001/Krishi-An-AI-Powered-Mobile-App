import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/advisory_screen.dart';

void main() {
  runApp(const KrishiApp());
}

class KrishiApp extends StatelessWidget {
  const KrishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krishi Sheba',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/advisory': (context) => AdvisoryScreen(),
      },
    );
  }
}
