import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/pdf_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Box receiptsBox;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final colors = const [
    Color(0xFF1E3A8A),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFF94A3B8),
  ];

  final monthNames = const [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
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

  @override
  Widget build(BuildContext context) {
    final allReceipts = receiptsBox.values.toList();

    final filteredReceipts = allReceipts.where((receipt) {
      final item = receipt as Map;
      final date = parseReceiptDate(item["date"].toString());

      return date != null &&
          date.month == selectedMonth &&
          date.year == selectedYear;
    }).toList();

    double total = 0;
    final Map<String, double> categoryTotals = {};

    for (final receipt in filteredReceipts) {
      final item = receipt as Map;
      final amount = double.tryParse(item["amount"].toString()) ?? 0;
      final category = item["category"].toString();

      total += amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory =
        sortedCategories.isNotEmpty ? sortedCategories.first.key : "None";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(filteredReceipts),
              const SizedBox(height: 20),
              monthYearFilter(),
              const SizedBox(height: 24),
              trendCard(filteredReceipts, total),
              const SizedBox(height: 24),
              categoryCard(sortedCategories),
              const SizedBox(height: 24),
              insightTile(
                icon: Icons.trending_up_rounded,
                title: "Most spent on $topCategory",
                subtitle: filteredReceipts.isEmpty
                    ? "No receipts for this month."
                    : "\$${sortedCategories.first.value.toStringAsFixed(2)} spent in this category.",
                color: const Color(0xFF10B981),
              ),
              insightTile(
                icon: Icons.auto_graph_rounded,
                title: "Total receipts",
                subtitle:
                    "${filteredReceipts.length} receipts in ${monthNames[selectedMonth - 1]} $selectedYear.",
                color: const Color(0xFFF59E0B),
              ),
              insightTile(
                icon: Icons.savings_rounded,
                title: "Expense tracking active",
                subtitle: "Your dashboard updates automatically.",
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(List receipts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
              "Insights",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              PdfService.generateReceiptsReport(receipts);
            },
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
                Icons.download_rounded,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget monthYearFilter() {
    final years = List.generate(10, (index) => DateTime.now().year - index);

    return Row(
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

  Widget trendCard(List receipts, double total) {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final dailyTotals = List<double>.filled(daysInMonth, 0);

    for (final receipt in receipts) {
      final item = receipt as Map;
      final amount = double.tryParse(item["amount"].toString()) ?? 0;
      final date = parseReceiptDate(item["date"].toString());

      if (date != null && date.day >= 1 && date.day <= daysInMonth) {
        dailyTotals[date.day - 1] += amount;
      }
    }

    final spots = <FlSpot>[];

    for (int i = 0; i < dailyTotals.length; i++) {
      if (dailyTotals[i] > 0) {
        spots.add(
          FlSpot(
            i.toDouble(),
            dailyTotals[i],
          ),
        );
      }
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    final maxY = dailyTotals.isEmpty
        ? 0.0
        : dailyTotals.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${monthNames[selectedMonth - 1]} $selectedYear trend",
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${total.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY == 0 ? 10 : maxY * 1.2,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: const Color(0xFF1E3A8A),
                    belowBarData: BarAreaData(
                      show: maxY > 0,
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                    ),
                    dotData: FlDotData(
                      show: spots.length <= 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryCard(List<MapEntry<String, double>> sortedCategories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          if (sortedCategories.isEmpty)
            const Text(
              "No data for selected month.",
              style: TextStyle(color: Colors.grey),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 135,
                  height: 135,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      startDegreeOffset: -90,
                      sections: sortedCategories.take(5).map((entry) {
                        final index = sortedCategories.indexOf(entry);

                        return PieChartSectionData(
                          value: entry.value,
                          color: colors[index % colors.length],
                          radius: 18,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: sortedCategories.take(5).map((entry) {
                      final index = sortedCategories.indexOf(entry);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[index % colors.length],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            Text(
                              "\$${entry.value >= 1000 ? "${(entry.value / 1000).toStringAsFixed(1)}k" : entry.value.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  BoxDecoration premiumCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  Widget insightTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: premiumCard(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}