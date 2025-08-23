import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CustomerDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const CustomerDetailsCardWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = invoice['customerName']?.toString() ?? '';
    final customerPhone = invoice['customerPhone']?.toString() ?? '';
    final customerAddress = invoice['customerAddress']?.toString() ?? '';

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
                    iconName: 'person',
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Customer Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customerName.isNotEmpty) ...[
              _buildDetailRow(
                context,
                icon: 'business',
                label: 'Name',
                value: customerName,
              ),
              const SizedBox(height: 12),
            ],
            if (customerPhone.isNotEmpty) ...[
              _buildDetailRow(
                context,
                icon: 'phone',
                label: 'Phone',
                value: customerPhone,
                isPhone: true,
              ),
              const SizedBox(height: 12),
            ],
            if (customerAddress.isNotEmpty) ...[
              _buildDetailRow(
                context,
                icon: 'location_on',
                label: 'Address',
                value: customerAddress,
                isAddress: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    bool isPhone = false,
    bool isAddress = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment:
          isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 18,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isPhone ? FontWeight.w500 : FontWeight.w400,
                  height: isAddress ? 1.4 : null,
                ),
              ),
            ],
          ),
        ),
        if (isPhone) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              // Launch phone dialer
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: CustomIconWidget(
                iconName: 'call',
                size: 16,
                color: AppTheme.accentLight,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
