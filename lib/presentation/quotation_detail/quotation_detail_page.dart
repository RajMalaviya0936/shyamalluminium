import 'package:flutter/material.dart';

class QuotationDetailPage extends StatelessWidget {
  final Map<String, dynamic>? quotationData;

  const QuotationDetailPage({Key? key, this.quotationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = quotationData ??
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation Detail'),
      ),
      body: data == null
          ? Center(child: Text('No quotation data provided.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text('Quotation #: ${data['quotationNumber'] ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  Text('Customer: ${data['customerName'] ?? ''}'),
                  Text('Phone: ${data['customerPhone'] ?? ''}'),
                  Text('Address: ${data['customerAddress'] ?? ''}'),
                  Text('Date: ${data['date'] ?? ''}'),
                  Text('Status: ${data['status'] ?? ''}'),
                  Text('Total Amount: ${data['totalAmount'] ?? ''}'),
                  Text('GST Rate: ${data['gstRate'] ?? ''}%'),
                  Text('GST Amount: ${data['gstAmount'] ?? ''}'),
                  Text('Final Amount: ${data['finalAmount'] ?? ''}'),
                  SizedBox(height: 16),
                  Text('Items:',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...((data['items'] as List<dynamic>? ?? [])
                      .map((item) => Card(
                            child: ListTile(
                              title: Text(item['productName'] ?? ''),
                              subtitle: Text(
                                  'Category: ${item['category'] ?? ''}\nSize: ${item['width']} x ${item['height']} ${item['unit']}\nRate: ${item['rate']}\nQty: ${item['quantity']}\nAmount: ${item['amount']}'),
                            ),
                          ))),
                ],
              ),
            ),
    );
  }
}
