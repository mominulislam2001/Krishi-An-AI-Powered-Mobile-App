import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; 

class DiseaseGuidanceScreen extends StatefulWidget {
  const DiseaseGuidanceScreen({super.key});

  @override
  State<DiseaseGuidanceScreen> createState() => _DiseaseGuidanceScreenState();
}

class _DiseaseGuidanceScreenState extends State<DiseaseGuidanceScreen> {
  int? _selectedDiseaseIndex;
  String _searchQuery = '';
  String _selectedCrop = 'সব';
  
  // Audio Controls State (FR-08, FR-09)
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isAudioMode = false; // Toggle between Reading and Audio mode

  final List<String> _cropFilters = [
    'সব',
    'ধান',
    'সবজি',
    'ডাল',
    'গম',
    'আলু',
  ];

  // The original list remains unchanged as per instructions
  final List<Map<String, dynamic>> _diseases = [
    {
      'name': 'হোয়াইট মোল্ড রোগ',
      'crop': 'সবজি',
      'cropTag': 'সয়াবিন / সবজি',
      'icon': '🍃',
      'color': const Color(0xFF2E7D32),
      'imageUrl': 'assets/images/white_mould_soyabean1.jpg',
      'cause': 'ছত্রাকের আক্রমণে এ রোগ হয়।',
      'symptoms': 'পাতার বোটায়, কাণ্ডে ও ফলে সাদা তুলার মত বস্তু দেখা যায়। আক্রান্ত অংশ পচে যায় এবং গাছ দুর্বল হয়ে পড়ে।',
      'management': [
        'রৌদ্রযুক্ত উচু স্থানে বীজতলা তৈরী করুন।',
        'বীজ বপনের আগে গভীরভাবে চাষ দিয়ে জমি তৈরী করুন।',
        'বীজতলায় বীজ বপনের ১৫ দিন আগে শতাংশ প্রতি ৮৫ গ্রাম হারে স্ট্যাবল ব্লিচিং পাউডার ছাই বা বালির সাথে মিশিয়ে ছিটিয়ে দিন।',
        'প্লাবন সেচের পরিবর্তে স্প্রিংলার সেচ দিন।',
        'আক্রান্ত ফল, পাতা ও ডগা অপসারণ করুন।',
        'আক্রান্ত জমিতে ছত্রাকনাশক ১০ দিন পরপর ৩ বার বিকেলে স্প্রে করুন।',
      ],
      'chemicals': [
        {'name': 'মেনকোজেব ৫০% + ফেনামিডন ১০%', 'dose': '১ কেজি / হেক্টর : সিকিউর ৬০০ ডিব্লিউজি (বায়ার)'},
        {'name': 'প্রপিকোনাজল ২৫০ ইসি', 'dose': '৫০০ মিলিলিটার/হেক্টর : টিল্ট (সিনজেন্টা)'},
      ],
      'warning': 'স্প্রে করার পর ১৫ দিনের মধ্যে সেই সবজি খাবেন না বা বিক্রি করবেন না।',
    },
    {
      'name': 'ধানের ব্লাস্ট রোগ',
      'crop': 'ধান',
      'cropTag': 'ধান',
      'icon': '🌾',
      'color': const Color(0xFF558B2F),
      'imageUrl': 'assets/images/dhaner_blast_rog.jpg',
      'cause': 'Magnaporthe oryzae ছত্রাক দ্বারা এ রোগ হয়।',
      'symptoms': 'পাতায় চোখের মতো বা মাকু আকৃতির বাদামি দাগ পড়ে। দাগের কেন্দ্র ধূসর-সাদা এবং কিনারা বাদামি রঙের হয়। ঘাড় পচে গেলে শীষ ভেঙে পড়ে।',
      'management': [
        'রোগ প্রতিরোধী জাত চাষ করুন।',
        'সুষম সার ব্যবহার করুন, অতিরিক্ত নাইট্রোজেন পরিহার করুন।',
        'বীজ শোধন করে বপন করুন।',
        'আক্রান্ত জমিতে সেচ বন্ধ রাখুন।',
        'রোগ দেখা দিলে ছত্রাকনাশক স্প্রে করুন।',
      ],
      'chemicals': [
        {'name': 'ট্রাইসাইক্লাজল ৭৫% WP', 'dose': '০.৬ গ্রাম/লিটার পানি : ব্লাস্টিন (এসিআই)'},
        {'name': 'কার্বেন্ডাজিম ৫০% WP', 'dose': '১ গ্রাম/লিটার পানি'},
      ],
      'warning': 'রোগের প্রথম পর্যায়ে স্প্রে করলে সবচেয়ে ভালো ফল পাওয়া যায়।',
    },
    {
      'name': 'আলুর লেট ব্লাইট',
      'crop': 'আলু',
      'cropTag': 'আলু',
      'icon': '🥔',
      'color': const Color(0xFF6D4C41),
      'imageUrl': 'assets/images/potato_blight.jpeg',
      'cause': 'Phytophthora infestans নামক ছত্রাক জাতীয় জীবাণু দ্বারা এ রোগ হয়।',
      'symptoms': 'পাতায় পানি ভেজা বাদামি দাগ পড়ে, যা দ্রুত বড় হয়। পাতার নিচে সাদা ছত্রাকের আবরণ দেখা যায়। ঠান্ডা ও ভেজা আবহাওয়ায় রোগ দ্রুত ছড়ায়।',
      'management': [
        'রোগমুক্ত বীজআলু ব্যবহার করুন।',
        'শস্য পর্যায় মেনে চলুন।',
        'জমিতে পানি জমতে না দেওয়া নিশ্চিত করুন।',
        'আক্রান্ত গাছের অংশ সংগ্রহ করে মাটিতে পুঁতে ফেলুন।',
        'মেঘলা ও কুয়াশার সময় প্রতিরোধমূলক স্প্রে দিন।',
      ],
      'chemicals': [
        {'name': 'মেনকোজেব ৮০% WP', 'dose': '২ গ্রাম/লিটার পানি : ডাইথেন M-45'},
        {'name': 'সাইমোক্সানিল + মেনকোজেব', 'dose': '২.৫ গ্রাম/লিটার পানি : কার্জেব (বায়ার)'},
      ],
      'warning': 'আক্রমণ শুরু হলে ৭ দিন পরপর স্প্রে করুন। ফসল তোলার ১৪ দিন আগে স্প্রে বন্ধ করুন।',
    },
    {
      'name': 'মসুরের স্টেম ফ্লাই',
      'crop': 'ডাল',
      'cropTag': 'মসুর / ডাল',
      'icon': '🌿',
      'color': const Color(0xFF00695C),
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Agromyzid_fly.jpg/640px-Agromyzid_fly.jpg',
      'cause': 'Melanagromyza sojae পোকার আক্রমণে এ রোগ হয়।',
      'symptoms': 'আক্রান্ত গাছের কান্ড হলুদ হয়ে শুকিয়ে যায়। কান্ড কেটে দেখলে ভেতরে পোকার সুড়ঙ্গ দেখা যায়। চারা অবস্থায় আক্রমণ হলে গাছ মারা যায়।',
      'management': [
        'আগাম বপন পরিহার করুন।',
        'বীজ শোধন করে বপন করুন।',
        'ফসল কাটার পর অবশিষ্টাংশ পুড়িয়ে ফেলুন।',
        'শস্য পর্যায় মেনে চলুন।',
        'আক্রান্ত গাছ উঠিয়ে নষ্ট করুন।',
      ],
      'chemicals': [
        {'name': 'ইমিডাক্লোপ্রিড ৭০% WS', 'dose': '৫ গ্রাম/কেজি বীজ শোধনে'},
        {'name': 'কার্বোফুরান ৫% G', 'dose': '১০ কেজি/হেক্টর মাটিতে প্রয়োগ'},
      ],
      'warning': 'কীটনাশক ব্যবহারের সময় হাত-মুখ ঢেকে রাখুন এবং পরে সাবান দিয়ে ধুয়ে ফেলুন।',
    },
    {
      'name': 'গমের মরিচা রোগ',
      'crop': 'গম',
      'cropTag': 'গম',
      'icon': '🌱',
      'color': const Color(0xFFE65100),
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Wheat_leaf_rust.jpg/640px-Wheat_leaf_rust.jpg',
      'cause': 'Puccinia triticina ছত্রাক দ্বারা পাতার মরিচা এবং Puccinia graminis দ্বারা কান্ডের মরিচা হয়।',
      'symptoms': 'পাতায় ও কান্ডে মরিচার মতো কমলা-লাল বা কালো গুঁড়া দেখা যায়। আক্রান্ত পাতা হলুদ হয়ে শুকিয়ে যায়। দানা চিটা হয়ে ফলন কমে যায়।',
      'management': [
        'রোগ প্রতিরোধী জাত ব্যবহার করুন।',
        'সময়মতো বপন করুন (নভেম্বর মাসে)।',
        'অতিরিক্ত নাইট্রোজেন সার পরিহার করুন।',
        'রোগের লক্ষণ দেখা দিলে সঙ্গে সঙ্গে ছত্রাকনাশক স্প্রে করুন।',
      ],
      'chemicals': [
        {'name': 'প্রপিকোনাজল ২৫% EC', 'dose': '০.৫ মিলি/লিটার পানি : টিল্ট ২৫০ EC'},
        {'name': 'টেবুকোনাজল ২৫০ EW', 'dose': '১ মিলি/লিটার পানি : ফলিকুর'},
      ],
      'warning': 'গম পাকার ৩০ দিন আগে স্প্রে বন্ধ করুন।',
    },
    {
      'name': 'টমেটোর আর্লি ব্লাইট',
      'crop': 'সবজি',
      'cropTag': 'টমেটো / সবজি',
      'icon': '🍅',
      'color': const Color(0xFFC62828),
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Alternaria_solani_on_tomato.jpg/640px-Alternaria_solani_on_tomato.jpg',
      'cause': 'Alternaria solani ছত্রাক দ্বারা এ রোগ হয়।',
      'symptoms': 'পুরনো পাতায় বাদামি গোলাকার দাগ পড়ে, যার কেন্দ্রে কালো বলয় থাকে। আক্রমণ বাড়লে পাতা ঝরে পড়ে। ফলেও কালো দাগ পড়ে।',
      'management': [
        'রোগমুক্ত বীজ ব্যবহার করুন।',
        'শস্য পর্যায় মেনে চলুন।',
        'গাছের নিচের আক্রান্ত পাতা সরিয়ে ফেলুন।',
        'সেচের পানি গাছের গোড়ায় দিন, পাতায় না দিন।',
        'জমিতে সুষম সার ব্যবহার করুন।',
      ],
      'chemicals': [
        {'name': 'ক্লোরোথ্যালোনিল ৭৫% WP', 'dose': '২ গ্রাম/লিটার পানি : ডাকোনিল'},
        {'name': 'ইপ্রোডিয়ন ৫০% WP', 'dose': '১.৫ গ্রাম/লিটার পানি : রোভরাল'},
      ],
      'warning': 'ফল তোলার ৭ দিন আগে স্প্রে বন্ধ করুন।',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // FR-05 & FR-08: Setup Audio Guidance
  void _initTts() {
    _flutterTts.setLanguage("bn-BD");
    _flutterTts.setStartHandler(() => setState(() => _isPlaying = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isPlaying = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isPlaying = false));
  }

  Future<void> _speak(Map<String, dynamic> disease) async {
    String text = "${disease['name']}। কারণ: ${disease['cause']}। লক্ষণ: ${disease['symptoms']}।";
    await _flutterTts.speak(text);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  // FR-07: Adjust list based on season/weather risk (Simulation)
  List<Map<String, dynamic>> get _filteredDiseases {
    List<Map<String, dynamic>> list = _diseases.where((d) {
      final matchesCrop = _selectedCrop == 'সব' || d['crop'] == _selectedCrop;
      final matchesSearch = _searchQuery.isEmpty ||
          d['name'].toString().contains(_searchQuery) ||
          d['cropTag'].toString().contains(_searchQuery);
      return matchesCrop && matchesSearch;
    }).toList();

    // FR-07 Logic: High risk for Late Blight if weather is cold/foggy (Simulated)
    // In a real app, this would fetch weather API data.
    bool isFoggyWeather = true; 
    if (isFoggyWeather) {
      list.sort((a, b) => a['name'].contains('ব্লাইট') ? -1 : 1);
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('ফসলের রোগ গাইড', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        actions: _selectedDiseaseIndex != null ? [
          // FR-09: Switch between Audio and Reading mode
          IconButton(
            icon: Icon(_isAudioMode ? Icons.menu_book : Icons.audiotrack),
            onPressed: () {
              setState(() => _isAudioMode = !_isAudioMode);
              if (!_isAudioMode) _stop();
            },
            tooltip: "মোড পরিবর্তন করুন",
          )
        ] : null,
      ),
      body: _selectedDiseaseIndex == null
          ? _buildDiseaseList()
          : _buildDiseaseDetail(_filteredDiseases[_selectedDiseaseIndex!]),
    );
  }

  Widget _buildDiseaseList() {
    final filtered = _filteredDiseases;
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('কোনো রোগ পাওয়া যায়নি', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildDiseaseCard(filtered[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'রোগের নাম খুঁজুন...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D32)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _cropFilters.map((crop) {
                final selected = _selectedCrop == crop;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCrop = crop),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(crop, style: TextStyle(color: selected ? const Color(0xFF2E7D32) : Colors.white, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease, int index) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedDiseaseIndex = index;
        _isAudioMode = false; // Default to reading mode
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              child: Image.network(
                disease['imageUrl'],
                width: 100, height: 90, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 100, height: 90, color: (disease['color'] as Color).withOpacity(0.15), child: Center(child: Text(disease['icon'], style: const TextStyle(fontSize: 32)))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: (disease['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(disease['cropTag'], style: TextStyle(fontSize: 11, color: disease['color'] as Color, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(disease['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    const SizedBox(height: 4),
                    Text(disease['cause'], style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDetail(Map<String, dynamic> disease) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
                  _stop();
                  setState(() => _selectedDiseaseIndex = null);
                }),
                Expanded(child: Text(disease['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // FR-08: Audio Player Controls if in Audio Mode
          if (_isAudioMode) _buildAudioControlPanel(disease),

          Image.network(
            disease['imageUrl'],
            width: double.infinity, height: 200, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: double.infinity, height: 180, color: (disease['color'] as Color).withOpacity(0.15), child: Center(child: Text(disease['icon'], style: const TextStyle(fontSize: 64)))),
          ),

          // FR-04: Text Guidance (Reading Mode)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(icon: Icons.help_outline, label: 'রোগের কারণঃ', color: const Color(0xFF1565C0), bgColor: const Color(0xFFE3F2FD)),
                const SizedBox(height: 8),
                _buildInfoCard(disease['cause']),
                const SizedBox(height: 16),
                _buildSectionHeader(icon: Icons.medical_services_outlined, label: 'রোগের লক্ষণঃ', color: const Color(0xFF6A1B9A), bgColor: const Color(0xFFF3E5F5)),
                const SizedBox(height: 8),
                _buildInfoCard(disease['symptoms']),
                const SizedBox(height: 16),
                _buildSectionHeader(icon: Icons.shield_outlined, label: 'দমন ব্যবস্থাপনাঃ', color: const Color(0xFF2E7D32), bgColor: const Color(0xFFE8F5E9)),
                const SizedBox(height: 8),
                _buildCheckList(disease['management'] as List<String>),
                const SizedBox(height: 16),
                _buildSectionHeader(icon: Icons.science_outlined, label: 'রাসায়নিক দমনঃ', color: const Color(0xFFBF360C), bgColor: const Color(0xFFFBE9E7)),
                const SizedBox(height: 8),
                ...(disease['chemicals'] as List<Map<String, dynamic>>).map((chem) => _buildChemicalCard(chem)),
                const SizedBox(height: 16),
                _buildWarningCard(disease['warning']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FR-08: Audio control interface
  Widget _buildAudioControlPanel(Map<String, dynamic> disease) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.replay, color: Colors.green), onPressed: () => _speak(disease)),
          const SizedBox(width: 20),
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 25,
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              onPressed: () => _isPlaying ? _stop() : _speak(disease),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(icon: const Icon(Icons.stop, color: Colors.red), onPressed: _stop),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String label, required Color color, required Color bgColor}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
    );
  }

  Widget _buildCheckList(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: const TextStyle(fontSize: 14, height: 1.5))),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildChemicalCard(Map<String, dynamic> chem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFFCCBC)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFBE9E7), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sanitizer_outlined, color: Color(0xFFBF360C), size: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(chem['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFBF360C))),
          const SizedBox(height: 3),
          Text(chem['dose'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ])),
      ]),
    );
  }

  Widget _buildWarningCard(String warning) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10), border: const Border(left: BorderSide(color: Color(0xFFF9A825), width: 4))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFFF9A825), size: 20),
        const SizedBox(width: 8),
        Expanded(child: RichText(text: TextSpan(children: [
          const TextSpan(text: 'বিশেষ দ্রষ্টব্যঃ ', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13)),
          TextSpan(text: warning, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ]))),
      ]),
    );
  }
}
