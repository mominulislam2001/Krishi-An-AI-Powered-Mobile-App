import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'preventive_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final List<String> _cropOptions = [
    "আলু",
    "টমেটো",
    "গম",
    "ধান",
    "পাট",
    "ভুট্টা",
  ];

  Widget _buildCropCard(String crop) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaptureGuideScreen(cropName: crop),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.green.shade50,
                child: Icon(
                  Icons.eco_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                crop,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "ছবি দিন",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2F8),
      appBar: AppBar(
        title: const Text(
          "রোগ শনাক্তকরণ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 48,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ফসল নির্বাচন করে ছবি দিন",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ফসল নির্বাচন করুন",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cropOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                return _buildCropCard(_cropOptions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CaptureGuideScreen extends StatefulWidget {
  final String cropName;

  const CaptureGuideScreen({
    super.key,
    required this.cropName,
  });

  @override
  State<CaptureGuideScreen> createState() => _CaptureGuideScreenState();
}

class _CaptureGuideScreenState extends State<CaptureGuideScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  bool _isLoading = false;
  String? _errorText;

  final Map<String, Map<String, dynamic>> _demoResults = {
    "টমেটো": {
      "class": "টমেটো আর্লি ব্লাইট",
      "confidence": 0.91,
    },
    "গম": {
      "class": "গমের রাস্ট রোগ",
      "confidence": 0.89,
    },
    "ধান": {
      "class": "ধানের ব্লাস্ট রোগ",
      "confidence": 0.93,
    },
    "পাট": {
      "class": "পাটের স্টেম রট",
      "confidence": 0.87,
    },
    "ভুট্টা": {
      "class": "ভুট্টার পাতার ঝলসা রোগ",
      "confidence": 0.90,
    },
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }

      setState(() {
        _pickedImage = image;
        _webImageBytes = bytes;
        _errorText = null;
      });

      if (widget.cropName == "আলু") {
        await _uploadPotatoToApi();
      } else {
        await _showDemoResult();
      }
    } catch (e) {
      setState(() {
        _errorText = "ছবি নির্বাচন করতে সমস্যা হয়েছে।";
      });
    }
  }

  Future<void> _uploadPotatoToApi() async {
    if (_pickedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final uri = Uri.parse(
        "https://mominul2001-potato-dep2.hf.space/predict",
      );

      final request = http.MultipartRequest("POST", uri);
      request.headers["accept"] = "application/json";

      if (kIsWeb) {
        final bytes = _webImageBytes ?? await _pickedImage!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            bytes,
            filename: _pickedImage!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            _pickedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final resultText = "শনাক্ত ফসল: আলু\n${_formatApiResponse(data)}";

        _openResultScreen(
          cropName: "আলু",
          resultText: resultText,
          isDemo: false,
        );
      } else if (response.statusCode == 503) {
        setState(() {
          _errorText =
              "আলুর সার্ভার এখন সাময়িকভাবে ব্যস্ত বা বন্ধ আছে (503)। কিছুক্ষণ পরে আবার চেষ্টা করুন।";
        });
      } else {
        setState(() {
          _errorText =
              "আলুর API থেকে সঠিক ফলাফল পাওয়া যায়নি। কোড: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "আলুর সার্ভারে ছবি পাঠাতে সমস্যা হয়েছে।";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDemoResult() async {
    if (_pickedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    try {
      final result = _demoResults[widget.cropName];

      if (result == null) {
        setState(() {
          _errorText = "এই ফসলের জন্য ডেমো ফলাফল পাওয়া যায়নি।";
        });
        return;
      }

      final diseaseClass = result["class"] ?? "অজানা";
      final confidenceRaw = result["confidence"] ?? 0;

      double confidence = 0;
      if (confidenceRaw is num) {
        confidence = confidenceRaw.toDouble();
      } else {
        confidence = double.tryParse(confidenceRaw.toString()) ?? 0;
      }

      if (!mounted) return;

      final resultText =
          "শনাক্ত ফসল: ${widget.cropName}\nশনাক্ত রোগ: $diseaseClass\nনির্ভুলতার হার: ${(confidence * 100).toStringAsFixed(2)}%";

      _openResultScreen(
        cropName: widget.cropName,
        resultText: resultText,
        isDemo: true,
      );
    } catch (e) {
      setState(() {
        _errorText = "ডেমো ফলাফল দেখাতে সমস্যা হয়েছে।";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final diseaseClass = data["class"] ?? "অজানা";
      final confidenceRaw = data["confidence"] ?? 0;

      double confidence = 0;
      if (confidenceRaw is num) {
        confidence = confidenceRaw.toDouble();
      } else {
        confidence = double.tryParse(confidenceRaw.toString()) ?? 0;
      }

      return "শনাক্ত রোগ: $diseaseClass\nনির্ভুলতার হার: ${(confidence * 100).toStringAsFixed(2)}%";
    }

    return "অজানা ফলাফল";
  }

  void _openResultScreen({
    required String cropName,
    required String resultText,
    required bool isDemo,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseResultScreen(
          cropName: cropName,
          resultText: resultText,
          isDemo: isDemo,
          imageFile: _pickedImage,
          webImageBytes: _webImageBytes,
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.radio_button_checked,
          size: 18,
          color: Colors.green.shade500,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox() {
    if (_errorText == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        _errorText!,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExampleCard({
  required String title,
  required bool isCorrect,
  required String imagePath,
}) {
  final Color accent = isCorrect ? Colors.green : Colors.red;

  return Expanded(
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCorrect
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  isCorrect
                      ? Icons.center_focus_strong
                      : Icons.image_not_supported_outlined,
                  size: 72,
                  color: accent,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 22,
          backgroundColor: accent.withOpacity(0.12),
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: accent,
            size: 30,
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      appBar: AppBar(
        title: const Text(
          "ছবি তুলুন",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FBF9),
                  Color(0xFFEAF7EF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildExampleCard(
                      title: "ভুল পদ্ধতি",
                      isCorrect: false,
                      imagePath: "images/wrong_capture_placeholder.jpg",
                    ),
                    const SizedBox(width: 14),
                    _buildExampleCard(
                      title: "সঠিক পদ্ধতি",
                      isCorrect: true,
                      imagePath: "images/correct_capture_placeholder.jpeg",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoPoint(
                        "ফসল কেন্দ্রিক ছবি তুলুন",
                        "নির্দিষ্ট ফসলের নির্দিষ্ট রোগ বা আক্রান্ত অংশের ছবি তুলুন। পুরো গাছের বদলে রোগ দেখা যাচ্ছে এমন অংশ স্পষ্টভাবে দেখান।",
                      ),
                      const SizedBox(height: 18),
                      _buildInfoPoint(
                        "সঠিকভাবে ছবি তুলুন",
                        "ছবি যেন ঝাপসা না হয়। ভালো আলোতে, ফোকাস ঠিক রেখে, কাছ থেকে এবং স্থির হাতে ছবি তুলুন।",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text(
                    "ছবি বিশ্লেষণ করা হচ্ছে...",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_errorText != null) ...[
                  _buildErrorBox(),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 26),
                    label: const Text(
                      "ক্যামেরা দিয়ে ছবি তুলুন",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 26),
                    label: const Text(
                      "ডিভাইসের ছবি আপলোড করুন",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiseaseResultScreen extends StatelessWidget {
  final String cropName;
  final String resultText;
  final bool isDemo;
  final XFile? imageFile;
  final Uint8List? webImageBytes;

  const DiseaseResultScreen({
    super.key,
    required this.cropName,
    required this.resultText,
    required this.isDemo,
    required this.imageFile,
    required this.webImageBytes,
  });

  Widget _buildImagePreview() {
    if (imageFile == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: kIsWeb
          ? Image.memory(
              webImageBytes!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(imageFile!.path),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2F8),
      appBar: AppBar(
        title: const Text(
          "শনাক্ত ফলাফল",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ফসল: $cropName",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  if (isDemo) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        "ডেমো ফলাফল",
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "শনাক্তকরণের ফলাফল",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resultText,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvisoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_information_outlined),
                label: const Text("পরামর্শ দেখুন"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("ফিরে যান"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}