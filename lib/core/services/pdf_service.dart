import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/quotation.dart';

class PdfService {
  // Generate PDF for a quotation and save to local storage
  Future<File> generateQuotationPdf(Quotation quotation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Quotation', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Text('Customer: ${quotation.customerName}'),
              pw.Text(
                  'Date: ${quotation.quotationDate.toLocal().toString().split(' ')[0]}'),
              pw.Text('Status: ${quotation.status}'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Item', 'Category', 'Size', 'Rate', 'Quantity'],
                data: quotation.items
                    .map((item) => [
                          item.itemName,
                          item.category,
                          item.size,
                          item.rate.toString(),
                          item.quantity.toString(),
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                  'Total Amount: ${quotation.totalAmount.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/quotation_${quotation.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Fetch PDF file by quotation id
  Future<File?> fetchQuotationPdf(String quotationId) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/quotation_$quotationId.pdf');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  // Get PDF as bytes for sharing/printing
  Future<Uint8List?> getQuotationPdfBytes(String quotationId) async {
    final file = await fetchQuotationPdf(quotationId);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }
}
