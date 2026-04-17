import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/advice_model.dart';

// ---------------------------------------------------------------------------
// Reusable mini audio player (same TTS logic as advisory screen)
// ---------------------------------------------------------------------------
class _AudioPlayer extends StatefulWidget {
  final String text;
  const _AudioPlayer({required this.text});

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  bool _playing = false;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("bn-BD");
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _tts.stop();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      await _tts.speak(widget.text);
    }
  }

  Future<void> _replay() async {
    await _tts.stop();
    setState(() => _playing = true);
    await _tts.speak(widget.text);
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
          IconButton(
            icon: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.green.shade700,
              size: 28,
            ),
            tooltip: _playing ? "বিরতি" : "বাংলা অডিও শুনুন",
            onPressed: _togglePlay,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.replay, color: Colors.green.shade600, size: 22),
            tooltip: "পুনরায় শুনুন",
            onPressed: _replay,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            _playing ? "অডিও চলছে..." : "বাংলা অডিও",
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preventive Screen
// ---------------------------------------------------------------------------
class PreventiveScreen extends StatefulWidget {
  const PreventiveScreen({super.key});

  @override
  State<PreventiveScreen> createState() => _PreventiveScreenState();
}

class _PreventiveScreenState extends State<PreventiveScreen> {
  final List<AgriAdvice> advices = [
    AgriAdvice(
      title: "ব্লাইট রোগ প্রতিরোধ",
      description: "আবহাওয়া আর্দ্র থাকায় আলু ক্ষেতে ব্লাইট দেখা দিতে পারে।",
      severity: AdviceSeverity.recommended,
      cropType: "Potato",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই সতর্কতামূলক ছত্রাকনাশক স্প্রে করুন।",
      whatToAvoid: "আজ ওভারহেড জল দেওয়া এড়ান।",
      nextSteps: "৩ দিন পর পাতা পরীক্ষা করুন।",
      hasPesticideWarning: true,
      audioGuidance:
          "আবহাওয়া আর্দ্র থাকায় আলু ক্ষেতে ব্লাইট দেখা দিতে পারে। এখনই সতর্কতামূলক ছত্রাকনাশক স্প্রে করুন এবং ওভারহেড জল দেওয়া এড়ান।",
    ),
    AgriAdvice(
      title: "সঠিক সেচ পদ্ধতি",
      description:
          "বিকেলের পর সেচ দিলে পানির অপচয় কম হয় এবং গাছের বৃদ্ধি ভালো হয়।",
      severity: AdviceSeverity.optional,
      cropType: "Potato",
      season: "Summer",
      weather: "Sunny",
      icon: Icons.water_drop_outlined,
      whatToDo: "বিকেল ৫টার পর সেচ দিন।",
      whatToAvoid: "দুপুরে সেচ দেওয়া থেকে বিরত থাকুন।",
      nextSteps: "সাপ্তাহিক সেচের সময়সূচি তৈরি করুন।",
      audioGuidance:
          "বিকেলের পর সেচ দিলে পানির অপচয় কম হয়। বিকেল পাঁচটার পর সেচ দিন এবং দুপুরে সেচ এড়িয়ে চলুন।",
    ),
    AgriAdvice(
      title: "গমের রাস্ট প্রতিরোধ",
      description: "শুষ্ক আবহাওয়ায় গমের রাস্ট রোগের ঝুঁকি থাকে।",
      severity: AdviceSeverity.recommended,
      cropType: "Wheat",
      season: "Dry",
      weather: "Sunny",
      icon: Icons.agriculture,
      whatToDo: "নিয়মিত পর্যবেক্ষণ করুন এবং প্রয়োজনে ছত্রাকনাশক ব্যবহার করুন।",
      whatToAvoid: "অতিরিক্ত নাইট্রোজেন সার এড়ান।",
      nextSteps: "সপ্তাহে দুইবার পাতা পরীক্ষা করুন।",
      hasPesticideWarning: true,
      audioGuidance:
          "শুষ্ক আবহাওয়ায় গমের রাস্ট রোগের ঝুঁকি থাকে। নিয়মিত পর্যবেক্ষণ করুন এবং প্রয়োজনে ছত্রাকনাশক ব্যবহার করুন।",
    ),
    AgriAdvice(
      title: "টমেটো ব্লাইট প্রতিরোধ",
      description: "বৃষ্টি বেশি হলে মাটিতে ফাংগাসের ঝুঁকি বাড়ে।",
      severity: AdviceSeverity.recommended,
      cropType: "Tomato",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.eco,
      whatToDo: "গাছের পাতা শুকনো রাখুন এবং মাল্চিং ব্যবহার করুন।",
      whatToAvoid: "বৃষ্টির পর সাথে সাথে স্প্রে করবেন না।",
      nextSteps: "বৃষ্টি থামলে ছত্রাকনাশক প্রয়োগ করুন।",
      hasPesticideWarning: true,
      audioGuidance:
          "বৃষ্টি বেশি হলে মাটিতে ফাংগাসের ঝুঁকি বাড়ে। গাছের পাতা শুকনো রাখুন এবং বৃষ্টি থামলে ছত্রাকনাশক প্রয়োগ করুন।",
    ),
    AgriAdvice(
      title: "ধানের পাতার দাগ প্রতিরোধ",
      description: "আর্দ্র আবহাওয়ায় ধানে পাতার দাগ রোগ হতে পারে।",
      severity: AdviceSeverity.recommended,
      cropType: "Rice",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.grass,
      whatToDo: "নিয়মিত পর্যবেক্ষণ করুন এবং সঠিক পরিমাণ পটাশ সার দিন।",
      whatToAvoid: "অতিরিক্ত পানি জমতে দেবেন না।",
      nextSteps: "৫ দিন পর পাতার অবস্থা দেখুন।",
      audioGuidance:
          "আর্দ্র আবহাওয়ায় ধানে পাতার দাগ রোগ হতে পারে। নিয়মিত পর্যবেক্ষণ করুন এবং অতিরিক্ত পানি জমতে দেবেন না।",
    ),
    AgriAdvice(
      title: "ধানের পুষ্টি পরামর্শ",
      description: "বর্ষায় ধানের জমিতে জিংক সার প্রয়োগ ফলন বাড়ায়।",
      severity: AdviceSeverity.optional,
      cropType: "Rice",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.eco_outlined,
      whatToDo: "প্রতি বিঘায় ১ কেজি জিংক সালফেট প্রয়োগ করুন।",
      whatToAvoid: "অতিরিক্ত ইউরিয়া একসাথে দেওয়া এড়ান।",
      nextSteps: "১৫ দিন পর ফলাফল মূল্যায়ন করুন।",
      audioGuidance:
          "বর্ষায় ধানের জমিতে জিংক সার প্রয়োগ ফলন বাড়ায়। প্রতি বিঘায় এক কেজি জিংক সালফেট প্রয়োগ করুন।",
    ),
  ];

