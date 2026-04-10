import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();

  String? _selectedCrop;
  XFile? _pickedImage;
  Uint8List? _webImageBytes;

  bool _isLoading = false;
  String? _resultText;
  String? _errorText;

  final List<String> _cropOptions = ["আলু"];

  Future<void> _selectCrop() async {
    final crop = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "কোন ফসল শনাক্ত করতে চান?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._cropOptions.map(
                  (crop) => ListTile(
                    leading: const Icon(Icons.grass, color: Colors.green),
                    title: Text(crop),
                    onTap: () => Navigator.pop(context, crop),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (crop != null) {
      setState(() {
        _selectedCrop = crop;
        _pickedImage = null;
        _webImageBytes = null;
        _resultText = null;
        _errorText = null;
      });

      await _chooseImageSource();
    }
  }

  Future<void> _chooseImageSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "ছবি নির্বাচন করুন",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text("ছবি তুলুন"),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file, color: Colors.blue),
                  title: const Text("ছবি আপলোড করুন"),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

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
        _resultText = null;
        _errorText = null;
      });

      await _uploadToApi();
    } catch (e) {
      setState(() {
        _errorText = "ছবি নির্বাচন করতে সমস্যা হয়েছে।";
      });
    }
  }

  Future<void> _uploadToApi() async {
    if (_pickedImage == null) return;

    setState(() {
      _isLoading = true;
      _resultText = null;
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

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        setState(() {
          _resultText = _formatApiResponse(data);
        });
      } else {
        setState(() {
          _errorText =
              "API থেকে সঠিক ফলাফল পাওয়া যায়নি। কোড: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "সার্ভারে ছবি পাঠাতে সমস্যা হয়েছে।";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _startAgain() {
    setState(() {
      _selectedCrop = null;
      _pickedImage = null;
      _webImageBytes = null;
      _resultText = null;
      _errorText = null;
      _isLoading = false;
    });

    _selectCrop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _selectedCrop == null
                        ? "ফসল নির্বাচন করে ছবি দিন"
                        : "নির্বাচিত ফসল: $_selectedCrop",
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

            if (_pickedImage == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectCrop,
                  icon: const Icon(Icons.search),
                  label: const Text("রোগ শনাক্ত শুরু করুন"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (_pickedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: kIsWeb
                    ? Image.memory(
                        _webImageBytes!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_pickedImage!.path),
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text(
                "ছবি বিশ্লেষণ করা হচ্ছে...",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],

            if (_resultText != null) ...[
              const SizedBox(height: 16),
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
                      "শনাক্ত ফলাফল",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resultText!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Container(
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
              ),
            ],

            const SizedBox(height: 20),

            if (_pickedImage != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _startAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text("নতুন ছবি দিন"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}