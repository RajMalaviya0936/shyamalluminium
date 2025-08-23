import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  final ValueChanged<Map<String, dynamic>>? onFiltersApplied;

  const FilterBottomSheetWidget({
    super.key,
    this.currentFilters,
    this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _dateRange;
  String? _selectedCustomer;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'All',
    'Draft',
    'Sent',
    'Approved',
    'Converted',
    'Rejected',
  ];

  final List<String> _customerOptions = [
    'All Customers',
    'John Smith',
    'Sarah Johnson',
    'Michael Brown',
    'Emily Davis',
    'David Wilson',
    'Lisa Anderson',
    'Robert Taylor',
    'Jennifer Martinez',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters ?? {});
    _dateRange = _filters['dateRange'] as DateTimeRange?;
    _selectedCustomer = _filters['customer'] as String? ?? 'All Customers';
    _selectedStatus = _filters['status'] as String? ?? 'All';
  }

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
                  'Filter Quotations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _clearFilters();
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter
                  _buildFilterSection(
                    title: 'Date Range',
                    child: InkWell(
                      onTap: () => _selectDateRange(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateRange != null
                                  ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                                  : 'Select date range',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _dateRange != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Customer Filter
                  _buildFilterSection(
                    title: 'Customer',
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCustomer,
                          isExpanded: true,
                          items: _customerOptions.map((customer) {
                            return DropdownMenuItem<String>(
                              value: customer,
                              child: Text(customer),
                            );
                          }).toList(),
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedCustomer = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Status Filter
                  _buildFilterSection(
                    title: 'Status',
                    child: Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _statusOptions.map((status) {
                        final isSelected = _selectedStatus == status;
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedStatus = selected ? status : 'All';
                            });
                          },
                          selectedColor:
                              colorScheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _applyFilters();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _selectedCustomer = 'All Customers';
      _selectedStatus = 'All';
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_dateRange != null) {
      filters['dateRange'] = _dateRange;
    }

    if (_selectedCustomer != null && _selectedCustomer != 'All Customers') {
      filters['customer'] = _selectedCustomer;
    }

    if (_selectedStatus != null && _selectedStatus != 'All') {
      filters['status'] = _selectedStatus;
    }

    widget.onFiltersApplied?.call(filters);
    Navigator.pop(context);
  }
}
