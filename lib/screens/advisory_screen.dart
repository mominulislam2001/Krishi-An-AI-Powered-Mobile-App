import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/advice_model.dart';

// ---------------------------------------------------------------------------
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
          // FR-27: play/pause button
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
          // FR-27: replay button
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
// Advisory Screen
// ---------------------------------------------------------------------------
class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  // ── FR-22: Rich dataset covering crop × season × weather combinations ──
  final List<AgriAdvice> advices = [
    // ── PREVENTIVE (recommended / optional) ────────────────────────────

    // FR-20: Preventive — risk detected before disease occurs
    AgriAdvice(
      title: "ব্লাইট রোগ প্রতিরোধ",
      description:
          "আবহাওয়া আর্দ্র থাকায় আলু ক্ষেতে ব্লাইট দেখা দিতে পারে।",
      severity: AdviceSeverity.recommended, // FR-23
      cropType: "Potato",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই সতর্কতামূলক ছত্রাকনাশক স্প্রে করুন।",
      whatToAvoid: "আজ ওভারহেড জল দেওয়া এড়ান।",
      nextSteps: "৩ দিন পর পাতা পরীক্ষা করুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "আবহাওয়া আর্দ্র থাকায় আলু ক্ষেতে ব্লাইট দেখা দিতে পারে। এখনই সতর্কতামূলক ছত্রাকনাশক স্প্রে করুন এবং ওভারহেড জল দেওয়া এড়ান।",
    ),
    AgriAdvice(
      title: "সঠিক সেচ পদ্ধতি",
      description:
          "বিকেলের পর সেচ দিলে পানির অপচয় কম হয় এবং গাছের বৃদ্ধি ভালো হয়।",
      severity: AdviceSeverity.optional, // FR-23
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
      severity: AdviceSeverity.recommended, // FR-23
      cropType: "Wheat",
      season: "Dry",
      weather: "Sunny",
      icon: Icons.agriculture,
      whatToDo: "নিয়মিত পর্যবেক্ষণ করুন এবং প্রয়োজনে ছত্রাকনাশক ব্যবহার করুন।",
      whatToAvoid: "অতিরিক্ত নাইট্রোজেন সার এড়ান।",
      nextSteps: "সপ্তাহে দুইবার পাতা পরীক্ষা করুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "শুষ্ক আবহাওয়ায় গমের রাস্ট রোগের ঝুঁকি থাকে। নিয়মিত পর্যবেক্ষণ করুন এবং প্রয়োজনে ছত্রাকনাশক ব্যবহার করুন।",
    ),
    AgriAdvice(
      title: "টমেটো ব্লাইট প্রতিরোধ",
      description: "বৃষ্টি বেশি হলে মাটিতে ফাংগাসের ঝুঁকি বাড়ে।",
      severity: AdviceSeverity.recommended, // FR-23
      cropType: "Tomato",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.eco,
      whatToDo: "গাছের পাতা শুকনো রাখুন এবং মাল্চিং ব্যবহার করুন।",
      whatToAvoid: "বৃষ্টির পর সাথে সাথে স্প্রে করবেন না।",
      nextSteps: "বৃষ্টি থামলে ছত্রাকনাশক প্রয়োগ করুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "বৃষ্টি বেশি হলে মাটিতে ফাংগাসের ঝুঁকি বাড়ে। গাছের পাতা শুকনো রাখুন এবং বৃষ্টি থামলে ছত্রাকনাশক প্রয়োগ করুন।",
    ),
    AgriAdvice(
      title: "ধানের পাতার দাগ প্রতিরোধ",
      description: "আর্দ্র আবহাওয়ায় ধানে পাতার দাগ রোগ হতে পারে।",
      severity: AdviceSeverity.recommended, // FR-23
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
    // Extra: optional advice for Rice in Monsoon/Humid
    AgriAdvice(
      title: "ধানের পুষ্টি পরামর্শ",
      description: "বর্ষায় ধানের জমিতে জিংক সার প্রয়োগ ফলন বাড়ায়।",
      severity: AdviceSeverity.optional, // FR-23
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

    // ── CORRECTIVE (urgent) ─────────────────────────────────────────────

    // FR-21: Corrective — after disease is detected
    AgriAdvice(
      title: "রোগ শনাক্ত: আলু ব্লাইট",
      description: "পাতায় বাদামি দাগ দেখা যাচ্ছে — ব্লাইট সংক্রমণ।",
      severity: AdviceSeverity.urgent, // FR-23
      cropType: "Potato",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
      whatToAvoid: "আক্রান্ত পাতা ছুঁয়ে সুস্থ গাছ স্পর্শ করবেন না।",
      nextSteps: "ক্ষতিগ্রস্ত অংশ কেটে মাটিতে পুঁতে ফেলুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "পাতায় বাদামি দাগ দেখা যাচ্ছে। এটি ব্লাইট সংক্রমণ। এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন এবং ক্ষতিগ্রস্ত অংশ কেটে মাটিতে পুঁতে ফেলুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: টমেটো ব্লাইট",
      description: "পাতায় হলুদ ও বাদামি দাগ — আর্লি ব্লাইট।",
      severity: AdviceSeverity.urgent, // FR-23
      cropType: "Tomato",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.warning_amber_rounded,
      whatToDo: "এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
      whatToAvoid: "বৃষ্টির আগে স্প্রে করবেন না।",
      nextSteps: "৭ দিন পর দ্বিতীয় দফা স্প্রে করুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "পাতায় হলুদ ও বাদামি দাগ দেখা যাচ্ছে। এটি আর্লি ব্লাইট। এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
    ),
    AgriAdvice(
      title: "রোগ শনাক্ত: ধানের পাতার দাগ",
      description: "ধানের পাতায় বাদামি দাগ — ব্লাস্ট রোগ।",
      severity: AdviceSeverity.urgent, // FR-23
      cropType: "Rice",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
      whatToDo: "আক্রান্ত অংশ কেটে সরান এবং ছত্রাকনাশক ব্যবহার করুন।",
      whatToAvoid: "জমিতে অতিরিক্ত ইউরিয়া দেওয়া বন্ধ রাখুন।",
      nextSteps: "৩ দিন পর পুনরায় মূল্যায়ন করুন।",
      hasPesticideWarning: true, // FR-24
      audioGuidance:
          "ধানের পাতায় বাদামি দাগ দেখা যাচ্ছে। এটি ব্লাস্ট রোগ। আক্রান্ত অংশ কেটে সরান এবং ছত্রাকনাশক ব্যবহার করুন।",
    ),
  ];

  // ── Bangla label maps ───────────────────────────────────────────────────
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

  // ── Filter state ────────────────────────────────────────────────────────
  String selectedCrop = "Potato";
  String selectedSeason = "Monsoon";
  String selectedWeather = "Humid";

  final List<String> crops = ["Potato", "Tomato", "Wheat", "Rice","Jute","Maize"];
  final List<String> seasons = ["Monsoon", "Summer","Winter", "Dry"];
  final List<String> weathers = ["Humid", "Sunny", "Rainy","Cloudy","Foggy"];

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // FR-20: Preventive tab — filter by crop + season + weather
    final filteredPreventive = advices.where((a) {
      return (a.severity == AdviceSeverity.recommended ||
              a.severity == AdviceSeverity.optional) &&
          a.cropType == selectedCrop &&
          a.season == selectedSeason &&
          a.weather == selectedWeather;
    }).toList();

    // FR-21: Corrective tab — filter by crop + season + weather (urgent only)
    // FR-22: Tailored by the same three filters
    final filteredCorrective = advices.where((a) {
      return a.severity == AdviceSeverity.urgent &&
          a.cropType == selectedCrop &&
          a.season == selectedSeason &&
          a.weather == selectedWeather;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        // FR-25: Bangla title
        title: const Text(
          "কৃষি পরামর্শ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.healing_outlined), text: "কার্যকরী পরামর্শ"),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── FR-22: Shared filter bar (applies to both tabs) ─────────────
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // FR-21: Corrective tab only
                _buildList(filteredCorrective, isPreventive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: Colors.green.shade50,
      child: Row(
        children: [
          // FR-26: Icon beside each dropdown label
          Expanded(child: _dropdown(
            icon: Icons.grass,
            label: "ফসল",
            value: selectedCrop,
            items: crops,
            labelMap: cropMap,
            onChanged: (v) => setState(() => selectedCrop = v!),
          )),
          const SizedBox(width: 8),
          Expanded(child: _dropdown(
            icon: Icons.calendar_month,
            label: "মৌসুম",
            value: selectedSeason,
            items: seasons,
            labelMap: seasonMap,
            onChanged: (v) => setState(() => selectedSeason = v!),
          )),
          const SizedBox(width: 8),
          Expanded(child: _dropdown(
            icon: Icons.wb_cloudy_outlined,
            label: "আবহাওয়া",
            value: selectedWeather,
            items: weathers,
            labelMap: weatherMap,
            onChanged: (v) => setState(() => selectedWeather = v!),
          )),
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

  // ── List builder ─────────────────────────────────────────────────────────
  Widget _buildList(List<AgriAdvice> list, {required bool isPreventive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline,
                size: 48, color: Colors.green.shade300),
            const SizedBox(height: 12),
            Text(
              isPreventive
                  ? "এই ফসল/মৌসুম/আবহাওয়ায় কোনো প্রতিরোধমূলক পরামর্শ নেই"
                  : "এই ফসল/মৌসুম/আবহাওয়ায় কোনো রোগ শনাক্ত হয়নি",
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
      itemBuilder: (_, i) => AdviceCard(advice: list[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Advice Card  
// ---------------------------------------------------------------------------
class AdviceCard extends StatefulWidget {
  final AgriAdvice advice;
  const AdviceCard({super.key, required this.advice});

  @override
  State<AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<AdviceCard> {
  bool _expanded = false;

  // FR-23: Color + label per severity
  Color get _severityColor {
    switch (widget.advice.severity) {
      case AdviceSeverity.urgent:
        return Colors.red.shade700;
      case AdviceSeverity.recommended:
        return Colors.teal.shade700;
      case AdviceSeverity.optional:
        return Colors.blue.shade600;
    }
  }

  String get _severityLabel {
    switch (widget.advice.severity) {
      case AdviceSeverity.urgent:
        return "জরুরি"; // urgent
      case AdviceSeverity.recommended:
        return "প্রস্তাবিত"; // recommended
      case AdviceSeverity.optional:
        return "ঐচ্ছিক"; // optional
    }
  }

  IconData get _severityIcon {
    switch (widget.advice.severity) {
      case AdviceSeverity.urgent:
        return Icons.error_outline;
      case AdviceSeverity.recommended:
        return Icons.recommend_outlined;
      case AdviceSeverity.optional:
        return Icons.lightbulb_outline;
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
          // ── Header ──────────────────────────────────────────────────────
          InkWell(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FR-26: Icon avatar
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
                        // FR-23: Severity badge
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
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

          // ── Expanded detail — FR-20/FR-21: what to do / avoid / next ───
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

                  // FR-27: Bangla audio player
                  _AudioPlayer(text: widget.advice.audioGuidance),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],

          // FR-24: Pesticide / fertilizer safe-use reminder
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
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
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
}
