import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      // 🟢 Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, true),
            _buildNavItem(Icons.analytics_outlined, false),
            _buildNavItem(Icons.person_outline_rounded, false),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 🌿 Top Decorative Header
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "কৃষি সহায়তা",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "আপনার ফসলের জন্য সেরা পরামর্শ",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 📱 Main Content Area
          Padding(
            padding: const EdgeInsets.only(top: 180, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔔 Premium Alert Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                      border: Border.all(color: Colors.red.shade100, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "জরুরি সতর্কতা: আজ স্প্রে করবেন না",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🎛 Feature Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.1,
                    children: [
                      _buildCuteCard("রোগ শনাক্তকরণ", Icons.camera_rounded, Colors.orange),
                      _buildCuteCard("আবহাওয়া", Icons.wb_cloudy_rounded, Colors.blue),
                      _buildCuteCard("পরামর্শ", Icons.face_retouching_natural, Colors.teal),
                      _buildCuteCard("জ্ঞানভান্ডার", Icons.auto_stories_rounded, Colors.brown),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 💡 Added Design: "Daily Tip" Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "আজকের টিপস",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.green.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 30),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "ধানের জমিতে সঠিক সময়ে ইউরিয়া সার প্রয়োগ করলে ফলন ২০% বৃদ্ধি পায়।",
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuteCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 55),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? Colors.green.shade700 : Colors.grey.shade400,
      size: 28,
    );
  }
}