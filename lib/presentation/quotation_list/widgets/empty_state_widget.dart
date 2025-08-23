import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? illustrationUrl;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Quotations Found',
    this.subtitle =
        'Create your first quotation to get started with managing your business quotes.',
    this.buttonText = 'Create First Quotation',
    this.onButtonPressed,
    this.illustrationUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    Container(
                      width: 60.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: illustrationUrl != null
                          ? CustomImageWidget(
                              imageUrl: illustrationUrl!,
                              width: 60.w,
                              height: 30.h,
                              fit: BoxFit.contain,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'description',
                                    color: colorScheme.primary,
                                    size: 48,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  width: 20.w,
                                  height: 1.h,
                                  decoration: BoxDecoration(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  width: 30.w,
                                  height: 1.h,
                                  decoration: BoxDecoration(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onButtonPressed?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: Colors.white,
                          size: 20,
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

                    SizedBox(height: 2.h),

                    // Secondary actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Navigate to product management
                            Navigator.pushNamed(context, '/product-management');
                          },
                          icon: CustomIconWidget(
                            iconName: 'inventory_2',
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          label: Text(
                            'Manage Products',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Navigate to dashboard
                            Navigator.pushNamed(context, '/dashboard');
                          },
                          icon: CustomIconWidget(
                            iconName: 'dashboard',
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          label: Text(
                            'Dashboard',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ), // Column
              ), // ConstrainedBox
            ); // SingleChildScrollView
          }, // builder
        ), // LayoutBuilder
      ), // Padding
    ); // Center
  }
}
