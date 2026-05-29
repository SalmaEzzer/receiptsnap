import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReceiptsReport(List receipts) async {
    final pdf = pw.Document();

    double total = 0;

    for (final receipt in receipts) {
      final item = receipt as Map;
      final amount = double.tryParse(item["amount"].toString()) ?? 0;
      total += amount;
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "ReceiptSnap Expense Report",
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text("Generated automatically from saved receipts"),

          pw.SizedBox(height: 25),

          pw.Text(
            "Total: \$${total.toStringAsFixed(2)}",
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 25),

          pw.TableHelper.fromTextArray(
            headers: [
              "Merchant",
              "Date",
              "Category",
              "Amount",
            ],
            data: receipts.map((receipt) {
              final item = receipt as Map;

              return [
                item["merchant"].toString(),
                item["date"].toString(),
                item["category"].toString(),
                "\$${item["amount"]}",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}