import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Map receipt;
  final dynamic receiptKey;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    required this.receiptKey,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late TextEditingController merchantController;
  late TextEditingController dateController;
  late TextEditingController amountController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    merchantController =
        TextEditingController(text: widget.receipt["merchant"].toString());
    dateController =
        TextEditingController(text: widget.receipt["date"].toString());
    amountController =
        TextEditingController(text: widget.receipt["amount"].toString());
    categoryController =
        TextEditingController(text: widget.receipt["category"].toString());
  }

  @override
  void dispose() {
    merchantController.dispose();
    dateController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final box = Hive.box('receiptsBox');

    await box.put(widget.receiptKey, {
      "merchant": merchantController.text,
      "date": dateController.text,
      "amount": amountController.text,
      "category": categoryController.text,
      "imagePath": widget.receipt["imagePath"],
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receipt updated")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Edit Receipt",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: saveChanges,
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                height: 360,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: InteractiveViewer(
                    child: Image.file(
                      File(widget.receipt["imagePath"]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              premiumInput("Merchant", merchantController, Icons.storefront),
              premiumInput("Date", dateController, Icons.calendar_month),
              premiumInput("Category", categoryController, Icons.category),
              premiumInput(
                "Amount",
                amountController,
                Icons.payments,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget premiumInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF2563EB)),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}