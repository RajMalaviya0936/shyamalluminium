import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalculationSummaryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double gstRate;
  final bool gstEnabled;
  final double discountPercent;
  final double discountAmount;

  const CalculationSummaryWidget({
    super.key,
    required this.products,
    this.gstRate = 18.0,
    this.gstEnabled = false,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
  });

  @override
  State<CalculationSummaryWidget> createState() =>
      _CalculationSummaryWidgetState();
}

class _CalculationSummaryWidgetState extends State<CalculationSummaryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final subtotal = _calculateSubtotal();
    final discount = widget.discountAmount > 0
        ? widget.discountAmount
        : subtotal * (widget.discountPercent / 100);
    final gst = widget.gstEnabled
        ? (subtotal - discount) * (widget.gstRate / 100)
        : 0.0;
    final total = subtotal - discount + gst;

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
                  iconName: 'calculate',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Calculation Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Quick Summary (Always Visible)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),

            // Detailed Breakdown (Expandable)
            if (_isExpanded) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Product-wise breakdown
                    ...widget.products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final area = _calculateArea(
                        product['width'] as double,
                        product['height'] as double,
                        product['unit'] as String,
                      );
                      final productTotal = area * (product['rate'] as double);

                      return Padding(
                        padding: EdgeInsets.only(
                            bottom:
                                index < widget.products.length - 1 ? 1.h : 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getDisplayName(product),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    '${area.toStringAsFixed(2)} sq ft',
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
                            Text(
                              '₹${productTotal.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    if (widget.products.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Divider(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 1.h),
                    ],

                    // Subtotal and adjustments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          '₹${subtotal.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Discount row
                    if (widget.discountAmount > 0 || widget.discountPercent > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          Text('- ₹${discount.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    SizedBox(height: 1.h),
                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.5),
                      thickness: 1.5,
                    ),
                    SizedBox(height: 1.h),
                    // GST row (if enabled) and Final Total
                    if (widget.gstEnabled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GST (${widget.gstRate.toStringAsFixed(2)}%)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          Text('₹${gst.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Additional Info
              // Container(
              //   padding: EdgeInsets.all(3.w),
              //   decoration: BoxDecoration(
              //     color: AppTheme.lightTheme.colorScheme.tertiary
              //         .withValues(alpha: 0.1),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Row(
              //     children: [
              //       CustomIconWidget(
              //         iconName: 'info',
              //         color: AppTheme.lightTheme.colorScheme.tertiary,
              //         size: 16,
              //       ),
              //       SizedBox(width: 2.w),
              //       Expanded(
              //         child: Text(
              //           'All prices are inclusive of GST. Final invoice will be generated after confirmation.',
              //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //                 color: AppTheme.lightTheme.colorScheme.onSurface
              //                     .withValues(alpha: 0.8),
              //               ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    for (final product in widget.products) {
      final area = _calculateArea(
        product['width'] as double,
        product['height'] as double,
        product['unit'] as String,
      );
      subtotal += area * (product['rate'] as double);
    }
    return subtotal;
  }

  double _calculateArea(double width, double height, String unit) {
    // If unit is mm, use the formula: area (sq ft) = (width * height) / 92903.04
    if (unit == 'mm') {
      return (width * height) / 92903.04;
    }
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

  // Mirror ProductListWidget._getDisplayName behavior for summary display
  String _getDisplayName(Map<String, dynamic> product) {
    final displayName = product['displayName'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final name = (product['name'] as String?)?.trim() ?? '';

    dynamic subtypeRaw = product['subtype'] ?? product['subtypes'];
    String subtypeStr = '';
    if (subtypeRaw != null) {
      if (subtypeRaw is String) {
        subtypeStr = subtypeRaw.trim();
      } else if (subtypeRaw is List) {
        subtypeStr = subtypeRaw
            .map((e) => e == null ? '' : e.toString().trim())
            .where((s) => s.isNotEmpty)
            .join(' ');
      } else {
        subtypeStr = subtypeRaw.toString().trim();
      }
    }

    if (subtypeStr.isNotEmpty) {
      return name.isNotEmpty ? '$name $subtypeStr' : subtypeStr;
    }

    return name;
  }
}
