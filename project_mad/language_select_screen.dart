import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LanguageSelectScreen(),
    );
  }
}

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {

  String selectedLanguage = "bn";

  void proceed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == "bn"
              ? "বাংলা নির্বাচন করা হয়েছে"
              : "English Selected",
        ),
      ),
    );
  }

  Widget languageOption(String label, String value) {

    bool selected = selectedLanguage == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = value;
        });
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),

        child: Row(
          children: [

            Container(
              width: 24,
              height: 24,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),

              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFEAF4EC),

      body: SafeArea(

        child: Column(

          children: [

            const SizedBox(height: 40),

            const Text(
              "Krishi",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "কৃষিী বাংলাদেশের প্রথম AI চালিত ডিজিটাল কৃষি প্ল্যাটফর্ম। কৃষকদের ফসলের স্বাস্থ্য ও উৎপাদন বৃদ্ধিতে সাহায্য করে।",
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "ভাষা নির্বাচন করুন",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 30),

                    languageOption("English", "en"),

                    languageOption("বাংলা", "bn"),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: proceed,
                        child: const Text("পরবর্তী"),
                      ),
                    )
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