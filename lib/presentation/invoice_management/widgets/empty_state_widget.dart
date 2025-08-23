import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String iconName;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onButtonPressed,
    this.iconName = 'receipt_long',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  size: 15.w,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action button
            if (onButtonPressed != null)
              SizedBox(
                width: 60.w,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onButtonPressed?.call();
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Factory constructor for no invoices state
  factory EmptyStateWidget.noInvoices({VoidCallback? onCreateInvoice}) {
    return EmptyStateWidget(
      title: 'No Invoices Yet',
      subtitle:
          'Start creating your first invoice to track payments and manage your business efficiently.',
      buttonText: 'Create Invoice',
      onButtonPressed: onCreateInvoice,
      iconName: 'receipt_long',
    );
  }

  /// Factory constructor for no search results
  factory EmptyStateWidget.noSearchResults({required String query}) {
    return EmptyStateWidget(
      title: 'No Results Found',
      subtitle:
          'We couldn\'t find any invoices matching "$query". Try adjusting your search terms or filters.',
      buttonText: 'Clear Search',
      iconName: 'search_off',
    );
  }

  /// Factory constructor for offline state
  factory EmptyStateWidget.offline() {
    return EmptyStateWidget(
      title: 'You\'re Offline',
      subtitle:
          'Your invoices are safely stored locally. You can still view and manage your existing invoices.',
      buttonText: 'Refresh',
      iconName: 'wifi_off',
    );
  }
}
