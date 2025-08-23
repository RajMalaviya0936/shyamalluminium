import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? selectedProduct;
  final Function(Map<String, dynamic>) onProductSelected;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController rateController;
  final String selectedUnit;
  final Function(String) onUnitChanged;
  final String? productError;
  final String? dimensionError;
  final String? rateError;

  const ProductSelectionWidget({
    super.key,
    required this.products,
    this.selectedProduct,
    required this.onProductSelected,
    required this.widthController,
    required this.heightController,
    required this.rateController,
    required this.selectedUnit,
    required this.onUnitChanged,
    this.productError,
    this.dimensionError,
    this.rateError,
  });

  @override
  State<ProductSelectionWidget> createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget> {
  bool _isDropdownOpen = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.products;
      } else {
        _filteredProducts = widget.products
            .where((product) => (product['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  iconName: 'inventory_2',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Product Selection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Product Dropdown
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.productError != null
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.selectedProduct?['name'] ?? 'Select Product *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.selectedProduct != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                      ),
                    ),
                    Icon(
                      _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.productError != null)
              Padding(
                padding: EdgeInsets.only(top: 0.5.h, left: 3.w),
                child: Text(
                  widget.productError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                ),
              ),

            // Dropdown List
            if (_isDropdownOpen) ...[
              SizedBox(height: 1.h),
              Container(
                constraints: BoxConstraints(maxHeight: 30.h),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Search Field
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                        ),
                        onChanged: _filterProducts,
                      ),
                    ),
                    // Product List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return ListTile(
                            leading: Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                    product['category'] as String),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _getCategoryIcon(product['category'] as String),
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              product['name'] as String,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              '${product['category']} • \$${(product['rate'] as double).toStringAsFixed(2)}/sq ft',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () {
                              widget.onProductSelected(product);
                              widget.rateController.text =
                                  (product['rate'] as double)
                                      .toStringAsFixed(2);
                              setState(() {
                                _isDropdownOpen = false;
                                _searchController.clear();
                                _filteredProducts = widget.products;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 2.h),

            // Dimensions Section
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.widthController,
                    decoration: InputDecoration(
                      labelText: 'Width *',
                      hintText: '0.0',
                      prefixIcon: Icon(
                        Icons.straighten,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      errorText: widget.dimensionError,
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '×',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: TextFormField(
                    controller: widget.heightController,
                    decoration: InputDecoration(
                      labelText: 'Height *',
                      hintText: '0.0',
                      prefixIcon: Icon(
                        Icons.height,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedUnit,
                      items: ['inches', 'cm', 'feet'].map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onUnitChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Rate Field
            TextFormField(
              controller: widget.rateController,
              decoration: InputDecoration(
                labelText: 'Rate per sq ft *',
                hintText: '0.00',
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                errorText: widget.rateError,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
