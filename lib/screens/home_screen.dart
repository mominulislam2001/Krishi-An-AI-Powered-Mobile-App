import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'disease_guidance_screen.dart';
import 'preventive_screen.dart';
import 'profile_screen.dart';
import '../models/auth_store.dart';

class WeatherData {
  final double tempC;
  final double humidity;
  final double rainMm;
  final String condition;
  final String description;
  final String cityName;
  final int windSpeed;

  WeatherData({
    required this.tempC,
    required this.humidity,
    required this.rainMm,
    required this.condition,
    required this.description,
    required this.cityName,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      tempC:       (json['main']['temp'] as num).toDouble() - 273.15,
      humidity:    (json['main']['humidity'] as num).toDouble(),
      rainMm:      json['rain'] != null
          ? (json['rain']['1h'] as num? ?? 0).toDouble()
          : 0.0,
      condition:   json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      cityName:    json['name'] as String,
      windSpeed:
          (((json['wind']['speed'] as num).toDouble()) * 3.6).round(),
    );
  }

  String? get alertMessage {
    if (rainMm > 0.5)     return "বৃষ্টি হচ্ছে: আজ স্প্রে করবেন না";
    if (humidity > 85)  return "অতিরিক্ত আর্দ্রতা: ছত্রাকের ঝুঁকি বেশি";
    if (tempC > 38)     return "তাপমাত্রা অনেক বেশি: সেচ দেওয়া এড়ান";
    if (windSpeed > 40) return "তীব্র বাতাস: আজ স্প্রে করা ঠিক হবে না";
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather service
// ─────────────────────────────────────────────────────────────────────────────
class WeatherService {
  static const _apiKey = '9ec4b448a3ab03a018d2d72cdd134bfa';

  static Future<WeatherData> fetchByCity(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    }
    throw Exception('আবহাওয়া তথ্য পাওয়া যায়নি (${response.statusCode})');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? _weather;
  bool _loadingWeather = true;
  String? _weatherError;

  static const _city = 'Dhaka';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() { _loadingWeather = true; _weatherError = null; });
    try {
      final data = await WeatherService.fetchByCity(_city);
      setState(() { _weather = data; _loadingWeather = false; });
    } catch (e) {
      setState(() { _weatherError = 'আবহাওয়া লোড হয়নি'; _loadingWeather = false; });
    }
  }

