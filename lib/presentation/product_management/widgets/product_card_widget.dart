import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool isMultiSelectMode;
  final ValueChanged<bool?>? onSelectionChanged;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('product_${product["id"]}'),
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: colorScheme.primary,
        icon: 'edit',
        label: 'Edit',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: colorScheme.error,
        icon: 'delete',
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isMultiSelectMode) {
            onSelectionChanged?.call(!isSelected);
          } else {
            onTap?.call();
          }
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onSelectionChanged?.call(!isSelected);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                if (isMultiSelectMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: onSelectionChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  SizedBox(width: 2.w),
                ],
                _buildProductImage(),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildProductDetails(theme),
                ),
                _buildProductActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: product["image"] != null &&
                (product["image"] as String).isNotEmpty
            ? CustomImageWidget(
                imageUrl: product["image"] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              )
            : Center(
                child: CustomIconWidget(
                  iconName:
                      _getCategoryIcon(product["category"] as String? ?? ""),
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                  size: 6.w,
                ),
              ),
      ),
    );
  }

  Widget _buildProductDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product["name"] as String? ?? "Unknown Product",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: _getCategoryColor(product["category"] as String? ?? "")
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product["category"] as String? ?? "Unknown",
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getCategoryColor(product["category"] as String? ?? ""),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          "\$${(product["price"] as double? ?? 0.0).toStringAsFixed(2)}",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (product["description"] != null &&
            (product["description"] as String).isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(
            product["description"] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildProductActions(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'delete':
            _showDeleteConfirmation(context).then((confirmed) {
              if (confirmed == true) {
                onDelete?.call();
              }
            });
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'edit',
                color: Theme.of(context).colorScheme.onSurface,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'content_copy',
                color: Theme.of(context).colorScheme.onSurface,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              const Text('Duplicate'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(2.w),
        child: CustomIconWidget(
          iconName: 'more_vert',
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required String icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      color: color,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product["name"]}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return const Color(0xFF607D8B);
      case 'pvc':
        return const Color(0xFF4CAF50);
      case 'wooden':
        return const Color(0xFF8D6E63);
      case 'glass':
        return const Color(0xFF2196F3);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
