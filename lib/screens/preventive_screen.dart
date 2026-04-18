import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../models/advice_model.dart';
import 'home_screen.dart'; // WeatherData & WeatherService

// ---------------------------------------------------------------------------
// Mini audio player — Google Cloud TTS REST API
// ---------------------------------------------------------------------------
class _AudioPlayer extends StatefulWidget {
  final String text;
  const _AudioPlayer({required this.text});

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  static const String _apiKey = 'AIzaSyBaXGJWooQsSkwIrEVyNUTedHfDaIuYj1Q';
  static const String _ttsUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  bool _playing = false;
  bool _loading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete
        .listen((_) { if (mounted) setState(() => _playing = false); });
  }

  @override
  void dispose() { _audioPlayer.dispose(); super.dispose(); }

  Future<Uint8List?> _fetchAudio() async {
    try {
      final res = await http.post(
        Uri.parse('$_ttsUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "input": {"text": widget.text},
          "voice": {"languageCode": "bn-IN", "name": "bn-IN-Wavenet-A"},
          "audioConfig": {"audioEncoding": "MP3", "speakingRate": 0.9},
        }),
      );
      if (res.statusCode == 200) {
        return base64Decode(jsonDecode(res.body)['audioContent'] as String);
      }
    } catch (e) { debugPrint('TTS: $e'); }
    return null;
  }

  Future<void> _togglePlay() async {
    if (_playing) { await _audioPlayer.stop(); setState(() => _playing = false); return; }
    await _play();
  }

  Future<void> _replay() async {
    await _audioPlayer.stop(); setState(() => _playing = false); await _play();
  }

  Future<void> _play() async {
    setState(() => _loading = true);
    final bytes = await _fetchAudio();
    if (!mounted) return;
    if (bytes == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('অডিও লোড করতে সমস্যা হয়েছে')));
      return;
    }
    setState(() { _loading = false; _playing = true; });
    await _audioPlayer.play(BytesSource(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _loading
              ? SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.green.shade700))
              : IconButton(
                  icon: Icon(
                    _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.green.shade700, size: 28),
                  tooltip: _playing ? "বিরতি" : "বাংলা অডিও শুনুন",
                  onPressed: _togglePlay,
                  padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.replay, color: Colors.green.shade600, size: 22),
            tooltip: "পুনরায় শুনুন",
            onPressed: _loading ? null : _replay,
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 8),
          Text(
            _loading ? "লোড হচ্ছে..." : _playing ? "অডিও চলছে..." : "বাংলা অডিও",
            style: TextStyle(fontSize: 12, color: Colors.green.shade700,
                fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weather advisory model + builder
// ---------------------------------------------------------------------------
class _Advisory {
  final IconData icon;
  final Color bg, border, iconBg, text;
  final String headline, detail;
  const _Advisory({
    required this.icon, required this.bg, required this.border,
    required this.iconBg, required this.text,
    required this.headline, required this.detail,
  });
}

_Advisory _buildAdvisory(WeatherData w) {
  if (w.rainMm > 10) {
    return _Advisory(
      icon: Icons.thunderstorm_rounded,
      bg: Colors.blue.shade50, border: Colors.blue.shade300,
      iconBg: Colors.blue.shade700, text: Colors.blue.shade900,
      headline: "আজ ভারী বৃষ্টির সম্ভাবনা — পানি জমতে পারে",
      detail: "জমির ড্রেনেজ এখনই নিশ্চিত করুন। স্প্রে ও সেচ সম্পূর্ণ এড়িয়ে চলুন। "
          "আলু ও টমেটোতে লেট ব্লাইটের ঝুঁকি অনেক বেশি।",
    );
  }
  if (w.rainMm > 0) {
    return _Advisory(
      icon: Icons.grain_rounded,
      bg: Colors.lightBlue.shade50, border: Colors.lightBlue.shade200,
      iconBg: Colors.lightBlue.shade600, text: Colors.lightBlue.shade900,
      headline: "হালকা বৃষ্টি চলছে — স্প্রে করবেন না",
      detail: "বৃষ্টিতে ওষুধ ধুয়ে যাবে। বৃষ্টি থামার পর ছত্রাকনাশক প্রয়োগ করুন।",
    );
  }
  if (w.humidity > 85) {
    return _Advisory(
      icon: Icons.water_drop_rounded,
      bg: Colors.orange.shade50, border: Colors.orange.shade200,
      iconBg: Colors.orange.shade700, text: Colors.orange.shade900,
      headline: "অতিরিক্ত আর্দ্রতা (${w.humidity.toInt()}%) — ছত্রাকের ঝুঁকি",
      detail: "আলু, ধান ও টমেটোতে ছত্রাকজনিত রোগ দ্রুত ছড়াতে পারে। "
          "আজই প্রতিরোধমূলক ছত্রাকনাশক প্রয়োগ করুন।",
    );
  }
  if (w.tempC > 38) {
    return _Advisory(
      icon: Icons.thermostat_rounded,
      bg: Colors.deepOrange.shade50, border: Colors.deepOrange.shade200,
      iconBg: Colors.deepOrange.shade600, text: Colors.deepOrange.shade900,
      headline: "তাপমাত্রা অনেক বেশি (${w.tempC.toStringAsFixed(1)}°C)",
      detail: "দুপুরে সেচ ও স্প্রে এড়িয়ে চলুন। সকাল বা বিকেলে কাজ করুন। "
          "গাছের গোড়ায় মাল্চিং দিন।",
    );
  }
  if (w.windSpeed > 40) {
    return _Advisory(
      icon: Icons.air_rounded,
      bg: Colors.purple.shade50, border: Colors.purple.shade200,
      iconBg: Colors.purple.shade600, text: Colors.purple.shade900,
      headline: "তীব্র বাতাস (${w.windSpeed} km/h) — স্প্রে করবেন না",
      detail: "বাতাসে ওষুধ উড়ে পার্শ্ববর্তী ফসলের ক্ষতি করতে পারে। বাতাস কমলে স্প্রে করুন।",
    );
  }
  // Clear / good weather
  return _Advisory(
    icon: Icons.wb_sunny_rounded,
    bg: Colors.green.shade50, border: Colors.green.shade200,
    iconBg: Colors.green.shade700, text: Colors.green.shade900,
    headline: "আবহাওয়া অনুকূল — কাজের উপযুক্ত সময়",
    detail: "আজ স্প্রে, সার প্রয়োগ ও জমি পর্যবেক্ষণের জন্য ভালো দিন। "
        "সকালে শিশির শুকানোর পর স্প্রে করুন।",
  );
}

// ---------------------------------------------------------------------------
// Corrective Advice Screen — single page, weather-aware
// ---------------------------------------------------------------------------
class PreventiveScreen extends StatefulWidget {
  /// Pass the already-fetched WeatherData from HomeScreen to avoid a
  /// duplicate API call. If null, the screen fetches it on its own.
  final WeatherData? weather;
  const PreventiveScreen({super.key, this.weather});

  @override
  State<PreventiveScreen> createState() => _PreventiveScreenState();
}

class _PreventiveScreenState extends State<PreventiveScreen> {
  WeatherData? _weather;
  bool _loadingWeather = true;
  String? _weatherError;

  // ── Dataset ────────────────────────────────────────────────────────────────
  final List<AgriAdvice> advices = [
    AgriAdvice(
      title: "রোগ শনাক্ত: আলু আর্লি ব্লাইট",
      description:
          "পাতায় গোলাকার বাদামি দাগ ও হলুদ রিং দেখা যাচ্ছে। "
          "এটি Alternaria solani ছত্রাকের আক্রমণ। "
          "সময়মতো ব্যবস্থা না নিলে ২–৩ সপ্তাহে পুরো গাছ নষ্ট হতে পারে।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Monsoon", weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই ম্যানকোজেব বা ক্লোরোথ্যালোনিল ছত্রাকনাশক স্প্রে করুন। "
          "আক্রান্ত পাতা কেটে সরিয়ে ফেলুন।",
      whatToAvoid: "বৃষ্টির আগে বা পরপরই স্প্রে করবেন না। "
          "আক্রান্ত পাতা জমিতে ফেলে রাখবেন না।",
      nextSteps: "৭ দিন পর দ্বিতীয় দফা স্প্রে করুন। সেচ ড্রিপ পদ্ধতিতে পরিবর্তন করুন।",
      hasPesticideWarning: true,
      audioGuidance: "পাতায় বাদামি দাগ ও হলুদ রিং দেখা যাচ্ছে। এটি আর্লি ব্লাইট। "
          "এখনই ছত্রাকনাশক স্প্রে করুন এবং আক্রান্ত পাতা সরিয়ে ফেলুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: আলু লেট ব্লাইট",
      description:
          "পাতায় জলভেজা সবুজ-বাদামি দাগ এবং পাতার নিচে সাদা ছত্রাকের আবরণ দেখা যাচ্ছে। "
          "এটি Phytophthora infestans — আলুর সবচেয়ে বিধ্বংসী রোগ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Monsoon", weather: "Rainy",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই সিস্টেমিক ছত্রাকনাশক (মেটালাক্সিল বা ডাইমেথোমর্ফ) স্প্রে করুন। "
          "আক্রান্ত অংশ কেটে জমির বাইরে পুঁতে ফেলুন।",
      whatToAvoid: "আক্রান্ত গাছ স্পর্শের পর সুস্থ গাছ ধরবেন না। "
          "ওভারহেড সেচ সম্পূর্ণ বন্ধ রাখুন।",
      nextSteps: "৫ দিন পর দ্বিতীয় দফা স্প্রে করুন। পার্শ্ববর্তী কৃষকদেরও সতর্ক করুন।",
      hasPesticideWarning: true,
      audioGuidance: "পাতায় জলভেজা বাদামি দাগ ও সাদা ছত্রাক দেখা যাচ্ছে। এটি লেট ব্লাইট। "
          "এখনই সিস্টেমিক ছত্রাকনাশক স্প্রে করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: ব্ল্যাক স্কার্ফ",
      description: "কন্দের গায়ে কালো পাউডারের মতো দাগ ও চারার গোড়া কালো হয়ে যাচ্ছে। "
          "এটি Rhizoctonia solani ছত্রাকের সংক্রমণ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Winter", weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "আক্রান্ত চারা তুলে ফেলুন। অনুমোদিত ছত্রাকনাশক মাটিতে প্রয়োগ করুন। "
          "জমির পানি নিষ্কাশন উন্নত করুন।",
      whatToAvoid: "আক্রান্ত কন্দ বীজ হিসেবে ব্যবহার করবেন না। জমিতে পানি জমতে দেবেন না।",
      nextSteps: "৩ দিন পর পুনরায় মূল্যায়ন করুন। পরের মৌসুমে ফসল পরিবর্তন করুন।",
      hasPesticideWarning: true,
      audioGuidance: "কন্দে কালো দাগ ও চারার গোড়া কালো হচ্ছে। এটি ব্ল্যাক স্কার্ফ। "
          "আক্রান্ত চারা তুলে ফেলুন এবং ছত্রাকনাশক মাটিতে প্রয়োগ করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: ব্ল্যাকলেগ",
      description: "গাছের গোড়া কালো হয়ে পচছে এবং পাতা হলুদ হয়ে ঢলে পড়ছে। "
          "এটি Pectobacterium ব্যাকটেরিয়ার সক্রিয় সংক্রমণ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Monsoon", weather: "Rainy",
      icon: Icons.warning_amber_rounded,
      whatToDo: "আক্রান্ত গাছ এখনই উপড়ে ফেলুন এবং মাটিতে পুঁতে দিন। "
          "পার্শ্ববর্তী সুস্থ গাছে তামা-ভিত্তিক ব্যাকটেরিসাইড স্প্রে করুন।",
      whatToAvoid: "আক্রান্ত গাছ স্পর্শের পর সুস্থ গাছ ধরবেন না। জমিতে সেচ কমিয়ে দিন।",
      nextSteps: "৫ দিন পর বাকি গাছ পর্যবেক্ষণ করুন।",
      hasPesticideWarning: true,
      audioGuidance: "গাছের গোড়া কালো হয়ে পচছে। এটি ব্ল্যাকলেগ। "
          "আক্রান্ত গাছ এখনই উপড়ে ফেলুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: ড্রাই রট",
      description: "আলু কাটলে ভেতরে বাদামি শুকনো পচন ও ফাঁকা অংশ দেখা যাচ্ছে। "
          "এটি Fusarium ছত্রাকের সক্রিয় সংক্রমণ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Winter", weather: "Foggy",
      icon: Icons.warning_amber_rounded,
      whatToDo: "আক্রান্ত আলু তুলে নষ্ট করুন। সংরক্ষণাগার ভালোভাবে পরিষ্কার ও শুকিয়ে নিন।",
      whatToAvoid: "আক্রান্ত আলু খাদ্য বা বীজ হিসেবে ব্যবহার করবেন না।",
      nextSteps: "বাকি ফসলের অবস্থা মূল্যায়ন করুন।",
      hasPesticideWarning: true,
      audioGuidance: "আলু কাটলে ভেতরে শুকনো পচন দেখা যাচ্ছে। এটি ড্রাই রট। "
          "আক্রান্ত আলু তুলে নষ্ট করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: পিংক রট",
      description: "আলু কাটলে ভেতরে গোলাপি থেকে বাদামি পচন দেখা যাচ্ছে। "
          "এটি Phytophthora erythroseptica সংক্রমণ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Monsoon", weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "জমির পানি নিষ্কাশন অবিলম্বে ঠিক করুন। আক্রান্ত আলু তুলে নষ্ট করুন. "
          "মেটালাক্সিল ভিত্তিক ছত্রাকনাশক প্রয়োগ করুন।",
      whatToAvoid: "আক্রান্ত এলাকায় সেচ দেওয়া বন্ধ রাখুন।",
      nextSteps: "৩–৫ দিন পর পুনরায় পর্যবেক্ষণ করুন।",
      hasPesticideWarning: true,
      audioGuidance: "আলু কাটলে গোলাপি পচন দেখা যাচ্ছে। এটি পিংক রট। "
          "দ্রুত পানি নিষ্কাশন করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: কমন স্ক্যাব",
      description: "আলুর খোসায় খসখসে বাদামি দাগ স্পষ্ট হয়ে উঠছে। "
          "এটি Streptomyces scabies ব্যাকটেরিয়ার সক্রিয় আক্রমণ।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato", season: "Summer", weather: "Sunny",
      icon: Icons.warning_amber_rounded,
      whatToDo: "মাটিতে অম্লীয় সার (সালফার বা অ্যামোনিয়াম সালফেট) প্রয়োগ করুন। "
          "পর্যাপ্ত সেচ দিন।",
      whatToAvoid: "চুন বা কাঠের ছাই আর দেবেন না।",
      nextSteps: "পরের মৌসুমে pH পরীক্ষা করে চাষ শুরু করুন।",
      hasPesticideWarning: false,
      audioGuidance: "আলুর খোসায় খসখসে দাগ দেখা যাচ্ছে। এটি কমন স্ক্যাব। "
          "অম্লীয় সার প্রয়োগ করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: টমেটো ব্লাইট",
      description: "পাতায় হলুদ ও বাদামি দাগ — আর্লি ব্লাইট (Alternaria solani)। "
          "দ্রুত ব্যবস্থা না নিলে সম্পূর্ণ গাছ নষ্ট হতে পারে।",
      severity: AdviceSeverity.urgent,
      cropType: "Tomato", season: "Monsoon", weather: "Rainy",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
      whatToAvoid: "বৃষ্টির আগে স্প্রে করবেন না।",
      nextSteps: "৭ দিন পর দ্বিতীয় দফা স্প্রে করুন।",
      hasPesticideWarning: true,
      audioGuidance: "পাতায় হলুদ ও বাদামি দাগ দেখা যাচ্ছে। এটি আর্লি ব্লাইট। "
          "এখনই ছত্রাকনাশক স্প্রে করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: ধানের ব্লাস্ট",
      description: "ধানের পাতায় বাদামি দাগ ও কাণ্ডে কালো বিন্দু — ব্লাস্ট রোগ (Magnaporthe oryzae)। "
          "সময়মতো ব্যবস্থা না নিলে ফলন ৫০–৮০% কমে যেতে পারে।",
      severity: AdviceSeverity.urgent,
      cropType: "Rice", season: "Monsoon", weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "আক্রান্ত অংশ কেটে সরান এবং অনুমোদিত ছত্রাকনাশক ব্যবহার করুন।",
      whatToAvoid: "জমিতে অতিরিক্ত ইউরিয়া দেওয়া বন্ধ রাখুন।",
      nextSteps: "৩ দিন পর পুনরায় মূল্যায়ন করুন।",
      hasPesticideWarning: true,
      audioGuidance: "ধানের পাতায় বাদামি দাগ দেখা যাচ্ছে। এটি ব্লাস্ট রোগ। "
          "আক্রান্ত অংশ কেটে সরান।",
    ),
  ];

  final Map<String, String> cropMap = {
    "Potato": "আলু", "Tomato": "টমেটো", "Wheat": "গম",
    "Rice": "ধান", "Jute": "পাট", "Maize": "ভুট্টা",
  };
  final List<String> crops = [
    "Potato", "Tomato", "Wheat", "Rice", "Jute", "Maize"
  ];
  String selectedCrop = "Potato";

  List<AgriAdvice> get _list => advices
      .where((a) => a.severity == AdviceSeverity.urgent && a.cropType == selectedCrop)
      .toList();

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.weather != null) {
      _weather = widget.weather;
      _loadingWeather = false;
    } else {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    setState(() { _loadingWeather = true; _weatherError = null; });
    try {
      final d = await WeatherService.fetchByCity('Dhaka');
      if (mounted) setState(() { _weather = d; _loadingWeather = false; });
    } catch (_) {
      if (mounted) setState(() { _weatherError = 'আবহাওয়া লোড হয়নি'; _loadingWeather = false; });
    }
  }

  // ── Weather advisory banner ──────────────────────────────────────────────────
  Widget _buildWeatherBanner() {
    if (_loadingWeather) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.grey.shade500)),
            const SizedBox(width: 10),
            Text("আবহাওয়া তথ্য লোড হচ্ছে...",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      );
    }
    if (_weatherError != null || _weather == null) return const SizedBox.shrink();

    final adv = _buildAdvisory(_weather!);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: adv.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: adv.border, width: 1.2),
        boxShadow: [
          BoxShadow(color: adv.border.withOpacity(0.25),
              blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 14, backgroundColor: adv.iconBg,
                  child: Icon(adv.icon, color: Colors.white, size: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(adv.headline,
                    style: TextStyle(color: adv.text,
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              // Live weather chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: adv.iconBg.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: adv.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat_rounded, size: 11, color: adv.text),
                    const SizedBox(width: 3),
                    Text(
                      "${_weather!.tempC.toStringAsFixed(0)}°C · ${_weather!.humidity.toInt()}%",
                      style: TextStyle(fontSize: 10, color: adv.text,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(adv.detail,
              style: TextStyle(color: adv.text.withOpacity(0.82), fontSize: 12)),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("কার্যকরী পরামর্শ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWeatherBanner(),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            color: Colors.red.shade50,
            child: DropdownButtonFormField<String>(
              value: selectedCrop,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "ফসল নির্বাচন করুন",
                prefixIcon: Icon(Icons.grass, size: 18, color: Colors.red.shade700),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true, fillColor: Colors.white,
              ),
              items: crops
                  .map((i) => DropdownMenuItem(value: i, child: Text(cropMap[i]!)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCrop = v!),
            ),
          ),
          Expanded(child: _buildList(_list)),
        ],
      ),
    );
  }

  Widget _buildList(List<AgriAdvice> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400),
            const SizedBox(height: 12),
            Text("এই ফসলে কোনো রোগ শনাক্ত হয়নি",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) => _AdviceCard(advice: list[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Advice Card
// ---------------------------------------------------------------------------
class _AdviceCard extends StatefulWidget {
  final AgriAdvice advice;
  const _AdviceCard({required this.advice});

  @override
  State<_AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<_AdviceCard> {
  bool _expanded = false;
  Color get _c => Colors.red.shade700;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _c.withOpacity(0.3)),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _c.withOpacity(0.12),
                    child: Icon(widget.advice.icon, color: _c, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _c.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 13, color: _c),
                              const SizedBox(width: 4),
                              Text("জরুরি",
                                  style: TextStyle(fontSize: 11, color: _c,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(widget.advice.title,
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 15, color: _c)),
                        const SizedBox(height: 4),
                        Text(widget.advice.description,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.advice.whatToDo != null)
                    _infoRow(icon: Icons.check_circle_outline,
                        color: Colors.green.shade700,
                        label: "এখন কী করবেন", text: widget.advice.whatToDo!),
                  if (widget.advice.whatToAvoid != null)
                    _infoRow(icon: Icons.do_not_disturb_alt_outlined,
                        color: Colors.orange.shade700,
                        label: "কী এড়াবেন", text: widget.advice.whatToAvoid!),
                  if (widget.advice.nextSteps != null)
                    _infoRow(icon: Icons.arrow_forward_ios_rounded,
                        color: Colors.blue.shade600,
                        label: "পরবর্তী পদক্ষেপ", text: widget.advice.nextSteps!),
                  const SizedBox(height: 10),
                  _AudioPlayer(text: widget.advice.audioGuidance),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
          if (widget.advice.hasPesticideWarning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "সতর্কতা: কীটনাশক/সার ব্যবহারের সময় মাস্ক ও গ্লাভস পরুন",
                      style: TextStyle(fontSize: 12, color: Colors.red.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon, required Color color,
    required String label, required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "$label: ",
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: color, fontSize: 13)),
                TextSpan(text: text,
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
