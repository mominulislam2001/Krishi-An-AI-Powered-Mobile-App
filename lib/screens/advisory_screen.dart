import 'package:flutter/material.dart';
import '../models/advice_model.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  // ----------------------
  // Data
  // ----------------------
  final List<AgriAdvice> advices = [
    // Preventive
    AgriAdvice(
      title: "ব্লাইট রোগ প্রতিরোধ",
      description:
          "আবহাওয়া আর্দ্র থাকায় আলু ক্ষেতে ব্লাইট দেখা দিতে পারে। আজ ওভারহেড জল দেওয়া এড়ান।",
      severity: AdviceSeverity.recommended,
      cropType: "Potato",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
    ),
    AgriAdvice(
      title: "সঠিক সেচ পদ্ধতি",
      description:
          "বিকেলের পর সেচ দিলে পানির অপচয় কম হয় এবং গাছের বৃদ্ধি ভালো হয়।",
      severity: AdviceSeverity.recommended,
      cropType: "Potato",
      season: "Summer",
      weather: "Sunny",
      icon: Icons.water_drop_outlined,
    ),
    AgriAdvice(
      title: "গমের রোস্ট প্রতিরোধ",
      description: "শুষ্ক আবহাওয়ায় নিয়মিত পর্যবেক্ষণ করুন।",
      severity: AdviceSeverity.recommended,
      cropType: "Wheat",
      season: "Dry",
      weather: "Sunny",
      icon: Icons.agriculture,
    ),
    AgriAdvice(
      title: "টমেটো ব্লাইট প্রতিরোধ",
      description:
          "বৃষ্টি বেশি হলে মাটিতে ফাংগাসের ঝুঁকি বাড়ে। তাই আজ গাছের পাতা শুকনো রাখুন।",
      severity: AdviceSeverity.recommended,
      cropType: "Tomato",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.eco,
    ),
    AgriAdvice(
      title: "ধানের পাতার দাগ প্রতিরোধ",
      description:
          "আর্দ্র আবহাওয়ায় নিয়মিত পর্যবেক্ষণ করুন এবং অতিরিক্ত পানি এড়ান।",
      severity: AdviceSeverity.recommended,
      cropType: "Rice",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.grass,
    ),

    // Corrective (All will show)
    AgriAdvice(
      title: "রোগ শনাক্তকরণ: ব্লাইট",
      description:
          "পাতায় দাগ দেখা যাচ্ছে। এখনই ছত্রাকনাশক স্প্রে করুন এবং ক্ষতিগ্রস্ত অংশ কেটে ফেলুন।",
      severity: AdviceSeverity.urgent,
      cropType: "Potato",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
    ),
    AgriAdvice(
      title: "টমেটো ব্লাইট শনাক্তকরণ",
      description:
          "পাতায় হলুদ দাগ দেখা যাচ্ছে। এখনই অনুমোদিত ছত্রাকনাশক স্প্রে করুন।",
      severity: AdviceSeverity.urgent,
      cropType: "Tomato",
      season: "Monsoon",
      weather: "Rainy",
      icon: Icons.warning_amber_rounded,
    ),
    AgriAdvice(
      title: "ধানের পাতার দাগ শনাক্তকরণ",
      description:
          "পাতায় দাগ দেখা যাচ্ছে। আক্রান্ত অংশ কেটে নিন এবং নিয়মিত ছত্রাকনাশক ব্যবহার করুন।",
      severity: AdviceSeverity.urgent,
      cropType: "Rice",
      season: "Monsoon",
      weather: "Humid",
      icon: Icons.warning_amber_rounded,
    ),
  ];

  // ----------------------
  // Bangla Mapping
  // ----------------------
  final Map<String, String> cropMap = {
    "Potato": "আলু",
    "Tomato": "টমেটো",
    "Wheat": "গম",
    "Rice": "ধান",
  };

  final Map<String, String> seasonMap = {
    "Monsoon": "বর্ষা",
    "Summer": "গ্রীষ্ম",
    "Dry": "শুষ্ক",
  };

  final Map<String, String> weatherMap = {
    "Humid": "আর্দ্র",
    "Sunny": "রৌদ্রোজ্জ্বল",
    "Rainy": "বৃষ্টি",
  };

  // ----------------------
  // State
  // ----------------------
  String selectedCrop = "Potato";
  String selectedSeason = "Monsoon";
  String selectedWeather = "Humid";

  final List<String> crops = ["Potato", "Tomato", "Wheat", "Rice"];
  final List<String> seasons = ["Monsoon", "Summer", "Dry"];
  final List<String> weathers = ["Humid", "Sunny", "Rainy"];

  @override
  Widget build(BuildContext context) {
    // Only preventive tab uses filters
    List<AgriAdvice> filteredPreventive = advices.where((advice) {
      return advice.severity == AdviceSeverity.recommended &&
          advice.cropType == selectedCrop &&
          advice.season == selectedSeason &&
          advice.weather == selectedWeather;
    }).toList();

    // Corrective tab shows all urgent advices
    List<AgriAdvice> correctiveAdvices =
        advices.where((advice) => advice.severity == AdviceSeverity.urgent).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("কৃষি পরামর্শ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "প্রতিরোধমূলক"),
            Tab(text: "কার্যকরী"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ----------------------
          // Preventive tab with filters
          // ----------------------
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCrop,
                        decoration: const InputDecoration(labelText: "ফসল"),
                        items: crops.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(cropMap[c]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedCrop = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSeason,
                        decoration: const InputDecoration(labelText: "মৌসুম"),
                        items: seasons.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(seasonMap[s]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedSeason = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedWeather,
                        decoration: const InputDecoration(labelText: "আবহাওয়া"),
                        items: weathers.map((w) {
                          return DropdownMenuItem(
                            value: w,
                            child: Text(weatherMap[w]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedWeather = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: buildList(filteredPreventive)),
            ],
          ),

          // ----------------------
          // Corrective tab without filters
          // ----------------------
          buildList(correctiveAdvices),
        ],
      ),
    );
  }

  // ----------------------
  // List Builder
  // ----------------------
  Widget buildList(List<AgriAdvice> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text("কোনো পরামর্শ পাওয়া যায়নি"),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: list.map((a) => AdviceCard(advice: a)).toList(),
    );
  }
}

// ----------------------
// Advice Card
// ----------------------
class AdviceCard extends StatelessWidget {
  final AgriAdvice advice;

  const AdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    Color severityColor = advice.severity == AdviceSeverity.urgent
        ? Colors.red
        : Colors.teal;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: severityColor.withOpacity(0.1),
              child: Icon(advice.icon, color: severityColor),
            ),
            title: Text(advice.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: severityColor)),
            subtitle: Text(advice.description),
          ),
          if (advice.severity == AdviceSeverity.urgent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "সতর্কতা: কীটনাশক ব্যবহারের সময় মাস্ক পরুন",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}