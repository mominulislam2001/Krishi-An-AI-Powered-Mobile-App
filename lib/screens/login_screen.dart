import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/auth_store.dart';

// FR-02: Authenticate users before granting access to the dashboard
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _obscure     = true;
  String? _error;

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final ok = AuthStore.login(_mobileCtrl.text.trim(), _passCtrl.text);
    if (!ok) {
      setState(() => _error = "মোবাইল নম্বর বা পাসওয়ার্ড ভুল");
      return;
    }
    // FR-02: Only on success, navigate to dashboard
    Navigator.pushReplacementNamed(context, '/');
  }

  // Demo login — registers + logs in a test account instantly
  void _demoLogin() {
    AuthStore.register('01712345678', 'demo123');
    AuthStore.updateProfile(
      name: 'আবদুল করিম',
      district: 'ঢাকা',
      upazila: 'সাভার',
      crops: ['Rice', 'Potato'],
    );
    AuthStore.login('01712345678', 'demo123');
    Navigator.pushReplacementNamed(context, '/');
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Stack(
        children: [
          // Green header
          Container(
            height: 220,
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
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.agriculture, color: Colors.white, size: 50),
                  SizedBox(height: 8),
                  Text(
                    "কৃষি",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "আপনার ফসলের জন্য সেরা পরামর্শ",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Form card
          Padding(
            padding: const EdgeInsets.only(top: 175),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "লগইন",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _mobileCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: _inputDecoration(
                            label: "মোবাইল নম্বর",
                            hint: "01XXXXXXXXX",
                            icon: Icons.phone_android_rounded,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "মোবাইল নম্বর দিন"
                              : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration(
                            label: "পাসওয়ার্ড",
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "পাসওয়ার্ড দিন"
                              : null,
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13)),
                        ],

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("লগইন করুন",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Quick demo login
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _demoLogin,
                            icon: Icon(Icons.flash_on,
                                color: Colors.green.shade700),
                            label: Text("ডেমো লগইন",
                                style:
                                    TextStyle(color: Colors.green.shade700)),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: Colors.green.shade400),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("অ্যাকাউন্ট নেই? "),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/register'),
                              child: Text("নিবন্ধন করুন",
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
