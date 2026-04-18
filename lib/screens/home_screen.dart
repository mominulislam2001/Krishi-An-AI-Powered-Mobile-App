import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'disease_guidance_screen.dart';
import 'preventive_screen.dart';


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
    if (rainMm > 0)      return "বৃষ্টি হচ্ছে: আজ স্প্রে করবেন না";
    if (humidity > 85)   return "অতিরিক্ত আর্দ্রতা: ছত্রাকের ঝুঁকি বেশি";
    if (tempC > 38)      return "তাপমাত্রা অনেক বেশি: সেচ দেওয়া এড়ান";
    if (windSpeed > 40)  return "তীব্র বাতাস: আজ স্প্রে করা ঠিক হবে না";
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

  Color _weatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':        return Colors.orange.shade400;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm': return Colors.blue.shade600;
      case 'clouds':       return Colors.blueGrey.shade400;
      default:             return Colors.lightBlue.shade400;
    }
  }

  // ── Weather card ────────────────────────────────────────────────────────────
  Widget _buildWeatherCard() {
    if (_loadingWeather) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 20)
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (_weatherError != null || _weather == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey),
            const SizedBox(width: 12),
            Text(_weatherError ?? 'আবহাওয়া তথ্য নেই',
                style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            TextButton(
                onPressed: _loadWeather,
                child: const Text("পুনরায় চেষ্টা")),
          ],
        ),
      );
    }

    final w = _weather!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(w.cityName,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: _loadWeather,
                child: const Icon(Icons.refresh, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${w.tempC.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      height: 1)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: Icon(_weatherIcon(w.condition),
                    color: Colors.white, size: 32),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(w.description,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
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
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  // ── Alert banner ────────────────────────────────────────────────────────────
  Widget _buildAlertBanner() {
    final alertMsg =
        _weather?.alertMessage ?? "জরুরি সতর্কতা: আজ স্প্রে করবেন না";
    final bool isWeatherAlert = _weather?.alertMessage != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.08), blurRadius: 20)
        ],
        border: Border.all(
            color: isWeatherAlert
                ? Colors.orange.shade200
                : Colors.red.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isWeatherAlert ? Colors.orange : Colors.red,
            child: Icon(
              isWeatherAlert
                  ? Icons.wb_cloudy_rounded
                  : Icons.notifications_active,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alertMsg,
              style: TextStyle(
                color: isWeatherAlert
                    ? Colors.orange.shade800
                    : Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
// ── Build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreventiveScreen(),
                  ),
                );
              },
              child: const _HoverNavIcon(icon: Icons.info_outline_rounded),
            ),
            const _HoverNavIcon(icon: Icons.person_outline_rounded),
          ],
        ),
      ),

      body: Stack(
        children: [
          Container(
            height: 120,
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
           child: Align(
            alignment: Alignment.topLeft, // 👈 move everything top-left
            child: Padding(
              padding: const EdgeInsets.all(16), // spacing from edges
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'images/Krishi_trans_logo.png',
                        height: 60,
                        width: 60,
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "কৃষি",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "আপনার ফসলের জন্য সেরা পরামর্শ",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),     
            ),
          ),
         ),

        

                  

              // Full-width Disease Detection card
            SingleChildScrollView(
            padding: const EdgeInsets.only(top: 130, left: 20, right: 20, bottom: 20),
            child:Column(
              children: [
                // Weather card
                _buildWeatherCard(),

                const SizedBox(height: 16),

                // Alert banner (driven by weather data)
                _buildAlertBanner(),

                const SizedBox(height: 30),

                // Action cards
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/detect'),
                  
                  child: const SizedBox(
                    width: double.infinity,
                    child: HoverCard(
                      title: "রোগ শনাক্তকরণ",
                      icon: Icons.camera_rounded,
                      color: Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DiseaseGuidanceScreen(),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: HoverCard(
                      title: "জ্ঞানভান্ডার",
                      icon: Icons.menu_book_rounded,
                      color: Colors.brown,
                    ),
                  ),
                ),
              
            

                  const SizedBox(height: 30),

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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange,
                          size: 25,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            "ধানের জমিতে সঠিক সময়ে ইউরিয়া সার প্রয়োগ করলে ফলন ২০% বৃদ্ধি পায়।",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          
        ],
      ),
    );
  }
}

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
        height: 90,
        transform: isHovered
            ? Matrix4.translationValues(0, -6, 0)
            : Matrix4.identity(),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isHovered ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
            ? Matrix4.translationValues(0, -6, 0)
            : Matrix4.identity(),
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
                radius: 18,
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
