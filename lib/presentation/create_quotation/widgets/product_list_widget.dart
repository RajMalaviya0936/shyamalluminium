import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(int) onRemoveProduct;
  final Function(int) onEditProduct;

  const ProductListWidget({
    super.key,
    required this.products,
    required this.onRemoveProduct,
    required this.onEditProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'list_alt',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Added Products (${products.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final product = products[index];
                final area = _calculateArea(
                  product['width'] as double,
                  product['height'] as double,
                  product['unit'] as String,
                );
                final total = area * (product['rate'] as double);

                return Dismissible(
                  key: Key('product_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'delete',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onDismissed: (direction) {
                    onRemoveProduct(index);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                    product['category'] as String),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getCategoryIcon(product['category'] as String),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    product['category'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => onEditProduct(index),
                              icon: CustomIconWidget(
                                iconName: 'edit',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Dimensions and calculations
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoItem(
                                    'Dimensions',
                                    '${(product['width'] as double).toStringAsFixed(1)} × ${(product['height'] as double).toStringAsFixed(1)} ${product['unit']}',
                                  ),
                                  _buildInfoItem(
                                    'Area',
                                    '${area.toStringAsFixed(2)} sq ft',
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoItem(
                                    'Rate',
                                    '\$${(product['rate'] as double).toStringAsFixed(2)}/sq ft',
                                  ),
                                  _buildInfoItem(
                                    'Total',
                                    '\$${total.toStringAsFixed(2)}',
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 12.sp : 11.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  double _calculateArea(double width, double height, String unit) {
    double widthInFeet = width;
    double heightInFeet = height;

    // Convert to feet if necessary
    switch (unit) {
      case 'inches':
        widthInFeet = width / 12;
        heightInFeet = height / 12;
        break;
      case 'cm':
        widthInFeet = width / 30.48;
        heightInFeet = height / 30.48;
        break;
    }

    return widthInFeet * heightInFeet;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return Colors.grey.shade600;
      case 'pvc':
        return Colors.blue.shade600;
      case 'wooden':
        return Colors.brown.shade600;
      case 'glass':
        return Colors.cyan.shade600;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return Icons.door_front_door;
      case 'pvc':
        return Icons.window;
      case 'wooden':
        return Icons.door_back_door;
      case 'glass':
        return Icons.help_outline;
      default:
        return Icons.inventory_2;
    }
  }
}
