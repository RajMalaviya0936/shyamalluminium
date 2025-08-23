import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/calculation_section_widget.dart';
import './widgets/customer_details_card_widget.dart';
import './widgets/invoice_header_widget.dart';
import './widgets/invoice_items_list_widget.dart';

class InvoiceDetailPreview extends StatefulWidget {
  const InvoiceDetailPreview({super.key});

  @override
  State<InvoiceDetailPreview> createState() => _InvoiceDetailPreviewState();
}

class _InvoiceDetailPreviewState extends State<InvoiceDetailPreview> {
  Map<String, dynamic>? _invoice;
  bool _isLoading = false;
  bool _isGeneratingPdf = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get invoice data from route arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _invoice = args;
    }
  }

  Future<void> _refreshInvoice() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
  }

  Future<void> _editInvoice() async {
    HapticFeedback.lightImpact();

    if (_invoice != null) {
      // Navigate to edit invoice screen
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.createQuotation,
        arguments: _invoice,
      );

      // If invoice was updated, refresh the data
      if (result != null) {
        setState(() {
          _invoice = result as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> _shareInvoice() async {
    HapticFeedback.mediumImpact();

    try {
      setState(() => _isGeneratingPdf = true);

      // Generate PDF
      final pdfBytes = await _generatePdfBytes();

      if (pdfBytes != null) {
        // Save PDF to temporary directory
        final tempDir = await getTemporaryDirectory();
        final invoiceNumber = _invoice?['invoiceNumber'] ?? 'invoice';
        final file = File('${tempDir.path}/$invoiceNumber.pdf');
        await file.writeAsBytes(pdfBytes);

        // Share the PDF file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Invoice ${_invoice?['invoiceNumber']} from Shyam Alluminium',
          subject: 'Invoice ${_invoice?['invoiceNumber']}',
        );
      }
    } catch (e) {
      _showErrorDialog(
          'Share Error', 'Failed to share invoice: ${e.toString()}');
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _regeneratePdf() async {
    HapticFeedback.mediumImpact();

    try {
      setState(() => _isGeneratingPdf = true);

      final pdfBytes = await _generatePdfBytes();

      if (pdfBytes != null) {
        // Show PDF preview
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'Invoice ${_invoice?['invoiceNumber']}',
        );
      }
    } catch (e) {
      _showErrorDialog('PDF Error', 'Failed to generate PDF: ${e.toString()}');
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _exportPdf() async {
    HapticFeedback.mediumImpact();

    try {
      setState(() => _isGeneratingPdf = true);

      final pdfBytes = await _generatePdfBytes();

      if (pdfBytes != null) {
        // Show save dialog
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Invoice_${_invoice?['invoiceNumber']}.pdf',
        );
      }
    } catch (e) {
      _showErrorDialog('Export Error', 'Failed to export PDF: ${e.toString()}');
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  Future<Uint8List?> _generatePdfBytes() async {
    if (_invoice == null) return null;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Create PdfColor values from Flutter Colors (normalized RGB) so we can
          // control alpha explicitly. PdfColor doesn't have withOpacity.
          final flutterPrimary = AppTheme.primaryLight;
          final flutterAccent = AppTheme.accentLight;
          final flutterSurface = AppTheme.surfaceLight;
          final flutterTextPrimary = AppTheme.textPrimaryLight;
          final flutterTextSecondary = AppTheme.textSecondaryLight;

          final primaryColor = PdfColor(flutterPrimary.red / 255,
              flutterPrimary.green / 255, flutterPrimary.blue / 255);
          final accentColor = PdfColor(flutterAccent.red / 255,
              flutterAccent.green / 255, flutterAccent.blue / 255);
          final surfaceColor = PdfColor(flutterSurface.red / 255,
              flutterSurface.green / 255, flutterSurface.blue / 255);
          final textPrimary = PdfColor(flutterTextPrimary.red / 255,
              flutterTextPrimary.green / 255, flutterTextPrimary.blue / 255);
          final textSecondary = PdfColor(
              flutterTextSecondary.red / 255,
              flutterTextSecondary.green / 255,
              flutterTextSecondary.blue / 255);

          return pw.Container(
            color: surfaceColor,
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          _invoice!['invoiceNumber'] ?? '',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(_formatDate(_invoice!['date'] ?? ''),
                            style: pw.TextStyle(color: textSecondary)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(color: accentColor),
                pw.SizedBox(height: 16),
                pw.Text('Bill To:',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor)),
                pw.SizedBox(height: 8),
                pw.Text(_invoice!['customerName'] ?? '',
                    style: pw.TextStyle(color: textPrimary)),
                pw.Text(_invoice!['customerPhone'] ?? '',
                    style: pw.TextStyle(color: textSecondary)),
                pw.Text(_invoice!['customerAddress'] ?? '',
                    style: pw.TextStyle(color: textSecondary)),
                pw.SizedBox(height: 24),
                pw.Table(
                  border: pw.TableBorder.all(color: accentColor),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                          color: PdfColor(
                              flutterPrimary.red / 255,
                              flutterPrimary.green / 255,
                              flutterPrimary.blue / 255,
                              0.08)),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: textPrimary)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: textPrimary)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rate',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: textPrimary)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: textPrimary)),
                        ),
                      ],
                    ),
                    ...(_invoice!['items'] as List<dynamic>? ?? []).map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item['name'] ?? '',
                                style: pw.TextStyle(color: textPrimary)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${item['quantity'] ?? 0}',
                                style: pw.TextStyle(color: textSecondary)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(' 24${_formatAmount(item['rate'])}',
                                style: pw.TextStyle(color: textSecondary)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(' 24${_formatAmount(item['total'])}',
                                style: pw.TextStyle(
                                    color: accentColor,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            'Subtotal:  24${_formatAmount(_invoice!['subtotal'])}',
                            style: pw.TextStyle(color: textPrimary)),
                        pw.Text('Tax:  24${_formatAmount(_invoice!['tax'])}',
                            style: pw.TextStyle(color: textSecondary)),
                        pw.Divider(thickness: 2, color: accentColor),
                        pw.Text(
                            'Total:  24${_formatAmount(_invoice!['total'])}',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: accentColor)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Text('Thank you for your business!',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) {
      return amount.toStringAsFixed(2);
    }
    return amount.toString();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Detail'),
        ),
        body: const Center(
          child: Text('No invoice data available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Invoice Detail',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isGeneratingPdf ? null : _editInvoice,
            icon: CustomIconWidget(
              iconName: 'edit',
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: _isGeneratingPdf ? null : _shareInvoice,
            icon: _isGeneratingPdf
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'share',
                    size: 24,
                    color: colorScheme.primary,
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInvoice,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Header
              InvoiceHeaderWidget(invoice: _invoice!),

              const SizedBox(height: 24),

              // Customer Details Card
              CustomerDetailsCardWidget(invoice: _invoice!),

              const SizedBox(height: 24),

              // Invoice Items List
              InvoiceItemsListWidget(invoice: _invoice!),

              const SizedBox(height: 24),

              // Calculation Section
              CalculationSectionWidget(invoice: _invoice!),

              const SizedBox(height: 32),

              // Action Buttons
              ActionButtonsWidget(
                isLoading: _isGeneratingPdf,
                onEdit: _editInvoice,
                onRegeneratePdf: _regeneratePdf,
                onExport: _exportPdf,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
