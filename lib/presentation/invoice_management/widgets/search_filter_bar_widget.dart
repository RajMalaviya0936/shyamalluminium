import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterBarWidget extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> activeFilters;
  final ValueChanged<List<String>> onFiltersChanged;
  final VoidCallback? onSortPressed;
  final List<String> searchSuggestions;

  const SearchFilterBarWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.activeFilters,
    required this.onFiltersChanged,
    this.onSortPressed,
    this.searchSuggestions = const [],
  });

  @override
  State<SearchFilterBarWidget> createState() => _SearchFilterBarWidgetState();
}

class _SearchFilterBarWidgetState extends State<SearchFilterBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  final List<String> _availableFilters = [
    'Paid',
    'Pending',
    'Overdue',
    'Cancelled',
    'This Week',
    'This Month',
    'Last 30 Days',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    widget.onSearchChanged(_searchController.text);
    setState(() {
      _showSuggestions =
          _searchController.text.isNotEmpty && _searchFocusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions =
          _searchController.text.isNotEmpty && _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _searchFocusNode.hasFocus
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText:
                                'Search by customer, invoice number, or date...',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: CustomIconWidget(
                                iconName: 'search',
                                size: 20,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();
                                    },
                                    icon: CustomIconWidget(
                                      iconName: 'clear',
                                      size: 20,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                          ),
                          style: theme.textTheme.bodyMedium,
                          onSubmitted: (value) {
                            _searchFocusNode.unfocus();
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onSortPressed?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'sort',
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.activeFilters.isNotEmpty ||
                    _availableFilters.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  _buildFilterChips(context),
                ],
              ],
            ),
          ),
          if (_showSuggestions && widget.searchSuggestions.isNotEmpty)
            _buildSearchSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableFilters.length +
            (widget.activeFilters.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0 && widget.activeFilters.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: ActionChip(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onFiltersChanged([]);
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Clear All',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.errorLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'clear',
                      size: 14,
                      color: AppTheme.errorLight,
                    ),
                  ],
                ),
                backgroundColor: AppTheme.errorLight.withValues(alpha: 0.1),
                side: BorderSide(
                    color: AppTheme.errorLight.withValues(alpha: 0.3)),
              ),
            );
          }

          final filterIndex =
              widget.activeFilters.isNotEmpty ? index - 1 : index;
          final filter = _availableFilters[filterIndex];
          final isActive = widget.activeFilters.contains(filter);

          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                final newFilters = List<String>.from(widget.activeFilters);
                if (selected) {
                  newFilters.add(filter);
                } else {
                  newFilters.remove(filter);
                }
                widget.onFiltersChanged(newFilters);
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isActive) ...[
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.all(0.5.w),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'check',
                        size: 10,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              selected: isActive,
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primary,
              side: BorderSide(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(maxHeight: 30.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = widget.searchSuggestions[index];
          return ListTile(
            dense: true,
            leading: CustomIconWidget(
              iconName: 'history',
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            title: Text(
              suggestion,
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              _searchController.text = suggestion;
              _searchFocusNode.unfocus();
              widget.onSearchChanged(suggestion);
            },
          );
        },
      ),
    );
  }
}
