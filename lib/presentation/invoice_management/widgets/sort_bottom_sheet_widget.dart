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
  statusPaid,
  statusPending,
}

class SortBottomSheetWidget extends StatefulWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheetWidget> createState() => _SortBottomSheetWidgetState();
}

class _SortBottomSheetWidgetState extends State<SortBottomSheetWidget> {
  late SortOption _selectedSort;

  final List<_SortOptionData> _sortOptions = [
    _SortOptionData(
      option: SortOption.dateNewest,
      title: 'Date (Newest First)',
      subtitle: 'Most recent invoices first',
      icon: 'calendar_today',
    ),
    _SortOptionData(
      option: SortOption.dateOldest,
      title: 'Date (Oldest First)',
      subtitle: 'Oldest invoices first',
      icon: 'history',
    ),
    _SortOptionData(
      option: SortOption.amountHighest,
      title: 'Amount (Highest First)',
      subtitle: 'Largest amounts first',
      icon: 'trending_up',
    ),
    _SortOptionData(
      option: SortOption.amountLowest,
      title: 'Amount (Lowest First)',
      subtitle: 'Smallest amounts first',
      icon: 'trending_down',
    ),
    _SortOptionData(
      option: SortOption.customerAZ,
      title: 'Customer Name (A-Z)',
      subtitle: 'Alphabetical order',
      icon: 'sort_by_alpha',
    ),
    _SortOptionData(
      option: SortOption.customerZA,
      title: 'Customer Name (Z-A)',
      subtitle: 'Reverse alphabetical order',
      icon: 'sort_by_alpha',
    ),
    _SortOptionData(
      option: SortOption.statusPaid,
      title: 'Status (Paid First)',
      subtitle: 'Paid invoices first',
      icon: 'check_circle',
    ),
    _SortOptionData(
      option: SortOption.statusPending,
      title: 'Status (Pending First)',
      subtitle: 'Pending invoices first',
      icon: 'schedule',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'sort',
                  size: 24,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Sort Invoices',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),

          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Sort options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _sortOptions.length,
              itemBuilder: (context, index) {
                final option = _sortOptions[index];
                final isSelected = _selectedSort == option.option;

                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: option.icon,
                      size: 20,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  title: Text(
                    option.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    option.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          size: 20,
                          color: colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedSort = option.option;
                    });
                  },
                );
              },
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onSortChanged(_selectedSort);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Apply Sort'),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required SortOption currentSort,
    required ValueChanged<SortOption> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSort: currentSort,
        onSortChanged: onSortChanged,
      ),
    );
  }
}

class _SortOptionData {
  final SortOption option;
  final String title;
  final String subtitle;
  final String icon;

  const _SortOptionData({
    required this.option,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
