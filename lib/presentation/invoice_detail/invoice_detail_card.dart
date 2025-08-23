import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InvoiceDetailCard extends StatelessWidget {
  final Map<String, dynamic> invoiceData;
  const InvoiceDetailCard({Key? key, required this.invoiceData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = invoiceData['items'] as List<dynamic>? ?? [];
    return Card(
      color: colorScheme.surfaceVariant,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice #: ${invoiceData['invoiceNumber'] ?? ''}',
                style: theme.textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Customer: ${invoiceData['customerName'] ?? ''}',
                style: theme.textTheme.bodyLarge),
            Text('Phone: ${invoiceData['customerPhone'] ?? ''}',
                style: theme.textTheme.bodyMedium),
            Text('Address: ${invoiceData['customerAddress'] ?? ''}',
                style: theme.textTheme.bodyMedium),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: Text('Date: ${invoiceData['date'] ?? ''}',
                        style: theme.textTheme.bodySmall)),
                Expanded(
                    child: Text('Due: ${invoiceData['dueDate'] ?? ''}',
                        style: theme.textTheme.bodySmall)),
              ],
            ),
            SizedBox(height: 8),
            Text('Status: ${invoiceData['status'] ?? ''}',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppTheme.accentLight)),
            Divider(height: 24),
            Text('Items', style: theme.textTheme.titleMedium),
            ...items.map((item) => Card(
                  color: colorScheme.surface,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Text(item['name'] ?? '',
                        style: theme.textTheme.bodyLarge),
                    subtitle:
                        Text('Qty: ${item['quantity']}  Rate: ${item['rate']}'),
                    trailing: Text('Total: ${item['total']}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                )),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: theme.textTheme.bodyMedium),
                Text('${invoiceData['subtotal'] ?? ''}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax:', style: theme.textTheme.bodyMedium),
                Text('${invoiceData['tax'] ?? ''}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('${invoiceData['total'] ?? ''}',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
