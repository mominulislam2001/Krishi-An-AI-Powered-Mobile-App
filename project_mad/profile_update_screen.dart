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
      home: ProfileUpdateScreen(),
    );
  }
}

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: "+8801611655192");

  String? occupation;
  String? gender;
  String? district;

  List<String> selectedCrops = [];

  final occupations = [
    'কৃষক',
    'উদ্যানপালক',
    'কৃষি ব্যবসায়ী',
    'কৃষি কর্মকর্তা',
    'অন্যান্য',
  ];

  final genders = ['পুরুষ', 'মহিলা', 'অন্যান্য'];

  final districts = [
    'ঢাকা',
    'চট্টগ্রাম',
    'রাজশাহী',
    'খুলনা',
    'বরিশাল',
    'সিলেট'
  ];

  final crops = [
    'ধান',
    'গম',
    'ভুট্টা',
    'পাট',
    'আলু',
    'টমেটো',
    'বেগুন',
    'পেঁয়াজ',
  ];

  void updateProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("প্রোফাইল সফলভাবে আপডেট হয়েছে")),
      );
    }
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget textField(TextEditingController controller, String hint,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: (v) {
        if (!readOnly && (v == null || v.isEmpty)) {
          return "এটি পূরণ করুন";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget dropdown(
      String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget cropSelector() {
    return Wrap(
      spacing: 8,
      children: crops.map((crop) {
        final selected = selectedCrops.contains(crop);

        return FilterChip(
          label: Text(crop),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                selectedCrops.add(crop);
              } else {
                selectedCrops.remove(crop);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget profilePhoto() {
    return Stack(
      children: [
        const CircleAvatar(
          radius: 45,
          child: Icon(Icons.person, size: 40),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4EC),

      appBar: AppBar(
        title: const Text("প্রোফাইল তথ্য সম্পাদনা করুন"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Center(child: profilePhoto()),

              const SizedBox(height: 30),

              label("সম্পূর্ণ নাম"),
              textField(_nameController, "আপনার পূর্ণ নাম লিখুন"),

              const SizedBox(height: 20),

              label("পেশা"),
              dropdown(occupation, occupations, (v) {
                setState(() {
                  occupation = v;
                });
              }),

              const SizedBox(height: 20),

              label("লিঙ্গ"),
              dropdown(gender, genders, (v) {
                setState(() {
                  gender = v;
                });
              }),

              const SizedBox(height: 20),

              label("ফোন নম্বর"),
              textField(_phoneController, "", readOnly: true),

              const SizedBox(height: 20),

              label("জেলা"),
              dropdown(district, districts, (v) {
                setState(() {
                  district = v;
                });
              }),

              const SizedBox(height: 20),

              label("পছন্দের ফসল"),
              cropSelector(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("আপডেট"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}