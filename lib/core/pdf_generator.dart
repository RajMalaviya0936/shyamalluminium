import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generate a simple invoice PDF from the provided invoice map.
/// Returns the PDF bytes. Throws on failure (so caller can show details).
Future<Uint8List> generateInvoicePdfBytes(Map<String, dynamic> invoice) async {
  try {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(invoice['invoiceNumber'] ?? '',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice['date'] ?? ''),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Text('Bill To:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(invoice['customerName'] ?? ''),
                pw.Text(invoice['customerPhone'] ?? ''),
                pw.Text(invoice['customerAddress'] ?? ''),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  headers: ['Item', 'Qty', 'Rate', 'Total'],
                  data: (invoice['items'] as List<dynamic>? ?? []).map((it) {
                    return [
                      it['name'] ?? '',
                      '${it['quantity'] ?? ''}',
                      '${it['rate'] ?? ''}',
                      '${it['total'] ?? ''}'
                    ];
                  }).toList(),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ${invoice['subtotal'] ?? ''}'),
                        pw.Text('Tax: ${invoice['tax'] ?? ''}'),
                        pw.SizedBox(height: 6),
                        pw.Text('Total: ${invoice['total'] ?? ''}',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  } catch (e, st) {
    // Log to console for diagnostics and rethrow
    // ignore: avoid_print
    print('generateInvoicePdfBytes error: $e');
    // ignore: avoid_print
    print(st);
    rethrow;
  }
}
