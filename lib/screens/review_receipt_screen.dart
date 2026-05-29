import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReviewReceiptScreen extends StatefulWidget {
  final File receiptImage;
  final String merchant;
  final String amount;
  final String date;
  final String category;

  const ReviewReceiptScreen({
    super.key,
    required this.receiptImage,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });

  @override
  State<ReviewReceiptScreen> createState() =>
      _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState
    extends State<ReviewReceiptScreen> {

  late TextEditingController merchantController;
  late TextEditingController amountController;
  late TextEditingController dateController;

  late String selectedCategory;

  final categories = [
    "Shopping",
    "Food",
    "Transport",
    "Health",
    "Fashion",
    "Electronics",
    "Grocery",
  ];

  @override
  void initState() {
    super.initState();

    merchantController =
        TextEditingController(
      text: widget.merchant,
    );

    amountController =
        TextEditingController(
      text: widget.amount,
    );

    dateController =
        TextEditingController(
      text: widget.date,
    );

    selectedCategory = widget.category;
  }

  Future<void> saveReceipt() async {

    final receiptsBox =
        Hive.box('receiptsBox');

    await receiptsBox.add({
      "merchant":
          merchantController.text,
      "amount":
          amountController.text,
      "date":
          dateController.text,
      "category":
          selectedCategory,
      "imagePath":
          widget.receiptImage.path,
    });

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Receipt saved"),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    merchantController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Review Receipt",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          children: [

            Container(
              height: 320,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),

                child: InteractiveViewer(
                  child: Image.file(
                    widget.receiptImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            premiumInput(
              "Merchant",
              merchantController,
              Icons.storefront_rounded,
            ),

            premiumInput(
              "Amount",
              amountController,
              Icons.payments_rounded,
            ),

            premiumInput(
              "Date",
              dateController,
              Icons.calendar_month_rounded,
            ),

            const SizedBox(height: 16),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,

                  items: categories.map((c) {

                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );

                  }).toList(),

                  onChanged: (value) {

                    if (value != null) {

                      setState(() {
                        selectedCategory =
                            value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                onPressed: saveReceipt,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xFF10B981),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                ),

                child: const Text(
                  "Save Receipt",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget premiumInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            icon,
            color:
                const Color(0xFF2563EB),
          ),
          labelText: label,
        ),
      ),
    );
  }
}