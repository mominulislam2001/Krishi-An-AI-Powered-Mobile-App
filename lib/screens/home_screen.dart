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
          children: const [
            _HoverNavIcon(icon: Icons.home_rounded, isActive: true),
            _HoverNavIcon(icon: Icons.info_outline_rounded),
            _HoverNavIcon(icon: Icons.person_outline_rounded),
          ],
        ),
      ),

      body: Stack(
        children: [
          // 🌿 Header
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
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "আপনার ফসলের জন্য সেরা পরামর্শ",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // 📱 Content
          Padding(
            padding: const EdgeInsets.only(top: 180, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔔 Alert
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 20,
                        )
                      ],
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.notifications_active, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "জরুরি সতর্কতা: আজ স্প্রে করবেন না",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🎛 Feature Grid (HOVER ENABLED)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.1,
                    children: const [
                      HoverCard(title: "রোগ শনাক্তকরণ", icon: Icons.camera_rounded, color: Colors.orange),
                      HoverCard(title: "আবহাওয়া", icon: Icons.wb_cloudy_rounded, color: Colors.blue),
                      HoverCard(title: "পরামর্শ", icon: Icons.face_retouching_natural, color: Colors.teal),
                      HoverCard(title: "জ্ঞানভান্ডার", icon: Icons.auto_stories_rounded, color: Colors.brown),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 💡 Tip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "আজকের টিপস",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                        Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 25),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "ধানের জমিতে সঠিক সময়ে ইউরিয়া সার প্রয়োগ করলে ফলন ২০% বৃদ্ধি পায়।",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🧩 HOVER CARD
//////////////////////////////////////////////////////////////
class HoverCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;

  const HoverCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(isHovered ? 0.25 : 0.08),
              blurRadius: isHovered ? 25 : 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isHovered ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🔘 HOVER NAV ICON
//////////////////////////////////////////////////////////////
class _HoverNavIcon extends StatefulWidget {
  final IconData icon;
  final bool isActive;

  const _HoverNavIcon({
    required this.icon,
    this.isActive = false,
  });

  @override
  State<_HoverNavIcon> createState() => _HoverNavIconState();
}

class _HoverNavIconState extends State<_HoverNavIcon> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          widget.icon,
          size: 28,
          color: widget.isActive || isHovered
              ? Colors.green.shade700
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}