  final Map<String, String> cropMap = {
    "Potato": "আলু",
    "Tomato": "টমেটো",
    "Wheat": "গম",
    "Rice": "ধান",
    "Jute": "পাট",
    "Maize": "ভুট্টা",
  };
  final Map<String, String> seasonMap = {
    "Monsoon": "বর্ষা",
    "Summer": "গ্রীষ্ম",
    "Winter": "শীত",
    "Dry": "শুষ্ক",
  };
  final Map<String, String> weatherMap = {
    "Humid": "আর্দ্র",
    "Sunny": "রৌদ্রোজ্জ্বল",
    "Rainy": "বৃষ্টি",
    "Cloudy": "মেঘলা",
    "Foggy": "কুয়াশা",
  };

  String selectedCrop = "Potato";
  String selectedSeason = "Monsoon";
  String selectedWeather = "Humid";

  final List<String> crops = ["Potato", "Tomato", "Wheat", "Rice", "Jute", "Maize"];
  final List<String> seasons = ["Monsoon", "Summer", "Winter", "Dry"];
  final List<String> weathers = ["Humid", "Sunny", "Rainy", "Cloudy", "Foggy"];

  @override
  Widget build(BuildContext context) {
    final filtered = advices.where((a) {
      return (a.severity == AdviceSeverity.recommended ||
              a.severity == AdviceSeverity.optional) &&
          a.cropType == selectedCrop &&
          a.season == selectedSeason &&
          a.weather == selectedWeather;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "প্রতিরোধমূলক পরামর্শ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildList(filtered)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Expanded(
            child: _dropdown(
              icon: Icons.grass,
              label: "ফসল",
              value: selectedCrop,
              items: crops,
              labelMap: cropMap,
              onChanged: (v) => setState(() => selectedCrop = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdown(
              icon: Icons.calendar_month,
              label: "মৌসুম",
              value: selectedSeason,
              items: seasons,
              labelMap: seasonMap,
              onChanged: (v) => setState(() => selectedSeason = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdown(
              icon: Icons.wb_cloudy_outlined,
              label: "আবহাওয়া",
              value: selectedWeather,
              items: weathers,
              labelMap: weatherMap,
              onChanged: (v) => setState(() => selectedWeather = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> labelMap,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.green.shade700),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((i) {
        return DropdownMenuItem(value: i, child: Text(labelMap[i]!));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildList(List<AgriAdvice> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 48, color: Colors.green.shade300),
            const SizedBox(height: 12),
            Text(
              "এই ফসল/মৌসুম/আবহাওয়ায় কোনো প্রতিরোধমূলক পরামর্শ নেই",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) => _PreventiveCard(advice: list[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Preventive Advice Card
// ---------------------------------------------------------------------------
class _PreventiveCard extends StatefulWidget {
  final AgriAdvice advice;
  const _PreventiveCard({required this.advice});

  @override
  State<_PreventiveCard> createState() => _PreventiveCardState();
}

class _PreventiveCardState extends State<_PreventiveCard> {
  bool _expanded = false;

  Color get _severityColor {
    switch (widget.advice.severity) {
      case AdviceSeverity.recommended:
        return Colors.teal.shade700;
      case AdviceSeverity.optional:
        return Colors.blue.shade600;
      default:
        return Colors.teal.shade700;
    }
  }

  String get _severityLabel {
    switch (widget.advice.severity) {
      case AdviceSeverity.recommended:
        return "প্রস্তাবিত";
      case AdviceSeverity.optional:
        return "ঐচ্ছিক";
      default:
        return "প্রস্তাবিত";
    }
  }

  IconData get _severityIcon {
    switch (widget.advice.severity) {
      case AdviceSeverity.recommended:
        return Icons.recommend_outlined;
      case AdviceSeverity.optional:
        return Icons.lightbulb_outline;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _severityColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.withOpacity(0.3)),
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
                    backgroundColor: c.withOpacity(0.12),
                    child: Icon(widget.advice.icon, color: c, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_severityIcon, size: 13, color: c),
                              const SizedBox(width: 4),
                              Text(
                                _severityLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.advice.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: c,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.advice.description,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
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
                    _infoRow(
                      icon: Icons.check_circle_outline,
                      color: Colors.green.shade700,
                      label: "এখন কী করবেন",
                      text: widget.advice.whatToDo!,
                    ),
                  if (widget.advice.whatToAvoid != null)
                    _infoRow(
                      icon: Icons.do_not_disturb_alt_outlined,
                      color: Colors.orange.shade700,
                      label: "কী এড়াবেন",
                      text: widget.advice.whatToAvoid!,
                    ),
                  if (widget.advice.nextSteps != null)
                    _infoRow(
                      icon: Icons.arrow_forward_ios_rounded,
                      color: Colors.blue.shade600,
                      label: "পরবর্তী পদক্ষেপ",
                      text: widget.advice.nextSteps!,
                    ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
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
    required IconData icon,
    required Color color,
    required String label,
    required String text,
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
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style:
                        TextStyle(color: Colors.grey.shade800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}