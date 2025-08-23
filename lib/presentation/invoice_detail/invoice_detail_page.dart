import 'package:flutter/material.dart';
import 'invoice_detail_card.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Map<String, dynamic>? invoiceData;

  const InvoiceDetailPage({Key? key, this.invoiceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = invoiceData ??
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Detail'),
      ),
      body: data == null
          ? Center(child: Text('No invoice data provided.'))
          : SingleChildScrollView(
              child: InvoiceDetailCard(invoiceData: data),
            ),
    );
  }
}
