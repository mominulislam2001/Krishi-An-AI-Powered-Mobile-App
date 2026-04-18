import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Krishi  — Animated Splash / Loading Screen
// Matches the app's green theme; auto-navigates to /login after 3.5 s
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo scale + fade
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Subtitle slide-up
  late final AnimationController _textCtrl;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  // Rotating leaf ring
  late final AnimationController _ringCtrl;

  // Progress bar
  late final AnimationController _progressCtrl;
  late final Animation<double> _progress;

  // Floating particles
  late final AnimationController _particleCtrl;

  // Bottom tagline
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();

    // ── Logo ─────────────────────────────────────────────────────────────────
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoFade =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0, 0.5, curve: Curves.easeIn)));

    // ── Subtitle text ────────────────────────────────────────────────────────
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textFade =
        Tween<double>(begin: 0, end: 1).animate(_textCtrl);

    // ── Ring rotation ────────────────────────────────────────────────────────
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    // ── Progress bar ─────────────────────────────────────────────────────────
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800));
    _progress =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
            parent: _progressCtrl, curve: Curves.easeInOut));

    // ── Floating particles ───────────────────────────────────────────────────
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    // ── Bottom tagline ───────────────────────────────────────────────────────
    _tagCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _tagFade =
        Tween<double>(begin: 0, end: 1).animate(_tagCtrl);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    _progressCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _tagCtrl.forward();
    // Navigate after loading completes
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _ringCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade900,
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Subtle curved wave at bottom ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 200,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ── Floating particles ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(_particleCtrl.value),
            ),
          ),

          // ── Rotating leaf ring ───────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) => Transform.rotate(
                angle: _ringCtrl.value * 2 * pi,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: _LeafRingPainter()),
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo icon ──────────────────────────────────────────────
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: _buildLogoWidget(),
                  ),
                ),

                const SizedBox(height: 28),

                // ── App name ───────────────────────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: const Text(
                    "কৃষি",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle slide-up ──────────────────────────────────────
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          "Krishi",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 1.5,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "আপনার ফসলের জন্য সেরা পরামর্শ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ── Feature pills ──────────────────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _FeaturePill(icon: Icons.camera_alt_rounded,     label: "রোগ শনাক্তকরণ"),
                        _FeaturePill(icon: Icons.wb_cloudy_rounded,       label: "আবহাওয়া"),
                        _FeaturePill(icon: Icons.water_drop_rounded,      label: "বৃষ্টির পূর্বাভাস"),
                        _FeaturePill(icon: Icons.recommend_rounded,       label: "কৃষি পরামর্শ"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // ── Loading progress bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (_, __) => Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 6,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _loadingLabel(_progress.value),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom tagline ───────────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _tagFade,
              child: Column(
                children: [
                  Text(
                    "Powered by Anthropic Claude AI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "© 2025 কৃষি সহায়তা",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo widget ─────────────────────────────────────────────────────────
  Widget _buildLogoWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Inner white circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade900.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Phone icon (background)
              Positioned(
                child: Icon(
                  Icons.smartphone_rounded,
                  size: 70,
                  color: Colors.green.shade800,
                ),
              ),
              // Leaf overlay
              Positioned(
                bottom: 22,
                right: 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              // Search icon
              Positioned(
                top: 22,
                left: 18,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _loadingLabel(double v) {
    if (v < 0.3) return "অ্যাপ শুরু হচ্ছে...";
    if (v < 0.6) return "তথ্য লোড হচ্ছে...";
    if (v < 0.9) return "আবহাওয়া ডেটা আনা হচ্ছে...";
    return "প্রস্তুত!";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature pill widget
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rotating leaf ring painter
// ─────────────────────────────────────────────────────────────────────────────
class _LeafRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    const count = 8;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 6;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating particle painter
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  static final _rng = Random(42);
  static final List<_Particle> _particles = List.generate(
    18,
    (_) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      r: 2 + _rng.nextDouble() * 4,
      speed: 0.1 + _rng.nextDouble() * 0.3,
      phase: _rng.nextDouble(),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    for (final p in _particles) {
      final dy = ((t * p.speed + p.phase) % 1.0);
      final y = (p.y - dy + 1) % 1.0;
      canvas.drawCircle(Offset(p.x * size.width, y * size.height), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  final double x, y, r, speed, phase;
  _Particle(
      {required this.x,
      required this.y,
      required this.r,
      required this.speed,
      required this.phase});
}

// ─────────────────────────────────────────────────────────────────────────────
// Wave clipper for bottom decoration
// ─────────────────────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 60);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 40);
    path.quadraticBezierTo(size.width * 0.75, 80, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
