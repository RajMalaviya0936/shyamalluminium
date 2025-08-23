import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionsToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onClearSelection;
  final VoidCallback? onExportMultiple;
  final VoidCallback? onDeleteMultiple;
  final VoidCallback? onMarkPaid;

  const BulkActionsToolbarWidget({
    super.key,
    required this.selectedCount,
    this.onClearSelection,
    this.onExportMultiple,
    this.onDeleteMultiple,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: selectedCount > 0
          ? Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    // Selection info
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'check',
                              size: 16,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$selectedCount selected',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Tap to perform bulk actions',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action buttons (horizontally scrollable to avoid overflow)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 10.h),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(
                              context,
                              icon: 'file_download',
                              label: 'Export',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                onExportMultiple?.call();
                              },
                            ),
                            SizedBox(width: 2.w),
                            _buildActionButton(
                              context,
                              icon: 'check_circle',
                              label: 'Mark Paid',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                onMarkPaid?.call();
                              },
                            ),
                            SizedBox(width: 2.w),
                            _buildActionButton(
                              context,
                              icon: 'delete',
                              label: 'Delete',
                              color: AppTheme.errorLight,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _showDeleteConfirmation(context);
                              },
                            ),
                            // SizedBox(width: 2.w),
                            // _buildActionButton(
                            //   context,
                            //   icon: 'close',
                            //   label: 'Clear',
                            //   onPressed: () {
                            //     HapticFeedback.lightImpact();
                            //     onClearSelection?.call();
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final buttonColor = color ?? colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: buttonColor.withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: CustomIconWidget(
              iconName: icon,
              size: 20,
              color: buttonColor,
            ),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 4.h,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: buttonColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Invoices'),
        content: Text(
          'Are you sure you want to delete $selectedCount selected invoice${selectedCount > 1 ? 's' : ''}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteMultiple?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
