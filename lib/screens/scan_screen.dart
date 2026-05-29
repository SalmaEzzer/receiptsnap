import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'review_receipt_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? selectedImage;

  String extractedText = "";
  String merchant = "";
  String amount = "";
  String date = "";
  String category = "";

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      extractedText = "";
      merchant = "";
      amount = "";
      date = "";
      category = "";
    });

    await processImage(image.path);
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      extractedText = "";
      merchant = "";
      amount = "";
      date = "";
      category = "";
    });

    await processImage(image.path);
  }

  Future<void> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    final parsed = parseReceiptText(recognizedText.text);

    if (!mounted) return;

    setState(() {
      extractedText = recognizedText.text;
      merchant = parsed["merchant"] ?? "Not detected";
      amount = parsed["amount"] ?? "Not detected";
      date = parsed["date"] ?? "Not detected";
      category = parsed["category"] ?? "Shopping";
    });

    if (selectedImage == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewReceiptScreen(
          receiptImage: selectedImage!,
          merchant: merchant,
          amount: amount,
          date: date,
          category: category,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      selectedImage = null;
      extractedText = "";
      merchant = "";
      amount = "";
      date = "";
      category = "";
    });
  }

  double? parseAmount(String raw) {
    String cleaned = raw.trim().replaceAll(' ', '');

    if (cleaned.contains(',') && cleaned.contains('.')) {
      cleaned = cleaned.replaceAll(',', '');
    } else {
      cleaned = cleaned.replaceAll(',', '.');
    }

    return double.tryParse(cleaned);
  }

  Map<String, String> parseReceiptText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String detectedMerchant = "Not detected";
    String detectedDate = "Not detected";
    String detectedAmount = "Not detected";

    final amountRegex = RegExp(
      r'-?\d{1,3}(?:[,\s]\d{3})*(?:[,.]\d{2})|-?\d+[,.]\d{2}',
    );

    final dateRegex = RegExp(
      r'\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}',
    );

    for (final line in lines) {
      final match = dateRegex.firstMatch(line);

      if (match != null) {
        detectedDate = match.group(0)!;
        break;
      }
    }

    int totalIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();

      if (lower.contains("total a payer") ||
          lower.contains("net a payer") ||
          lower.contains("total ttc") ||
          lower.contains("amount due") ||
          lower == "total") {
        totalIndex = i;
        break;
      }
    }

    if (totalIndex != -1) {
      final followingAmounts = <double>[];

      for (int i = totalIndex + 1; i < lines.length; i++) {
        final matches = amountRegex.allMatches(lines[i]);

        for (final match in matches) {
          final value = parseAmount(match.group(0)!);

          if (value != null && value > 0) {
            followingAmounts.add(value);
          }
        }
      }

      if (followingAmounts.isNotEmpty) {
        followingAmounts.sort();
        detectedAmount = followingAmounts.last.toStringAsFixed(2);
      }
    }

    if (detectedAmount == "Not detected") {
      final amounts = <double>[];

      for (final line in lines) {
        final matches = amountRegex.allMatches(line);

        for (final match in matches) {
          final value = parseAmount(match.group(0)!);

          if (value != null && value > 0) {
            amounts.add(value);
          }
        }
      }

      if (amounts.isNotEmpty) {
        amounts.sort();
        detectedAmount = amounts.last.toStringAsFixed(2);
      }
    }

    for (final line in lines) {
      final lower = line.toLowerCase();

      final ignored = lower.contains("receipt") ||
          lower.contains("facture") ||
          lower.contains("cashier") ||
          lower.contains("total") ||
          lower.contains("amount") ||
          lower.contains("tax") ||
          lower.contains("date") ||
          amountRegex.hasMatch(line) ||
          dateRegex.hasMatch(line);

      final hasLetters = RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(line);

      if (!ignored && hasLetters && line.length > 5) {
        detectedMerchant = line.replaceAll("<", "").trim();
        break;
      }
    }

    final detectedCategory = detectCategory(
      detectedMerchant,
      text,
    );

    return {
      "merchant": detectedMerchant,
      "date": detectedDate,
      "amount": detectedAmount,
      "category": detectedCategory,
    };
  }

  String detectCategory(
    String merchant,
    String text,
  ) {
    final combined = "$merchant $text".toLowerCase();

    if (combined.contains("carrefour") ||
        combined.contains("market") ||
        combined.contains("marjane")) {
      return "Grocery";
    }

    if (combined.contains("restaurant") ||
        combined.contains("coffee") ||
        combined.contains("pizza")) {
      return "Food";
    }

    if (combined.contains("uber") ||
        combined.contains("taxi")) {
      return "Transport";
    }

    if (combined.contains("pharmacy") ||
        combined.contains("medical")) {
      return "Health";
    }

    if (combined.contains("zara") ||
        combined.contains("nike")) {
      return "Fashion";
    }

    return "Shopping";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),

          child: Column(
            children: [

              // HEADER
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(30),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    const Expanded(
                      child: Text(
                        "Scan",

                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: pickImageFromGallery,

                      child: Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),

                          borderRadius: BorderRadius.circular(18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(34),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),

                  child: selectedImage == null

                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            Container(
                              width: 120,
                              height: 120,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF10B981),
                                  ],
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.35),

                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),

                              child: const Icon(
                                Icons.document_scanner_rounded,
                                color: Colors.white,
                                size: 58,
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "Scan your receipt",

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),

                              child: Text(
                                "Take a photo or import a receipt image to automatically extract expense details.",

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        )

                      : ClipRRect(
                          borderRadius: BorderRadius.circular(34),

                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,

                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: pickImageFromCamera,

                child: Container(
                  width: 88,
                  height: 88,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF10B981),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981)
                            .withOpacity(0.35),

                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              if (extractedText.isNotEmpty)

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      infoRow("Merchant", merchant),
                      infoRow("Date", date),

                      infoRow(
                        "Amount",
                        amount == "Not detected"
                            ? amount
                            : "\$$amount",
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [

          Expanded(
            child: Text(
              label.toUpperCase(),

              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,

              textAlign: TextAlign.right,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}