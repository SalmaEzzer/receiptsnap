import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'receipt_detail_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  late Box receiptsBox;

  String searchQuery = "";
  String selectedFilter = "All";

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final filters = [
    "All",
    "Food",
    "Grocery",
    "Transport",
    "Health",
    "Fashion",
    "Electronics",
    "Shopping",
  ];

  final monthNames = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void initState() {
    super.initState();
    receiptsBox = Hive.box('receiptsBox');
  }

  DateTime? parseReceiptDate(String rawDate) {
    final parts = rawDate.split("/");
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  String formatAmount(dynamic value) {
    final amount = double.tryParse(value.toString()) ?? 0;

    if (amount >= 1000) {
      return "\$${(amount / 1000).toStringAsFixed(1)}k";
    }

    return "\$${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(10, (index) => DateTime.now().year - index);

    final allReceipts = receiptsBox.toMap().entries.toList().reversed.toList();

    final receipts = allReceipts.where((entry) {
      final receipt = entry.value as Map;
      final receiptDate = parseReceiptDate(receipt["date"].toString());

      final matchesMonthYear = receiptDate != null &&
          receiptDate.month == selectedMonth &&
          receiptDate.year == selectedYear;

      final merchant = receipt["merchant"].toString().toLowerCase();
      final category = receipt["category"].toString();
      final date = receipt["date"].toString().toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchesSearch = merchant.contains(query) ||
          category.toLowerCase().contains(query) ||
          date.contains(query);

      final matchesFilter = selectedFilter == "All" || category == selectedFilter;

      return matchesMonthYear && matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Container(
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
                child: const Text(
                  "Receipt",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: filterBox(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(monthNames[index]),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedMonth = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: filterBox(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          items: years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedYear = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded),
                    hintText: "Search receipts...",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF2563EB),
                                  Color(0xFF10B981),
                                ],
                              )
                            : null,
                        color: selected ? null : Colors.white,
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: receipts.isEmpty
                  ? Center(
                      child: Text(
                        "No receipts found for ${monthNames[selectedMonth - 1]} $selectedYear",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final key = receipts[index].key;
                        final receipt = receipts[index].value as Map;

                        return Dismissible(
                          key: ValueKey(key),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.only(right: 24),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          onDismissed: (_) async {
                            await receiptsBox.delete(key);

                            if (mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Receipt deleted"),
                                ),
                              );
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReceiptDetailScreen(
                                    receipt: receipt,
                                    receiptKey: key,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.file(
                                      File(receipt["imagePath"]),
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          receipt["merchant"].toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          receipt["date"].toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFF2563EB),
                                                      Color(0xFF10B981),
                                                    ],
                                                  ),
                                                ),
                                                child: Text(
                                                  receipt["category"].toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 105),
                                    child: Text(
                                      formatAmount(receipt["amount"]),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}