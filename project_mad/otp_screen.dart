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
      home: OtpScreen(),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  int resendSeconds = 60;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() async {
    for (int i = resendSeconds; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        resendSeconds = i;
        if (i == 0) {
          canResend = true;
        }
      });
    }
  }

  String get enteredOtp =>
      otpControllers.map((e) => e.text).join();

  void verifyOtp() async {

    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("সম্পূর্ণ OTP দিন")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP যাচাই সফল")),
    );
  }

  void onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (v) => onDigitEntered(index, v),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.yellow.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    const phoneNumber = "+8801611655192";

    return Scaffold(

      backgroundColor: const Color(0xFFEAF4EC),

      body: SafeArea(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "OTP যাচাই করুন",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "$phoneNumber নম্বরে একটি OTP পাঠানো হয়েছে",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => buildOtpBox(index),
              ),
            ),

            const SizedBox(height: 20),

            canResend
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        resendSeconds = 60;
                        canResend = false;
                      });

                      startTimer();
                    },
                    child: const Text("OTP পুনরায় পাঠান"),
                  )
                : Text("পুনরায় পাঠান $resendSeconds সেকেন্ডে"),

            const SizedBox(height: 30),

            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("যাচাই করুন"),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {},
              child: const Text("ফোন নম্বর পরিবর্তন করুন"),
            )
          ],
        ),
      ),
    );
  }
}