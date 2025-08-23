import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoiceHeaderWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = invoice['status']?.toString().toLowerCase() ?? '';
    final invoiceNumber = invoice['invoiceNumber']?.toString() ?? '';
    final date = invoice['date']?.toString() ?? '';
    final dueDate = invoice['dueDate']?.toString() ?? '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVOICE',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        invoiceNumber,
                        style: AppTheme.invoiceDataStyle(
                          isLight: theme.brightness == Brightness.light,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status, colorScheme),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getStatusTextColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Date',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(dueDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _isOverdue(dueDate, status)
                              ? AppTheme.errorLight
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'paid':
        return AppTheme.accentLight.withValues(alpha: 0.1);
      case 'pending':
        return AppTheme.warningLight.withValues(alpha: 0.1);
      case 'overdue':
        return AppTheme.errorLight.withValues(alpha: 0.1);
      case 'cancelled':
        return colorScheme.onSurface.withValues(alpha: 0.1);
      default:
        return colorScheme.primary.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.accentLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'overdue':
        return AppTheme.errorLight;
      case 'cancelled':
        return AppTheme.textSecondaryLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'overdue':
        return 'OVERDUE';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  bool _isOverdue(String dueDateStr, String status) {
    if (status == 'paid' || dueDateStr.isEmpty) return false;
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return DateTime.now().isAfter(dueDate) && status != 'paid';
    } catch (e) {
      return false;
    }
  }
}