  IconData _weatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':        return Icons.wb_sunny_rounded;
      case 'clouds':       return Icons.wb_cloudy_rounded;
      case 'rain':
      case 'drizzle':      return Icons.grain_rounded;
      case 'thunderstorm': return Icons.flash_on_rounded;
      case 'snow':         return Icons.ac_unit_rounded;
      case 'mist':
      case 'haze':
      case 'fog':          return Icons.cloud_rounded;
      default:             return Icons.wb_cloudy_outlined;
    }
  }

  // ── Weather card ────────────────────────────────────────────────────────────
  Widget _buildWeatherCard() {
    if (_loadingWeather) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 20),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (_weatherError != null || _weather == null) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(_weatherError ?? 'আবহাওয়া তথ্য নেই',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            TextButton(
              onPressed: _loadWeather,
              child: const Text("পুনরায় চেষ্টা", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    final w = _weather!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City + refresh
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(w.cityName,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: _loadWeather,
                child: const Icon(Icons.refresh, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Temp + icon + description
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${w.tempC.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_weatherIcon(w.condition), color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(w.description,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weatherStat(
                  icon: Icons.water_drop_outlined,
                  label: "আর্দ্রতা",
                  value: "${w.humidity.toInt()}%"),
              _weatherStat(
                  icon: Icons.grain_rounded,
                  label: "বৃষ্টি",
                  value: "${w.rainMm.toStringAsFixed(1)} mm"),
              _weatherStat(
                  icon: Icons.air_rounded,
                  label: "বাতাস",
                  value: "${w.windSpeed} km/h"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  // ── Alert banner ────────────────────────────────────────────────────────────
  Widget _buildAlertBanner() {
  // Don't show anything while weather is still loading
  if (_loadingWeather) return const SizedBox.shrink();

  final String? alertMsg = _weather?.alertMessage;
  final bool hasAlert = alertMsg != null;

  // Pick color/icon based on which threshold was triggered
  final Color borderColor;
  final Color bgShadowColor;
  final Color iconBg;
  final Color textColor;
  final IconData icon;

  if (!hasAlert) {
    // ✅ All clear — green
    borderColor   = Colors.green.shade200;
    bgShadowColor = Colors.green;
    iconBg        = Colors.green.shade600;
    textColor     = Colors.green.shade800;
    icon          = Icons.check_circle_outline_rounded;
  } else if (_weather!.rainMm > 0) {
    // 🌧 Rain — blue
    borderColor   = Colors.blue.shade200;
    bgShadowColor = Colors.blue;
    iconBg        = Colors.blue.shade600;
    textColor     = Colors.blue.shade800;
    icon          = Icons.grain_rounded;
  } else if (_weather!.humidity > 85) {
    // 💧 High humidity — orange
    borderColor   = Colors.orange.shade200;
    bgShadowColor = Colors.orange;
    iconBg        = Colors.orange.shade700;
    textColor     = Colors.orange.shade900;
    icon          = Icons.water_drop_rounded;
  } else if (_weather!.tempC > 38) {
    // 🌡 High temp — deep orange
    borderColor   = Colors.deepOrange.shade200;
    bgShadowColor = Colors.deepOrange;
    iconBg        = Colors.deepOrange.shade600;
    textColor     = Colors.deepOrange.shade900;
    icon          = Icons.thermostat_rounded;
  } else {
    // 💨 High wind — purple
    borderColor   = Colors.purple.shade200;
    bgShadowColor = Colors.purple;
    iconBg        = Colors.purple.shade600;
    textColor     = Colors.purple.shade900;
    icon          = Icons.air_rounded;
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: bgShadowColor.withOpacity(0.08), blurRadius: 12),
      ],
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: iconBg,
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            hasAlert ? alertMsg : "আবহাওয়া অনুকূল: কৃষিকাজ করার উপযুক্ত সময়",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = AuthStore.currentUser;
    final userName = (user?['name'] as String? ?? '').isNotEmpty
        ? user!['name'] as String
        : 'কৃষক';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),

      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 55,
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
            const _HoverNavIcon(icon: Icons.home_rounded, isActive: true),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // ✅ Pass the already-fetched weather so the corrective
                  //    screen doesn't make a second API call.
                  builder: (_) => PreventiveScreen(weather: _weather),
                ),
              ),
              child: const _HoverNavIcon(icon: Icons.info_outline_rounded),
            ),
           GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: const _HoverNavIcon(icon: Icons.person_outline_rounded),
            ),
          ],
        ),
      ),

      // ── Body: SafeArea → Column (no scroll ever) ────────────────────────────
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────────────────────
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(255, 72, 164, 77), const Color.fromARGB(255, 91, 197, 94)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Krishi_trans_logo.png',
                            height: 65,
                            width: 58,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "কৃষি",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "আপনার ফসলের জন্য সেরা পরামর্শ",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            

            // ── All cards expand to fill remaining space exactly ─────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Weather card (fixed intrinsic height)
                    _buildWeatherCard(),

                    const SizedBox(height: 10),

                    // Alert banner (fixed intrinsic height)
                    _buildAlertBanner(),

                    const SizedBox(height: 12),

                    // Disease detection — flex
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/detect'),
                        child: const HoverCard(
                          title: "রোগ শনাক্তকরণ",
                          icon: Icons.camera_rounded,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Knowledge base — flex
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DiseaseGuidanceScreen()),
                        ),
                        child: const HoverCard(
                          title: "জ্ঞানভান্ডার",
                          icon: Icons.menu_book_rounded,
                          color: Colors.brown,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tips label
                    Text(
                      "আজকের টিপস",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tips card — flex
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lightbulb_outline,
                                color: Colors.orange, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "ধানের জমিতে সঠিক সময়ে ইউরিয়া সার প্রয়োগ করলে ফলন ২০% বৃদ্ধি পায়।",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class WideHoverCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;

  const WideHoverCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<WideHoverCard> createState() => _WideHoverCardState();
}

class _WideHoverCardState extends State<WideHoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        transform: isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(isHovered ? 0.25 : 0.08),
              blurRadius: isHovered ? 25 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isHovered ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        transform: isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(isHovered ? 0.25 : 0.08),
              blurRadius: isHovered ? 25 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isHovered ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverNavIcon extends StatefulWidget {
  final IconData icon;
  final bool isActive;

  const _HoverNavIcon({required this.icon, this.isActive = false});

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
