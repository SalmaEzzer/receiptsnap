import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'receipts_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const HomeDashboard(),
    const ReceiptsScreen(),
    const ScanScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navButton(Icons.home_rounded, 0),
            navButton(Icons.receipt_long_rounded, 1),
            GestureDetector(
              onTap: () => setState(() => selectedIndex = 2),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            navButton(Icons.bar_chart_rounded, 3),
            navButton(Icons.person_outline_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget navButton(IconData icon, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Icon(
        icon,
        size: 28,
        color: selectedIndex == index
            ? const Color(0xFF2563EB)
            : Colors.grey,
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late Box receiptsBox;

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

  double getTotal(List receipts) {
    double total = 0;

    for (final receipt in receipts) {
      final item = receipt as Map;
      total += double.tryParse(item["amount"].toString()) ?? 0;
    }

    return total;
  }

  String getTopCategory(List receipts) {
    final Map<String, double> categoryTotals = {};

    for (final receipt in receipts) {
      final item = receipt as Map;
      final amount = double.tryParse(item["amount"].toString()) ?? 0;
      final category = item["category"].toString();

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    if (categoryTotals.isEmpty) return "None";

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String formatAmount(double amount) {
    if (amount >= 1000) {
      return "\$${(amount / 1000).toStringAsFixed(1)}k";
    }

    return "\$${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final receipts = receiptsBox.values
        .where((receipt) {
          final item = receipt as Map;
          final date = parseReceiptDate(item["date"].toString());

          return date != null &&
              date.month == now.month &&
              date.year == now.year;
        })
        .toList()
        .reversed
        .toList();

    final total = getTotal(receipts);
    final average = receipts.isEmpty ? 0 : total / receipts.length;
    final topCategory = getTopCategory(receipts);
    final recentReceipts = receipts.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF10B981)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "RS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "ReceiptSnap",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
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
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                    Color(0xFF10B981),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "THIS MONTH EXPENSES",
                    style: TextStyle(
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formatAmount(total),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${receipts.length} saved receipts this month",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: statCard(
                    icon: Icons.receipt_long_rounded,
                    title: "Receipts",
                    value: receipts.length.toString(),
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: statCard(
                    icon: Icons.category_rounded,
                    title: "Top",
                    value: topCategory,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: statCard(
                    icon: Icons.analytics_rounded,
                    title: "Average",
                    value: formatAmount(average.toDouble()),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              "Recent receipts",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 20),

            if (recentReceipts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "No receipts this month. Scan your first receipt.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: recentReceipts.map((receipt) {
                  final item = receipt as Map;

                  return receiptTile(
                    title: item["merchant"].toString(),
                    category: item["category"].toString(),
                    amount: formatAmount(
                      double.tryParse(item["amount"].toString()) ?? 0,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget receiptTile({
    required String title,
    required String category,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade100,
            child: const Icon(Icons.receipt_long_rounded),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}