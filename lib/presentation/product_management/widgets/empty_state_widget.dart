import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final String category;
  final String searchQuery;
  final VoidCallback? onAddProduct;

  const EmptyStateWidget({
    super.key,
    required this.category,
    this.searchQuery = '',
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName:
                      isSearching ? 'search_off' : _getCategoryIcon(category),
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  size: 15.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isSearching ? 'No products found' : _getEmptyTitle(category),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              isSearching
                  ? 'Try adjusting your search terms or filters'
                  : _getEmptyDescription(category),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onAddProduct,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(
                  'Add Your First Product',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return 'window';
      case 'pvc':
        return 'kitchen';
      case 'wooden':
        return 'door_front';
      case 'glass':
        return 'crop_free';
      default:
        return 'inventory_2';
    }
  }

  String _getEmptyTitle(String category) {
    if (category.toLowerCase() == 'all') {
      return 'No products yet';
    }
    return 'No $category products';
  }

  String _getEmptyDescription(String category) {
    if (category.toLowerCase() == 'all') {
      return 'Start building your inventory by adding your first product. You can organize them by categories like Aluminium, PVC, Wooden, and Glass.';
    }
    return 'Add $category products to your inventory. Include details like dimensions, pricing, and images to create professional quotations.';
  }
}
