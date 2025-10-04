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
    double totalSqFt = 0.0;
    double totalRunningFt = 0.0;
    for (final it in quotation.items) {
      final unitPrice = _getDouble(it, 'unitPrice');
      final qty = _getInt(it, 'quantity');

      // compute area for this item (prefer precomputed area on QuotationItem)
      double area = 0.0;
      try {
        if (it.area != null) {
          area = it.area!;
        }
        // If area still zero, parse the size string and convert units
        if (area == 0.0) {
          final sizeStr = _getString(it, 'size');
          final parts = sizeStr.split('x');
          if (parts.length >= 2) {
            final w = double.tryParse(parts[0].trim().split(' ').first) ?? 0.0;
            final h = double.tryParse(parts[1].trim().split(' ').first) ?? 0.0;
            final measurementType = _getString(it, 'measurementType');
            final unit = _getString(it, 'unit');
            if (measurementType.toLowerCase() == 'runningft') {
              area = w; // running feet
              totalRunningFt += area;
            } else {
              if (unit == 'mm') {
                area = (w * h) / 92903.04;
              } else if (unit == 'inches') {
                area = (w / 12) * (h / 12);
              } else if (unit == 'cm') {
                area = (w / 30.48) * (h / 30.48);
              } else {
                area = w * h;
              }
              totalSqFt += area;
            }
          }
        } else {
          // area was provided; add to totals depending on measurement type
          final measurementType = _getString(it, 'measurementType');
          if (measurementType.toLowerCase() == 'runningft') {
            totalRunningFt += area;
          } else {
            totalSqFt += area;
          }
        }
      } catch (_) {}

      // subtotal uses unitPrice * area * quantity to match UI productTotal
      subtotal += unitPrice * area * qty;
    }
    // Tax/discount/gst will be computed in the totals block below

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
                      pw.Text('Shyam Aluminium',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          'Gundala Chowkdi, Behind Silver Complex, Gundala Road,\nGondal-360311',
                          textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          'Phone : 96385 10777 | Email : malaviyasagar312@gmail.com',
                          textAlign: pw.TextAlign.center),
                      // pw.Text('GSTIN : 24BTZPP6949L1ZG',
                      //     textAlign: pw.TextAlign.center),
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
                        pw.Text('Address : ${quotation.customerAddress ?? ''}'),
                        pw.Text('Phone : ${quotation.customerPhone ?? ''}'),
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
                        // pw.Row(children: [
                        //   pw.Text('Quotation Prepared By : '),
                        //   pw.Text('SHYAM\nALLUMINIUM')
                        // ]),
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
              // removed unused code/itemName variables; use fields directly if needed
              final size = _getString(it, 'size');
              final location = _getString(it, 'location');
              final glass = _getString(it, 'glassColor');
              // description and category are not used in this layout
              final hasNet = _getBool(it, 'hasMosquitoNet');
              final profileColor = _getString(it, 'profileColor');
              final meshType = _getString(it, 'meshType');
              final locking = _getString(it, 'locking');
              final handleColor = _getString(it, 'handleColor');
              final itemRemarks = _getString(it, 'remarks');
              final topCategory =
                  it.topCategory ?? 'General'; // Get top category
              final itemName = it.itemName;
              final idx = quotation.items.indexOf(it);
              final Uint8List? itemImg = (itemPreviews != null &&
                      idx >= 0 &&
                      idx < itemPreviews.length)
                  ? itemPreviews[idx]
                  : null;
              final unitPrice = _getDouble(it, 'unitPrice');
              final qty = _getInt(it, 'quantity');
              final measurementType = _getString(it, 'measurementType');
              final unit = _getString(it, 'unit');
              final unitLabel = (measurementType.toLowerCase() == 'runningft')
                  ? 'Running Ft'
                  : 'Sq.Ft.';
              // Prefer an already-computed area (passed through QuotationItem.area or item['area']).
              double area = 0.0;
              try {
                // quotation.items contains QuotationItem objects, prefer the precomputed area
                if (it.area != null) {
                  area = it.area!;
                }

                // If area still zero, fall back to parsing the size string (old behavior)
                if (area == 0.0) {
                  final parts = size.split('x');
                  if (parts.length >= 2) {
                    final w =
                        double.tryParse(parts[0].trim().split(' ').first) ??
                            0.0;
                    final h =
                        double.tryParse(parts[1].trim().split(' ').first) ??
                            0.0;
                    if (measurementType.toLowerCase() == 'runningft') {
                      area = w; // treat width as running feet length
                    } else if (unit == 'mm') {
                      area = (w * h) / 92903.04;
                    } else if (unit == 'inches') {
                      area = (w / 12) * (h / 12);
                    } else if (unit == 'cm') {
                      area = (w / 30.48) * (h / 30.48);
                    } else {
                      area = w * h;
                    }
                  }
                }
              } catch (_) {
                area = 0.0;
              }
              // value calculated as unitPrice x area
              final value = unitPrice * area;

              // Compose left (image) and right (tables) columns
              final leftColumn = pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // enlarged preview box while keeping the same visual box structure
                  pw.Container(
                    width: 260,
                    height: 300,
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300)),
                    child: itemImg != null
                        ? pw.Center(
                            child: pw.Image(pw.MemoryImage(itemImg),
                                fit: pw.BoxFit.contain))
                        : pw.Center(
                            child: pw.Text('No Preview',
                                style: pw.TextStyle(
                                    color: PdfColors.grey, fontSize: 10))),
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
                    columnWidths: {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(3)
                    },
                    children: [
                      // Render metadata in requested order and with requested fields
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Location :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(location)),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Size :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(size)),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Unit Price :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child:
                                pw.Text('Rs. ${unitPrice.toStringAsFixed(2)}')),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Profile System :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(_getDisplayNameForItem(it)),
                        ),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Color :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                                profileColor.isNotEmpty ? profileColor : '-')),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Glass :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(glass.isNotEmpty ? glass : '-')),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Grill :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                                _getBool(it, 'hasGrill') ? 'Yes' : 'No')),
                      ]),

                      // New line: Grill pipe count
                      // if (_getBool(it, 'hasGrill'))
                      //   pw.TableRow(children: [
                      //     pw.Padding(
                      //         padding: const pw.EdgeInsets.all(6),
                      //         child: pw.Text('Grill Pipe:',
                      //             style: pw.TextStyle(
                      //                 fontWeight: pw.FontWeight.bold))),
                      //     pw.Padding(
                      //         padding: const pw.EdgeInsets.all(6),
                      //         child: pw.Text(
                      //             (it.grillPipeCount?.toString() ?? '-'))),
                      //   ]),

                      // New line: PVC window count
                      // pw.TableRow(children: [
                      //   pw.Padding(
                      //       padding: const pw.EdgeInsets.all(6),
                      //       child: pw.Text('PVC Window Count:',
                      //           style: pw.TextStyle(
                      //               fontWeight: pw.FontWeight.bold))),
                      //   pw.Padding(
                      //       padding: const pw.EdgeInsets.all(6),
                      //       child: pw.Text(
                      //           (it.pvcWindowCount?.toString() ?? '-'))),
                      // ]),
                    ],
                  ),

                  pw.SizedBox(height: 8),

                  // Computed Values as a bordered table with rows
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(1)
                    },
                    children: [
                      pw.TableRow(
                          decoration:
                              pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text('Computed Values',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text('')),
                          ]),
                      // Area (sq.ft or running ft)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Area')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                                '${area.toStringAsFixed(2)} $unitLabel')),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('SLIDING NET')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(hasNet ? 'Yes' : 'No')),
                      ]),
                      // removed duplicate Unit Price row; Quantity and Value remain
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Quantity')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(qty.toString() + ' Pcs')),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Price')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('RS. ${value.toStringAsFixed(2)}')),
                      ]),
                    ],
                  ),

                  pw.SizedBox(height: 8),

                  pw.Row(children: [
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300)),
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Profile',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 6),
                            pw.Text(
                                'Profile Color : ${profileColor.isNotEmpty ? profileColor : '-'}'),
                            pw.Text(
                                'Mesh Type : ${meshType.isNotEmpty ? meshType : (hasNet ? '-' : '-')}'),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300)),
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Accessories',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 6),
                            pw.Text(
                                'Locking : ${locking.isNotEmpty ? locking : '-'}'),
                            pw.Text(
                                'Handle color : ${handleColor.isNotEmpty ? handleColor : '-'}'),
                          ],
                        ),
                      ),
                    ),
                  ]),

                  if (itemRemarks.isNotEmpty)
                    pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300)),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Remarks',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 6),
                              pw.Text(itemRemarks)
                            ])),
                  pw.SizedBox(height: 12),
                  pw.SizedBox(height: 12),
                ],
              );

              return pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Item title section with category and name
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '$topCategory - $itemName',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    // Item content section
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        leftColumn,
                        pw.SizedBox(width: 12),
                        pw.Expanded(child: rightColumn),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.Divider(),

            // Totals block (Subtotal -> Discount -> GST -> Total)
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: Rs.  ${subtotal.toStringAsFixed(2)}'),
                    pw.SizedBox(height: 6),
                    // show computed totals for area/length
                    pw.Text('Total Sq.Ft: ${totalSqFt.toStringAsFixed(2)}'),
                    pw.Text(
                        'Total Running Ft: ${totalRunningFt.toStringAsFixed(2)}'),
                    pw.SizedBox(height: 6),
                    // Compute discount: explicit amount preferred, else percent of subtotal
                    (() {
                      final explicitDisc = (quotation.discountAmount ?? 0);
                      final discPercent = (quotation.discountPercent ?? 0);
                      final discount = (explicitDisc > 0)
                          ? explicitDisc
                          : (discPercent > 0
                              ? subtotal * (discPercent / 100)
                              : 0.0);

                      if (discount > 0) {
                        return pw.Row(children: [
                          pw.Text('Discount : ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal)),
                          pw.SizedBox(height: 2),
                          pw.Text('Rs. -${discount.toStringAsFixed(2)}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]);
                      }
                      return pw.SizedBox();
                    })(),
                    pw.SizedBox(height: 6),
                    // GST (if enabled) — GST calculated on (subtotal - discount)
                    (() {
                      final explicitDisc = (quotation.discountAmount ?? 0);
                      final discPercent = (quotation.discountPercent ?? 0);
                      final discount = (explicitDisc > 0)
                          ? explicitDisc
                          : (discPercent > 0
                              ? subtotal * (discPercent / 100)
                              : 0.0);
                      final gstRate = (quotation.gstRate ?? 0);
                      final gstAmt = quotation.gstEnabled == true
                          ? (subtotal - discount) * (gstRate / 100)
                          : 0.0;
                      if (quotation.gstEnabled == true) {
                        return pw.Text(
                            'GST (${gstRate.toStringAsFixed(2)}%): Rs.  ${gstAmt.toStringAsFixed(2)}');
                      }
                      return pw.SizedBox();
                    })(),
                    pw.SizedBox(height: 6),
                    // Final total = subtotal - discount + gst
                    (() {
                      final explicitDisc = (quotation.discountAmount ?? 0);
                      final discPercent = (quotation.discountPercent ?? 0);
                      final discount = (explicitDisc > 0)
                          ? explicitDisc
                          : (discPercent > 0
                              ? subtotal * (discPercent / 100)
                              : 0.0);
                      final gstRate = (quotation.gstRate ?? 0);
                      final gstAmt = quotation.gstEnabled == true
                          ? (subtotal - discount) * (gstRate / 100)
                          : 0.0;
                      final finalTotal = subtotal - discount + gstAmt;
                      return pw.Text(
                          'Total: Rs.  ${finalTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold));
                    })(),
                  ])
            ]),

            // Quotation-level remarks (if present)
            if ((quotation.remarks ?? '').isNotEmpty)
              pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Quotation Remarks',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(quotation.remarks ?? '')
                      ]))
          ];
        },
      ),
    );

    // Add full-page project process image before Terms & Conditions
    try {
      final processImgBytes =
          await rootBundle.load('assets/images/Shyam_Process.png');
      final processImage = pw.MemoryImage(processImgBytes.buffer.asUint8List());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Center(
              child: pw.Image(processImage, fit: pw.BoxFit.cover),
            );
          },
        ),
      );
    } catch (_) {
      // If image not found, skip
    }

    // Terms & Conditions page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(09),
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
                          'Quatation validity 15 Days From the date of issue.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Fly screen mesh and Glasses are not covered under warranty.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Delivery period 45-50 days working days from the date of drawing approval by the buyer.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Any replacement or removal of window will be charge extra.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Rate will be re-calculated if there is a variation in height or width.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Transportation charge wil be extra (Additional) And Come under clients scope.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Any damage or breakage of sill / stone / Glass white will not be our responsibility.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Glass: There is no warranty for fragile material and protection for it wil be done by client.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Necessary scaffolding (If required) and power supply has to be provided by the client.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'For manufacturing defect client has to inform us within 48 hours after installation. After the time period Shyam Aluminium will be not liable for any defects.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'The window will be loose 3mm from the small size (Width / Height)'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'If Wall & Frame area gap in-between more than 3mm additional silicon fitting will be charge extra @ RS20 /- Per running foot.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Shyam Aluminium in any case is not responsible for the cleaning of dust and / or cement particles of window after installation.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'If the furniture is fitted in the frame of the window before the window is installed. Then Shyam Aluminium not is responsible water leakage for the window.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'The client will have to arrange a ladder and base (chokdi Ghodo / Tele Tower) for the window or fix above the height.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Shyam Aluminium also strongly recommends you to inform us in advance to update us if there is any plumbing and / or electrical and / or piped gas line passing through.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Pre & Post inspection on the site will be done by both client and us.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Quotation sent from Shyam Aluminium through whatsapp or mail will be considered valid.'),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                      text:
                          'Quotation has to be checked and verified by the clients.'),
                  pw.SizedBox(height: 4),
                ]),
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/${quotation.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // fetch existing PDF
  Future<File?> fetchQuotationPdf(String quotationId) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/$quotationId.pdf');
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
          case 'system':
            return item.system ?? '';
          case 'location':
            return item.location ?? '';
          case 'glassColor':
            return item.glassColor ?? '';
          case 'profileColor':
            return item.profileColor ?? '';
          case 'meshType':
            return item.meshType ?? '';
          case 'locking':
            return item.locking ?? '';
          case 'handleColor':
            return item.handleColor ?? '';
          case 'remarks':
            return item.remarks ?? '';
          case 'measurementType':
            return item.measurementType ?? 'sqft';
          case 'grillOrientation':
            return item.grillOrientation ?? 'horizontal';
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
        if (key == 'unitPrice') return item.unitPrice ?? 0.0;
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
        if (key == 'position') return item.position ?? 0;
        if (key == 'grillPipeCount') return item.grillPipeCount ?? 0;
        if (key == 'pvcWindowCount') return item.pvcWindowCount ?? 1;
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
      if (item is QuotationItem) {
        if (key == 'hasMosquitoNet') return item.hasMosquitoNet;
        if (key == 'hasGrill') return item.hasGrill == true;
        return false;
      }
      if (item is Map<String, dynamic>) {
        final v = item[key];
        if (v is bool) return v;
        return (v?.toString().toLowerCase() == 'true');
      }
    } catch (_) {}
    return false;
  }

  // Mirror the UI's _getDisplayName logic for PDF rendering.
  String _getDisplayNameForItem(dynamic item) {
    try {
      // If QuotationItem model is used
      if (item is QuotationItem) {
        // model doesn't have displayName; use itemName + subtype
        final name = item.itemName;
        final subtype = item.subtype ?? '';
        if (subtype.isNotEmpty) return '$name $subtype';
        return name;
      }

      if (item is Map<String, dynamic>) {
        final displayName = (item['displayName'] ?? '').toString().trim();
        if (displayName.isNotEmpty) return displayName;

        final name = (item['name'] as String?)?.trim() ??
            (item['itemName'] as String?)?.trim() ??
            '';

        dynamic subtypeRaw = item['subtype'] ?? item['subtypes'];
        String subtypeStr = '';
        if (subtypeRaw != null) {
          if (subtypeRaw is String) {
            subtypeStr = subtypeRaw.trim();
          } else if (subtypeRaw is List) {
            subtypeStr = subtypeRaw
                .map((e) => e == null ? '' : e.toString().trim())
                .where((s) => s.isNotEmpty)
                .join(' ');
          } else {
            subtypeStr = subtypeRaw.toString().trim();
          }
        }

        if (subtypeStr.isNotEmpty) {
          return name.isNotEmpty ? '$name $subtypeStr' : subtypeStr;
        }

        return name;
      }
    } catch (_) {}
    return '';
  }

  // area computation removed — printing rate per unit instead

  // _parseFirstDimension removed — no longer required after layout refactor.
}
