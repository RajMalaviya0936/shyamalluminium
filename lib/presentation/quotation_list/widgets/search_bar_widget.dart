import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onVoiceSearch;
  final TextEditingController? controller;
  final bool showVoiceSearch;
  final bool showFilter;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search quotations...',
    this.onChanged,
    this.onFilterTap,
    this.onVoiceSearch,
    this.controller,
    this.showVoiceSearch = true,
    this.showFilter = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),
          if (widget.showVoiceSearch) ...[
            Container(
              width: 1,
              height: 6.h,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _handleVoiceSearch();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(3.w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: _isListening ? 'mic' : 'mic_none',
                    color: _isListening
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          if (widget.showFilter) ...[
            Container(
              width: 1,
              height: 6.h,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFilterTap?.call();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'filter_list',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleVoiceSearch() async {
    if (_isListening) {
      // Stop listening
      setState(() {
        _isListening = false;
      });
      widget.onVoiceSearch?.call();
      return;
    }

    // Start listening
    setState(() {
      _isListening = true;
    });

    // Simulate voice search functionality
    // In a real implementation, you would integrate with speech_to_text package
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isListening = false;
      });

      // Mock voice search result
      const mockResult = "Aluminium door quotation";
      _controller.text = mockResult;
      widget.onChanged?.call(mockResult);

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice search: "$mockResult"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
