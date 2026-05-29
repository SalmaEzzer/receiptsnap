import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box receiptsBox;

  @override
  void initState() {
    super.initState();
    receiptsBox = Hive.box('receiptsBox');
  }

  @override
  Widget build(BuildContext context) {
    final receipts = receiptsBox.values.toList();

    double total = 0;

    for (final receipt in receipts) {
      final item = receipt as Map;
      total += double.tryParse(item["amount"].toString()) ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
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

                child: const Text(
                  "Profile",

                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // PROFILE CARD
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(26),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(32),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Container(
                      width: 92,
                      height: 92,

                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF10B981),
                          ],
                        ),
                      ),

                      child: const Center(
                        child: Text(
                          "RS",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "ReceiptSnap User",

                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Smart receipt tracking account",

                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STATS
              Row(
                children: [

                  Expanded(
                    child: statBox(
                      "Receipts",
                      receipts.length.toString(),
                      Icons.receipt_long_rounded,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: statBox(
                      "Spent",

                      total >= 1000
                          ? "\$${(total / 1000).toStringAsFixed(1)}k"
                          : "\$${total.toStringAsFixed(0)}",

                      Icons.payments_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // SETTINGS
              settingTile(
                icon: Icons.cloud_upload_rounded,
                title: "Backup data",
                subtitle: "Cloud sync coming soon",
              ),

              settingTile(
                icon: Icons.picture_as_pdf_rounded,
                title: "Export reports",
                subtitle: "Generate expense reports",
              ),

              settingTile(
                icon: Icons.lock_rounded,
                title: "Privacy",
                subtitle: "All data is stored locally",
              ),

              settingTile(
                icon: Icons.info_rounded,
                title: "App version",
                subtitle: "ReceiptSnap v1.0.0",
              ),

              const SizedBox(height: 30),

              // CLEAR BUTTON
              GestureDetector(
                onTap: () async {

                  await receiptsBox.clear();

                  if (mounted) {

                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "All receipts deleted",
                        ),
                      ),
                    );
                  }
                },

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.10),

                    borderRadius: BorderRadius.circular(26),
                  ),

                  child: const Row(
                    children: [

                      Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.redAccent,
                      ),

                      SizedBox(width: 16),

                      Text(
                        "Clear all receipts",

                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget statBox(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(26),

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

          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 30,
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
                const Color(0xFF2563EB).withOpacity(0.10),

            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: const TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}