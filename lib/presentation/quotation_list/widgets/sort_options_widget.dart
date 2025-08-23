import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  customerAZ,
  customerZA,
}

class SortOptionsWidget extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption>? onSortChanged;

  const SortOptionsWidget({
    super.key,
    required this.currentSort,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Sort options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                _buildSortOption(
                  context,
                  title: 'Date (Newest First)',
                  subtitle: 'Most recent quotations first',
                  option: SortOption.dateNewest,
                  icon: 'calendar_today',
                ),
                _buildSortOption(
                  context,
                  title: 'Date (Oldest First)',
                  subtitle: 'Oldest quotations first',
                  option: SortOption.dateOldest,
                  icon: 'history',
                ),
                _buildSortOption(
                  context,
                  title: 'Amount (Highest First)',
                  subtitle: 'Highest value quotations first',
                  option: SortOption.amountHighest,
                  icon: 'trending_up',
                ),
                _buildSortOption(
                  context,
                  title: 'Amount (Lowest First)',
                  subtitle: 'Lowest value quotations first',
                  option: SortOption.amountLowest,
                  icon: 'trending_down',
                ),
                _buildSortOption(
                  context,
                  title: 'Customer (A-Z)',
                  subtitle: 'Alphabetical order by customer name',
                  option: SortOption.customerAZ,
                  icon: 'sort_by_alpha',
                ),
                _buildSortOption(
                  context,
                  title: 'Customer (Z-A)',
                  subtitle: 'Reverse alphabetical order',
                  option: SortOption.customerZA,
                  icon: 'sort_by_alpha',
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required SortOption option,
    required String icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentSort == option;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onSortChanged?.call(option);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
