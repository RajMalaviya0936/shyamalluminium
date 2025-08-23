import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onRegeneratePdf;
  final VoidCallback onExport;

  const ActionButtonsWidget({
    super.key,
    required this.isLoading,
    required this.onEdit,
    required this.onRegeneratePdf,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Primary action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onEdit,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text('Edit Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Secondary action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onRegeneratePdf,
                    icon: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'picture_as_pdf',
                            size: 18,
                            color: colorScheme.primary,
                          ),
                    label: const Text('View PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onExport,
                    icon: CustomIconWidget(
                      iconName: 'file_download',
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional actions
            _buildActionTile(
              context,
              icon: 'copy_all',
              title: 'Copy Invoice Number',
              subtitle: 'Copy to clipboard',
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(const ClipboardData(text: 'INV-2024-001'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Invoice number copied to clipboard'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildActionTile(
              context,
              icon: 'email',
              title: 'Email Invoice',
              subtitle: 'Send via email',
              onTap: () {
                HapticFeedback.lightImpact();
                // Implement email functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email functionality coming soon'),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildActionTile(
              context,
              icon: 'print',
              title: 'Print Invoice',
              subtitle: 'Print to local printer',
              onTap: () {
                HapticFeedback.lightImpact();
                // Implement print functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Print functionality coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          size: 20,
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        size: 20,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
