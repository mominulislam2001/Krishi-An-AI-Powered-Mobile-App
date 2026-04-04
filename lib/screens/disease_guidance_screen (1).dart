import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// FR-04: Disease model — Bangla text guidance (symptoms, prevention, actions)
// ---------------------------------------------------------------------------
class DiseaseInfo {
  final String cropType;
  final String diseaseName; // Bangla
  final String symptoms; // FR-04: Bangla symptoms
  final String prevention; // FR-04: Bangla prevention
  final String correctiveActions; // FR-04: Bangla corrective actions
  final String audioGuidance; // FR-05: full Bangla audio text
  final String season;
  final String weather;
  final IconData icon;
  final Color color;

  const DiseaseInfo({
    required this.cropType,
    required this.diseaseName,
    required this.symptoms,
    required this.prevention,
    required this.correctiveActions,
    required this.audioGuidance,
    required this.season,
    required this.weather,
    required this.icon,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// FR-08: Audio player widget — play, pause, replay
// FR-09: Mode switcher — audio ↔ reading without losing context
// ---------------------------------------------------------------------------
class _DiseaseAudioPlayer extends StatefulWidget {
  final String text;
  final bool isReadingMode; // FR-09: current mode
  final VoidCallback onToggleMode; // FR-09: switch mode callback

  const _DiseaseAudioPlayer({
    required this.text,
    required this.isReadingMode,
    required this.onToggleMode,
  });

  @override
  State<_DiseaseAudioPlayer> createState() => _DiseaseAudioPlayerState();
}

class _DiseaseAudioPlayerState extends State<_DiseaseAudioPlayer>
    with SingleTickerProviderStateMixin {
  bool _playing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.18).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // FR-08: play / pause
  void _togglePlay() {
    setState(() => _playing = !_playing);
    // TODO: integrate flutter_tts — call _speak() or _stop()
    if (_playing) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _playing = false);
      });
    }
  }

  // FR-08: replay
  void _replay() {
    setState(() => _playing = true);
    // TODO: call _stop() then _speak() via flutter_tts
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          // FR-08: Play / Pause button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) {
              return Transform.scale(
                scale: _playing ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: IconButton(
              icon: Icon(
                _playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.green.shade700,
                size: 30,
              ),
              tooltip: _playing ? "বিরতি" : "বাংলা অডিও শুনুন",
              onPressed: _togglePlay,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 6),

          // FR-08: Replay button
          IconButton(
            icon:
                Icon(Icons.replay, color: Colors.green.shade600, size: 22),
            tooltip: "পুনরায় শুনুন",
            onPressed: _replay,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),

          // Status label
          Expanded(
            child: Text(
              _playing ? "অডিও চলছে..." : "বাংলা অডিও",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // FR-09: Mode toggle button — audio ↔ reading
          GestureDetector(
            onTap: widget.onToggleMode,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isReadingMode
                        ? Icons.volume_up_rounded
                        : Icons.menu_book_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isReadingMode ? "অডিও মোড" : "পড়ার মোড",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

// ---------------------------------------------------------------------------
// Disease Guidance Screen
// FR-04: Bangla text guidance
// FR-05: Bangla audio guidance
// FR-06: Crop-type selector
// FR-07: Season + weather filter
// FR-08: Audio controls (play, pause, replay)
// FR-09: Audio ↔ reading mode toggle
// ---------------------------------------------------------------------------
class DiseaseGuidanceScreen extends StatefulWidget {
  const DiseaseGuidanceScreen({super.key});

  @override
  State<DiseaseGuidanceScreen> createState() => _DiseaseGuidanceScreenState();
}

class _DiseaseGuidanceScreenState extends State<DiseaseGuidanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // FR-09: global mode — false = audio mode, true = reading mode
  bool _isReadingMode = false;

  // FR-06: selected crop, FR-07: season + weather
  String _selectedCrop = "আলু";
  String _selectedSeason = "বর্ষা";
  String _selectedWeather = "আর্দ্র";

  final List<String> _crops = ["আলু", "টমেটো", "গম", "ধান", "পাট", "ভুট্টা"];
  final List<String> _seasons = ["বর্ষা", "গ্রীষ্ম", "শীত", "শুষ্ক"];
  final List<String> _weathers = [
    "আর্দ্র",
    "রৌদ্রোজ্জ্বল",
    "বৃষ্টি",
    "মেঘলা",
    "কুয়াশা"
  ];

  // Internal key maps matching team's English keys → Bangla labels
  final Map<String, String> _cropKeyMap = {
    "আলু": "Potato",
    "টমেটো": "Tomato",
    "গম": "Wheat",
    "ধান": "Rice",
    "পাট": "Jute",
    "ভুট্টা": "Maize",
  };
  final Map<String, String> _seasonKeyMap = {
    "বর্ষা": "Monsoon",
    "গ্রীষ্ম": "Summer",
    "শীত": "Winter",
    "শুষ্ক": "Dry",
  };
  final Map<String, String> _weatherKeyMap = {
    "আর্দ্র": "Humid",
    "রৌদ্রোজ্জ্বল": "Sunny",
    "বৃষ্টি": "Rainy",
    "মেঘলা": "Cloudy",
    "কুয়াশা": "Foggy",
  };

  // ---------------------------------------------------------------------------
  // FR-04 & FR-05: Full disease dataset in Bangla
  // ---------------------------------------------------------------------------
  final List<DiseaseInfo> _diseases = const [
    // ── আলু ──────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Potato",
      diseaseName: "আলু ব্লাইট (Late Blight)",
      symptoms:
          "পাতায় বাদামি বা কালো ভেজা দাগ, পাতার নিচে সাদা ছত্রাক, কান্ড কালো হয়ে যায়।",
      prevention:
          "সুস্থ বীজ ব্যবহার করুন। ক্ষেতে বায়ু চলাচল নিশ্চিত করুন। রোপণের আগে মেনকোজেব দিয়ে বীজ শোধন করুন।",
      correctiveActions:
          "আক্রান্ত পাতা ও কান্ড কেটে মাটিতে পুঁতুন। সঙ্গে সঙ্গে অনুমোদিত ছত্রাকনাশক (Metalaxyl বা Cymoxanil) স্প্রে করুন। মাস্ক ও গ্লাভস পরে কাজ করুন।",
      audioGuidance:
          "আলু ব্লাইট রোগে পাতায় বাদামি দাগ ও সাদা ছত্রাক দেখা যায়। সুস্থ বীজ ব্যবহার করুন এবং বায়ু চলাচল নিশ্চিত করুন। আক্রান্ত পাতা কেটে মাটিতে পুঁতুন এবং অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
    ),
    DiseaseInfo(
      cropType: "Potato",
      diseaseName: "আলুর স্ক্যাব (Common Scab)",
      symptoms:
          "আলুর খোসায় খসখসে বাদামি বা কর্কী দাগ। আলু বাজারে বিক্রির অযোগ্য হয়।",
      prevention:
          "মাটির pH ৫.০–৫.৫ রাখুন। অতিরিক্ত চুন প্রয়োগ এড়ান। ফসল চক্র মেনে চলুন।",
      correctiveActions:
          "আক্রান্ত মাটিতে সালফার মিশিয়ে pH কমান। পরবর্তী মৌসুমে প্রতিরোধী জাত ব্যবহার করুন।",
      audioGuidance:
          "আলুর স্ক্যাব রোগে খোসায় খসখসে দাগ দেখা যায়। মাটির পিএইচ পাঁচ থেকে সাড়ে পাঁচের মধ্যে রাখুন এবং ফসল চক্র মেনে চলুন।",
      season: "Summer",
      weather: "Sunny",
      icon: Icons.eco,
      color: Colors.orange,
    ),

    // ── টমেটো ────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Tomato",
      diseaseName: "টমেটো আর্লি ব্লাইট",
      symptoms:
          "পাতায় হলুদ রিং সহ বাদামি দাগ, নিচের পাতা প্রথমে আক্রান্ত হয়।",
      prevention:
          "গাছের গোড়ায় মালচিং করুন। ওভারহেড সেচ এড়িয়ে ড্রিপ সেচ ব্যবহার করুন।",
      correctiveActions:
          "আক্রান্ত পাতা সরিয়ে ফেলুন। Chlorothalonil বা Mancozeb স্প্রে করুন। ৭ দিন পর পুনরায় স্প্রে করুন।",
      audioGuidance:
          "টমেটো আর্লি ব্লাইটে পাতায় হলুদ রিং সহ বাদামি দাগ দেখা যায়। মালচিং করুন এবং ড্রিপ সেচ ব্যবহার করুন। আক্রান্ত পাতা সরিয়ে ছত্রাকনাশক স্প্রে করুন।",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
    ),
    DiseaseInfo(
      cropType: "Tomato",
      diseaseName: "টমেটো ফুসারিয়াম উইল্ট",
      symptoms:
          "গাছ হঠাৎ নেতিয়ে পড়ে, কান্ড কাটলে ভেতরে বাদামি দাগ দেখা যায়।",
      prevention:
          "প্রতিরোধী জাত লাগান। জমির পানি নিষ্কাশন নিশ্চিত করুন।",
      correctiveActions:
          "আক্রান্ত গাছ তুলে পুড়িয়ে ফেলুন। মাটি ট্রাইকোডার্মা দিয়ে শোধন করুন।",
      audioGuidance:
          "টমেটো ফুসারিয়াম উইল্টে গাছ হঠাৎ নেতিয়ে পড়ে। প্রতিরোধী জাত ব্যবহার করুন এবং আক্রান্ত গাছ তুলে পুড়িয়ে ফেলুন।",
      season: "Summer",
      weather: "Sunny",
      icon: Icons.eco_outlined,
      color: Colors.orange,
    ),

    // ── গম ───────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Wheat",
      diseaseName: "গমের রাস্ট (Wheat Rust)",
      symptoms:
          "পাতায় ও কান্ডে কমলা-বাদামি গুঁড়া দাগ। রোগ দ্রুত ছড়িয়ে পড়ে।",
      prevention:
          "রাস্ট-প্রতিরোধী জাত ব্যবহার করুন। অতিরিক্ত নাইট্রোজেন সার এড়ান।",
      correctiveActions:
          "Propiconazole বা Tebuconazole ছত্রাকনাশক স্প্রে করুন। সপ্তাহে দুইবার পাতা পরীক্ষা করুন।",
      audioGuidance:
          "গমের রাস্ট রোগে পাতায় কমলা-বাদামি গুঁড়া দাগ দেখা যায়। রাস্ট-প্রতিরোধী জাত ব্যবহার করুন এবং প্রোপিকোনাজোল ছত্রাকনাশক স্প্রে করুন।",
      season: "Dry",
      weather: "Sunny",
      icon: Icons.agriculture,
      color: Colors.orange,
    ),

    // ── ধান ──────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Rice",
      diseaseName: "ধানের ব্লাস্ট রোগ",
      symptoms:
          "পাতায় চোখের মতো ধূসর দাগ, শীষে কালো বা ধূসর রং ধরে। ফলন মারাত্মকভাবে কমে যায়।",
      prevention:
          "সঠিক পরিমাণ পটাশ সার দিন। অতিরিক্ত পানি জমতে দেবেন না।",
      correctiveActions:
          "Tricyclazole বা Isoprothiolane স্প্রে করুন। আক্রান্ত অংশ কেটে মাঠের বাইরে নিয়ে পুড়িয়ে ফেলুন।",
      audioGuidance:
          "ধানের ব্লাস্ট রোগে পাতায় চোখের মতো ধূসর দাগ দেখা যায়। সঠিক পরিমাণ পটাশ সার দিন এবং ট্রাইসাইক্লাজোল স্প্রে করুন।",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.grass,
      color: Colors.teal,
    ),
    DiseaseInfo(
      cropType: "Rice",
      diseaseName: "ধানের বাদামি ঘের পোড়া",
      symptoms:
          "পাতায় বাদামি রঙের ঘের দিয়ে ধূসর কেন্দ্র বিশিষ্ট দাগ।",
      prevention: "সুষম সার ব্যবহার করুন। জমিতে পানির সুষম বণ্টন নিশ্চিত করুন।",
      correctiveActions:
          "Carbendazim বা Mancozeb স্প্রে করুন। ৫ দিন পর পাতার অবস্থা পুনরায় দেখুন।",
      audioGuidance:
          "ধানের বাদামি ঘের পোড়া রোগে পাতায় বাদামি ঘেরা দাগ দেখা যায়। সুষম সার ব্যবহার করুন এবং কার্বেন্ডাজিম স্প্রে করুন।",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.grass,
      color: Colors.teal,
    ),

    // ── পাট ──────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Jute",
      diseaseName: "পাটের স্টেম রট",
      symptoms:
          "কান্ডের গোড়া পচে যায়, গাছ হেলে পড়ে এবং পাতা হলুদ হয়।",
      prevention:
          "বীজ বপনের আগে Thiram দিয়ে শোধন করুন। জমিতে পানি না জমতে দিন।",
      correctiveActions:
          "আক্রান্ত গাছ উপড়ে ফেলুন। মাটিতে চুন প্রয়োগ করুন।",
      audioGuidance:
          "পাটের স্টেম রট রোগে কান্ডের গোড়া পচে যায়। বীজ বপনের আগে থিরাম দিয়ে শোধন করুন এবং জমিতে পানি না জমতে দিন।",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.park,
      color: Colors.green,
    ),

    // ── ভুট্টা ────────────────────────────────────────────────────────────
    DiseaseInfo(
      cropType: "Maize",
      diseaseName: "ভুট্টার পাতার ঝলসা রোগ",
      symptoms:
          "পাতায় লম্বা বাদামি ডোরাকাটা দাগ, গাছ দুর্বল হয়ে পড়ে।",
      prevention:
          "প্রতিরোধী হাইব্রিড জাত ব্যবহার করুন। ফসল কাটার পর জমির অবশিষ্টাংশ পুড়িয়ে ফেলুন।",
      correctiveActions:
          "Propiconazole স্প্রে করুন। সেচ ব্যবস্থাপনা উন্নত করুন।",
      audioGuidance:
          "ভুট্টার পাতার ঝলসা রোগে পাতায় লম্বা বাদামি ডোরাকাটা দাগ দেখা যায়। প্রতিরোধী হাইব্রিড জাত ব্যবহার করুন এবং প্রোপিকোনাজোল স্প্রে করুন।",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.grain,
      color: Colors.amber,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DiseaseInfo> get _filtered {
    final cropKey = _cropKeyMap[_selectedCrop] ?? "";
    final seasonKey = _seasonKeyMap[_selectedSeason] ?? "";
    final weatherKey = _weatherKeyMap[_selectedWeather] ?? "";
    return _diseases.where((d) {
      return d.cropType == cropKey &&
          d.season == seasonKey &&
          d.weather == weatherKey;
    }).toList();
  }

  // FR-09: toggle reading ↔ audio mode globally (state preserved)
  void _toggleMode() => setState(() => _isReadingMode = !_isReadingMode);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "রোগের গাইড",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        // FR-09: mode indicator badge in AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _toggleMode,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isReadingMode
                          ? Icons.menu_book_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isReadingMode ? "পড়ার মোড" : "অডিও মোড",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.medical_information_outlined), text: "লক্ষণ"),
            Tab(icon: Icon(Icons.shield_outlined), text: "প্রতিরোধ"),
            Tab(icon: Icon(Icons.healing_outlined), text: "চিকিৎসা"),
          ],
        ),
      ),
      body: Column(
        children: [
          // FR-06 + FR-07: Filter bar
          _buildFilterBar(),
          // Tab content
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1 — FR-04: symptoms
                      _buildDiseaseList(
                          filtered, _DiseaseTab.symptoms),
                      // Tab 2 — FR-04: prevention
                      _buildDiseaseList(
                          filtered, _DiseaseTab.prevention),
                      // Tab 3 — FR-04: corrective actions
                      _buildDiseaseList(
                          filtered, _DiseaseTab.corrective),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // FR-06 + FR-07: Filter bar
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
              value: _selectedCrop,
              items: _crops,
              onChanged: (v) => setState(() => _selectedCrop = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdown(
              icon: Icons.calendar_month,
              label: "মৌসুম",
              value: _selectedSeason,
              items: _seasons,
              onChanged: (v) => setState(() => _selectedSeason = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdown(
              icon: Icons.wb_cloudy_outlined,
              label: "আবহাওয়া",
              value: _selectedWeather,
              items: _weathers,
              onChanged: (v) => setState(() => _selectedWeather = v!),
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
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDiseaseList(List<DiseaseInfo> list, _DiseaseTab tab) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) => _DiseaseCard(
        disease: list[i],
        tab: tab,
        isReadingMode: _isReadingMode, // FR-09
        onToggleMode: _toggleMode, // FR-09
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: Colors.green.shade200),
          const SizedBox(height: 12),
          Text(
            "এই ফসল/মৌসুম/আবহাওয়ায় কোনো রোগের তথ্য পাওয়া যায়নি",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Which tab is active — determines what body text to show (FR-04)
enum _DiseaseTab { symptoms, prevention, corrective }

// ---------------------------------------------------------------------------
// Disease Card
// FR-04: Shows symptoms / prevention / corrective actions in Bangla text
// FR-05: Bangla audio player inside card
// FR-08: Play, pause, replay inside card
// FR-09: Mode switch without losing card expand state
// ---------------------------------------------------------------------------
class _DiseaseCard extends StatefulWidget {
  final DiseaseInfo disease;
  final _DiseaseTab tab;
  final bool isReadingMode; // FR-09
  final VoidCallback onToggleMode; // FR-09

  const _DiseaseCard({
    required this.disease,
    required this.tab,
    required this.isReadingMode,
    required this.onToggleMode,
  });

  @override
  State<_DiseaseCard> createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<_DiseaseCard> {
  bool _expanded = false; // FR-09: preserve on mode switch

  String get _tabTitle {
    switch (widget.tab) {
      case _DiseaseTab.symptoms:
        return "লক্ষণ";
      case _DiseaseTab.prevention:
        return "প্রতিরোধ";
      case _DiseaseTab.corrective:
        return "প্রতিকার";
    }
  }

  String get _tabBody {
    switch (widget.tab) {
      case _DiseaseTab.symptoms:
        return widget.disease.symptoms;
      case _DiseaseTab.prevention:
        return widget.disease.prevention;
      case _DiseaseTab.corrective:
        return widget.disease.correctiveActions;
    }
  }

  IconData get _tabIcon {
    switch (widget.tab) {
      case _DiseaseTab.symptoms:
        return Icons.medical_information_outlined;
      case _DiseaseTab.prevention:
        return Icons.shield_outlined;
      case _DiseaseTab.corrective:
        return Icons.healing_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.disease.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.withOpacity(0.25)),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          InkWell(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: c.withOpacity(0.12),
                    child: Icon(widget.disease.icon, color: c, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_tabIcon, size: 13, color: c),
                              const SizedBox(width: 4),
                              Text(
                                _tabTitle,
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
                          widget.disease.diseaseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: c,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // FR-09: Show first line of relevant section as preview
                        Text(
                          _tabBody.split('।').first + ((_tabBody.contains('।')) ? '।' : ''),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

          // ── Expanded detail ───────────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FR-09: Reading mode → show full text; Audio mode → show audio player
                  if (widget.isReadingMode) ...[
                    // FR-04: Full Bangla text guidance
                    _sectionHeader(_tabIcon, _tabTitle, c),
                    const SizedBox(height: 6),
                    Text(
                      _tabBody,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Still show audio player so user can switch back (FR-09)
                    _DiseaseAudioPlayer(
                      text: widget.disease.audioGuidance,
                      isReadingMode: widget.isReadingMode,
                      onToggleMode: widget.onToggleMode,
                    ),
                  ] else ...[
                    // FR-05: Audio mode — prominent player + text below
                    _DiseaseAudioPlayer(
                      text: widget.disease.audioGuidance,
                      isReadingMode: widget.isReadingMode,
                      onToggleMode: widget.onToggleMode,
                    ),
                    const SizedBox(height: 12),
                    // FR-04: Bangla text still shown below audio (FR-09: context kept)
                    _sectionHeader(_tabIcon, _tabTitle, c),
                    const SizedBox(height: 6),
                    Text(
                      _tabBody,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],

          // Safety reminder for corrective tab (matches team pattern FR-24)
          if (_expanded && widget.tab == _DiseaseTab.corrective)
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
                  Icon(Icons.security,
                      size: 16, color: Colors.red.shade700),
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

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}