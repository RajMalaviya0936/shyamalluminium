import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class InvoiceItemsListWidget extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoiceItemsListWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = invoice['items'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'inventory_2',
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No items found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                    iconName: 'inventory_2',
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Invoice Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} item${items.length != 1 ? 's' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Items list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 24,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                return _buildItemRow(context, item, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
      BuildContext context, Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = item['name']?.toString() ?? '';
    final quantity = item['quantity'] ?? 0;
    final rate = item['rate'] ?? 0.0;
    final total = item['total'] ?? 0.0;
    final category = item['category']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item thumbnail placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category),
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Quantity, Rate, Total row
                    Row(
                      children: [
                        Expanded(
                          child: _buildItemDetail(
                            context,
                            'Qty',
                            quantity.toString(),
                          ),
                        ),
                        Expanded(
                          child: _buildItemDetail(
                            context,
                            'Rate',
                            '\$${_formatAmount(rate)}',
                          ),
                        ),
                        Expanded(
                          child: _buildItemDetail(
                            context,
                            'Total',
                            '\$${_formatAmount(total)}',
                            isTotal: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: (isTotal
                  ? AppTheme.invoiceDataStyle(
                      isLight: theme.brightness == Brightness.light,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )
                  : theme.textTheme.bodyMedium)
              ?.copyWith(
            color: isTotal ? colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'door':
      case 'doors':
        return 'door_front';
      case 'window':
      case 'windows':
        return 'window';
      case 'cupboard':
      case 'cupboards':
        return 'kitchen';
      case 'frame':
      case 'frames':
        return 'crop_free';
      case 'panel':
      case 'panels':
        return 'view_module';
      default:
        return 'inventory_2';
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) {
      return amount.toStringAsFixed(2);
    }
    return amount.toString();
  }
}
