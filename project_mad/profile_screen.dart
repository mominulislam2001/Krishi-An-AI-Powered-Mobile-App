import 'package:flutter/material.dart';
import '../models/auth_store.dart';

// FR-03: Allow users to update profile information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _upazilaCtrl;

  final List<String> _allCrops = [
    'Rice', 'Wheat', 'Potato', 'Tomato', 'Jute',
    'Mustard', 'Maize', 'Onion', 'Garlic', 'Lentil',
  ];
  final Map<String, String> _cropBangla = {
    'Rice': 'ধান',    'Wheat': 'গম',     'Potato': 'আলু',
    'Tomato': 'টমেটো','Jute': 'পাট',     'Mustard': 'সরিষা',
    'Maize': 'ভুট্টা','Onion': 'পেঁয়াজ','Garlic': 'রসুন',
    'Lentil': 'মসুর',
  };

  List<String> _selectedCrops = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final user = AuthStore.currentUser ?? {};
    _nameCtrl     = TextEditingController(text: user['name']     ?? '');
    _districtCtrl = TextEditingController(text: user['district'] ?? '');
    _upazilaCtrl  = TextEditingController(text: user['upazila']  ?? '');
    _selectedCrops = List<String>.from(user['crops'] ?? []);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    AuthStore.updateProfile(
      name:     _nameCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      upazila:  _upazilaCtrl.text.trim(),
      crops:    _selectedCrops,
    );
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: const Text("প্রোফাইল আপডেট হয়েছে ✓"),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green.shade700),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.green.shade50,
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900)),
        ],
      );

  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.green.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 6))
          ],
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        title: const Text("আমার প্রোফাইল",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "লগআউট",
            onPressed: () {
              AuthStore.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar banner
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.person,
                          size: 44, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(AuthStore.currentMobile ?? '',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                    if (_saved)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text("প্রোফাইল আপডেট হয়েছে",
                                style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal info
              _sectionHeader("ব্যক্তিগত তথ্য", Icons.person_outline),
              const SizedBox(height: 10),
              _buildCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _inputDecoration(
                          label: "পুরো নাম", icon: Icons.badge_outlined),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "নাম দিন" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _districtCtrl,
                      decoration: _inputDecoration(
                          label: "জেলা",
                          icon: Icons.location_city_outlined),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "জেলার নাম দিন" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _upazilaCtrl,
                      decoration: _inputDecoration(
                          label: "উপজেলা", icon: Icons.map_outlined),
                      validator: (v) =>
                          (v == null || v.isEmpty)
                              ? "উপজেলার নাম দিন"
                              : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Preferred crops
              _sectionHeader("পছন্দের ফসল", Icons.grass),
              const SizedBox(height: 10),
              _buildCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allCrops.map((crop) {
                    final selected = _selectedCrops.contains(crop);
                    return FilterChip(
                      label: Text(_cropBangla[crop]!),
                      selected: selected,
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green.shade800,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                          color: selected
                              ? Colors.green.shade400
                              : Colors.grey.shade300),
                      onSelected: (val) {
                        setState(() {
                          val
                              ? _selectedCrops.add(crop)
                              : _selectedCrops.remove(crop);
                          _saved = false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text("পরিবর্তন সংরক্ষণ করুন",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _districtCtrl.dispose();
    _upazilaCtrl.dispose();
    super.dispose();
  }
}
