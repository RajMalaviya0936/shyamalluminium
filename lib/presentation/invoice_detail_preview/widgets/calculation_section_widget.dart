import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CalculationSectionWidget extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const CalculationSectionWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtotal = invoice['subtotal'] ?? 0.0;
    final tax = invoice['tax'] ?? 0.0;
    final total = invoice['total'] ?? 0.0;

    // Calculate GST percentage (assuming tax is GST)
    final gstPercentage = subtotal > 0 ? (tax / subtotal * 100) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'calculate',
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Invoice Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Calculation rows
            _buildCalculationRow(
              context,
              'Subtotal',
              '\$${_formatAmount(subtotal)}',
            ),

            const SizedBox(height: 12),

            _buildCalculationRow(
              context,
              'GST (${gstPercentage.toStringAsFixed(1)}%)',
              '\$${_formatAmount(tax)}',
              showPercentage: true,
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),

            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.primary.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    '\$${_formatAmount(total)}',
                    style: AppTheme.invoiceDataStyle(
                      isLight: theme.brightness == Brightness.light,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ).copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment status info
            _buildPaymentStatusInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(
    BuildContext context,
    String label,
    String amount, {
    bool showPercentage = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: AppTheme.invoiceDataStyle(
            isLight: theme.brightness == Brightness.light,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = invoice['status']?.toString().toLowerCase() ?? '';

    Color statusColor;
    String statusText;
    String statusDescription;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        statusColor = AppTheme.accentLight;
        statusText = 'Payment Received';
        statusDescription = 'This invoice has been fully paid';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.warningLight;
        statusText = 'Payment Pending';
        statusDescription = 'Awaiting payment from customer';
        statusIcon = Icons.access_time;
        break;
      case 'overdue':
        statusColor = AppTheme.errorLight;
        statusText = 'Payment Overdue';
        statusDescription = 'Payment is past the due date';
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = colorScheme.primary;
        statusText = 'Unknown Status';
        statusDescription = 'Payment status is unknown';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            size: 20,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  statusDescription,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) {
      return amount.toStringAsFixed(2);
    }
    return amount.toString();
  }
}
