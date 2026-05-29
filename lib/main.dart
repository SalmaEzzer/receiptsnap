import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('receiptsBox');

  runApp(const ReceiptSnapApp());
}

class ReceiptSnapApp extends StatelessWidget {
  const ReceiptSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReceiptSnap',
      themeMode: ThemeMode.light,

theme: ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor:
      const Color(0xFFF5F7FA),
),

darkTheme: ThemeData(
  brightness: Brightness.dark,

  scaffoldBackgroundColor:
      const Color(0xFF0F172A),

  cardColor:
      const Color(0xFF1E293B),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2563EB),
  ),
),
      home: const HomeScreen(),
    );
  }
}