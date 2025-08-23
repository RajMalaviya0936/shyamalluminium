import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositiveTrend;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const MetricCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositiveTrend,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor ??
                          colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: isPositiveTrend
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.warningLight,
                  size: 5.w,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: textColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: isPositiveTrend ? 'arrow_upward' : 'arrow_downward',
                  color: isPositiveTrend
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.warningLight,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  trend,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositiveTrend
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.warningLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
