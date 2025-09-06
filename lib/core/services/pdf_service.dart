import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/quotation.dart';

class PdfService {
  // Generate a detailed quotation PDF (A4) with header, items table,
  // item detail previews, totals and Terms & Conditions page.
  Future<File> generateQuotationPdf(Quotation quotation,
      {Uint8List? previewImage, List<Uint8List?>? itemPreviews}) async {
    final pdf = pw.Document();

    // Load logo from assets
    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      // ignore if logo not found; continue without image
      logoImage = null;
    }

    double subtotal = 0.0;
    for (final it in quotation.items) {
      final rate = _getDouble(it, 'rate');
      final qty = _getInt(it, 'quantity');
      subtotal += rate * qty;
    }
    final tax = subtotal * 0.18;
    final total = subtotal + tax;

    // Main page with header, customer info and items
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          return [
            // Header: logo + company info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoImage != null)
                  pw.Container(width: 90, child: pw.Image(logoImage)),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('METALEX ALUMINIUM',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          'SWC BUSINESS HUB\nA-501, Bhaydi Rd, opp. Rajpath Complex, Bhayli,\nVadodara Gujarat-391410',
                          textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          'Phone: 81403 78133 | Email: metalexaluminium@gmail.com',
                          textAlign: pw.TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 12),

            pw.Center(
                child: pw.Text('Quotation',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 12),

            // Customer & meta info box
            pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey)),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('To,',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Client Name : ${quotation.customerName}'),
                        pw.Text('Address : '),
                        pw.Text('Phone : '),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [
                          pw.Text('Quote Date : '),
                          pw.Text(
                              '${quotation.quotationDate.toLocal().toString().split(' ')[0]}')
                        ]),
                        pw.SizedBox(height: 4),
                        pw.Row(children: [
                          pw.Text('Quotation number : '),
                          pw.Text(quotation.id)
                        ]),
                        pw.SizedBox(height: 4),
                        pw.Row(children: [
                          pw.Text('Quotation Prepared By : '),
                          pw.Text('Administrator')
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Items table removed per user request. Individual item detail blocks
            // (with preview images and computed values) are rendered below.

            // Render detailed blocks for each item (image placeholder + description)
              // Render each item as a two-column block: left - interior image, right - metadata & computed values
              ...quotation.items.map((it) {
                final code = _getString(it, 'code');
                final itemName = _getString(it, 'itemName');
                final size = _getString(it, 'size');
                final profileSystem = _getString(it, 'system');
                final location = _getString(it, 'location');
                final glass = _getString(it, 'glassColor');
                // description and category are not used in this layout
                final hasNet = _getBool(it, 'hasMosquitoNet');
                final idx = quotation.items.indexOf(it);
                final Uint8List? itemImg = (itemPreviews != null && idx >= 0 && idx < itemPreviews.length) ? itemPreviews[idx] : null;
                final rate = _getDouble(it, 'rate');
                final qty = _getInt(it, 'quantity');
                final area = _computeAreaFromSize(size);
                final value = rate * qty;

                // Compose left (image) and right (tables) columns
                final leftColumn = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // enlarged preview box while keeping the same visual box structure
                    pw.Container(
                      width: 260,
                      height: 180,
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                      child: itemImg != null ? pw.Center(child: pw.Image(pw.MemoryImage(itemImg), fit: pw.BoxFit.contain)) : pw.Center(child: pw.Text('No Preview', style: pw.TextStyle(color: PdfColors.grey, fontSize: 10))),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('View From Inside', style: pw.TextStyle(fontSize: 9)),
                  ],
                );

                final rightColumn = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(3)},
                      children: [
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Code :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(code.isNotEmpty ? code : '')),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Size :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(size)),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Name :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(itemName)),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Profile System :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(profileSystem)),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Location :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(location)),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Glass :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(glass.isNotEmpty ? glass : '-')),
                        ]),
                      ],
                    ),

                    pw.SizedBox(height: 8),

                    // Computed Values as a bordered table with rows
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1)},
                      children: [
                        pw.TableRow(
                            decoration: pw.BoxDecoration(color: PdfColors.grey200),
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Computed Values', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('')),
                            ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Sq.Ft. per window')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(area.toStringAsFixed(0) + ' Sq.Ft.')),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('SLIDING NET')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(hasNet ? 'Yes' : 'No')),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unit Price')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(rate.toStringAsFixed(0) + ' Rs.')),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Quantity')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(qty.toString() + ' Pcs')),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Value')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(value.toStringAsFixed(0) + ' Rs.')),
                        ]),
                      ],
                    ),

                    pw.SizedBox(height: 8),

                    pw.Row(children: [
                      pw.Expanded(
                        child: pw.Container(
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Profile', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 6),
                              pw.Text('Profile Color : MILL FINISH'),
                              pw.Text('MeshType : ${hasNet ? 'SLIDING NET' : '-'}'),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Container(
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Accessories', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 6),
                              pw.Text('Locking : MULTI POINT'),
                              pw.Text('Handle color : BLACK'),
                            ],
                          ),
                        ),
                      ),
                    ]),

                    pw.SizedBox(height: 8),
                    pw.Text('Remarks :'),
                    pw.SizedBox(height: 12),
                  ],
                );

                return pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      leftColumn,
                      pw.SizedBox(width: 12),
                      pw.Expanded(child: rightColumn),
                    ],
                  ),
                );
              }).toList(),

            pw.Divider(),

            // Totals block
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: ${subtotal.toStringAsFixed(2)}'),
                    pw.Text('Tax (18%): ${tax.toStringAsFixed(2)}'),
                    pw.SizedBox(height: 6),
                    pw.Text('Total: ${total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ])
            ])
          ];
        },
      ),
    );

    // Terms & Conditions page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(18),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Terms and Conditions',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Bullet(
                      text:
                          'Payment Terms: 50% advance along with your valued order, 50% payment before delivery of windows at site.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Quotation validity 07-days from the date of issue.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Delivery period 45 working days from the date of drawing approval by the buyer.'),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      'Please refer to the attached document for full terms and conditions.'),
                ]),
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/quotation_${quotation.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // fetch existing PDF
  Future<File?> fetchQuotationPdf(String quotationId) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/quotation_$quotationId.pdf');
    if (await file.exists()) return file;
    return null;
  }

  Future<Uint8List?> getQuotationPdfBytes(String quotationId) async {
    final file = await fetchQuotationPdf(quotationId);
    if (file != null) return await file.readAsBytes();
    return null;
  }

  // helpers to read fields from either QuotationItem or Map
  String _getString(dynamic item, String key) {
    try {
      if (item is QuotationItem) {
        switch (key) {
          case 'itemName':
            return item.itemName;
          case 'category':
            return item.category;
          case 'size':
            return item.size;
          default:
            return '';
        }
      } else if (item is Map<String, dynamic>) {
        return (item[key] ?? '').toString();
      }
    } catch (_) {}
    return '';
  }

  double _getDouble(dynamic item, String key) {
    try {
      if (item is QuotationItem) {
        if (key == 'rate') return item.rate;
      } else if (item is Map<String, dynamic>) {
        final v = item[key];
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
      }
    } catch (_) {}
    return 0.0;
  }

  int _getInt(dynamic item, String key) {
    try {
      if (item is QuotationItem) {
        if (key == 'quantity') return item.quantity;
      } else if (item is Map<String, dynamic>) {
        final v = item[key];
        if (v is int) return v;
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  bool _getBool(dynamic item, String key) {
    try {
      if (item is Map<String, dynamic>) {
        final v = item[key];
        if (v is bool) return v;
        return (v?.toString().toLowerCase() == 'true');
      }
    } catch (_) {}
    return false;
  }

  double _computeAreaFromSize(String size) {
    // try to parse size like '1458 mm x 1119 mm' or '4 x 3' else return 0
    try {
      final parts = size.split(RegExp(r'[xX×,]'));
      if (parts.length >= 2) {
        final a = double.tryParse(
                parts[0].replaceAll(RegExp(r'[^0-9\.]'), '').trim()) ??
            0;
        final b = double.tryParse(
                parts[1].replaceAll(RegExp(r'[^0-9\.]'), '').trim()) ??
            0;
        // assume mm => convert to feet if large values (>100)
        if (a > 100 || b > 100) {
          // mm -> meters -> feet
          final aFeet = (a / 1000) * 3.28084;
          final bFeet = (b / 1000) * 3.28084;
          return aFeet * bFeet;
        }
        // else assume feet
        return a * b;
      }
    } catch (_) {}
    return 0.0;
  }

  // _parseFirstDimension removed — no longer required after layout refactor.
}
