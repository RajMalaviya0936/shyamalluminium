import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductSelectionWidget extends StatefulWidget {
  final List<String> topCategories;
  final String? selectedTopCategory;
  final Function(String?) onTopCategoryChanged;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? selectedProduct;
  final Function(Map<String, dynamic>) onProductSelected;
  final bool hasMosquitoNet;
  final Function(bool) onMosquitoNetChanged;
  final TextEditingController glassColorController;
  final TextEditingController positionController;
  final TextEditingController locationController;
  final TextEditingController systemController;
  final TextEditingController profileColorController;
  final TextEditingController meshTypeController;
  final TextEditingController lockingController;
  final TextEditingController handleColorController;
  final TextEditingController itemRemarksController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController rateController;
  final TextEditingController unitPriceController;
  final bool hasGrill;
  final Function(bool) onHasGrillChanged;
  final String grillOrientation;
  final Function(String) onGrillOrientationChanged;
  final TextEditingController grillPipeController;
  final TextEditingController pvcCountController;
  final String selectedUnit;
  final Function(String) onUnitChanged;
  final String selectedMeasurement; // 'sqft' or 'runningft'
  final Function(String) onMeasurementChanged;
  final String? productError;
  final String? dimensionError;
  final String? rateError;

  const ProductSelectionWidget({
    super.key,
    required this.topCategories,
    this.selectedTopCategory,
    required this.onTopCategoryChanged,
    required this.products,
    this.selectedProduct,
    required this.onProductSelected,
    this.hasMosquitoNet = false,
    required this.onMosquitoNetChanged,
    required this.glassColorController,
    required this.positionController,
    required this.locationController,
    required this.systemController,
    required this.profileColorController,
    required this.meshTypeController,
    required this.lockingController,
    required this.handleColorController,
    required this.itemRemarksController,
    required this.widthController,
    required this.heightController,
    required this.rateController,
    required this.unitPriceController,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.selectedMeasurement,
    required this.onMeasurementChanged,
    required this.hasGrill,
    required this.onHasGrillChanged,
    required this.grillOrientation,
    required this.onGrillOrientationChanged,
    required this.grillPipeController,
    required this.pvcCountController,
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
  bool _isZHydrolic = false;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _isZHydrolic = widget.selectedProduct != null &&
        (widget.selectedProduct!['name'] == 'Z Hydrolic');
  }

  @override
  void didUpdateWidget(covariant ProductSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isZHydrolic = widget.selectedProduct != null &&
        (widget.selectedProduct!['name'] == 'Z Hydrolic');
    // ensure pvc count is set to 1 when Z Hydrolic is selected
    if (_isZHydrolic) {
      try {
        widget.pvcCountController.text = '1';
      } catch (_) {}
    }
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

            // Top Category Selection
            DropdownButtonFormField<String>(
              value: widget.selectedTopCategory,
              items: widget.topCategories
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: widget.onTopCategoryChanged,
              decoration: InputDecoration(
                labelText: 'Select Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            SizedBox(height: 2.h),

            DropdownButtonFormField<int>(
              value: widget.selectedProduct != null
                  ? widget.selectedProduct!['id'] as int
                  : null,
              items: widget.products
                  .where((p) => p['category'] == 'Main')
                  .map((product) => DropdownMenuItem<int>(
                        value: product['id'] as int,
                        child: Text(product['name']),
                      ))
                  .toList(),
              onChanged: (productId) {
                if (productId != null) {
                  final selected =
                      widget.products.firstWhere((p) => p['id'] == productId);
                  widget.onProductSelected(selected);
                  // If the product typically includes a mosquito/slider net, default checkbox to true
                  try {
                    if (_shouldShowMosquitoOption(selected)) {
                      widget.onMosquitoNetChanged(true);
                    }
                  } catch (_) {}
                  // If Z Hydrolic is selected, enforce a single window (no partitions)
                  // For Dumal / Z openable default to 2 panes so preview shows partitions
                  setState(() {
                    _isZHydrolic = selected['name'] == 'Z Hydrolic';
                    if (_isZHydrolic) {
                      try {
                        widget.pvcCountController.text = '1';
                      } catch (_) {}
                    } else if (selected['name'] == 'Dumal' ||
                        selected['name'] == 'Z openable') {
                      try {
                        final cur = widget.pvcCountController.text.trim();
                        if (cur.isEmpty || cur == '1') {
                          widget.pvcCountController.text = '2';
                        }
                      } catch (_) {}
                    }
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Select Main Product *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),

            if (widget.selectedProduct != null &&
                widget.selectedProduct!['name'] == 'Dumal') ...[
              DropdownButtonFormField<String>(
                // Show currently selected subtype if present on the selectedProduct
                value: widget.selectedProduct != null
                    ? widget.selectedProduct!['selectedSubtype'] as String?
                    : null,
                items: (widget.selectedProduct!['subtypes'] as List? ?? [])
                    .map<DropdownMenuItem<String>>(
                        (sub) => DropdownMenuItem<String>(
                              value: sub['name'] as String,
                              child: Text(sub['name'] as String),
                            ))
                    .toList(),
                onChanged: (subtype) {
                  if (subtype == null) return;
                  // Copy the selected product and add/update the selectedSubtype
                  final updated =
                      Map<String, dynamic>.from(widget.selectedProduct!);
                  updated['selectedSubtype'] = subtype;
                  widget.onProductSelected(updated);
                  // If subtype name contains 'net' default mosquito net option
                  try {
                    if (subtype.toString().toLowerCase().contains('net')) {
                      widget.onMosquitoNetChanged(true);
                    }
                  } catch (_) {}
                },
                decoration: InputDecoration(
                  labelText: 'Select Dumal Subtype *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
            ],

            if (widget.selectedProduct != null &&
                widget.selectedProduct!['name'] == 'Z openable') ...[
              DropdownButtonFormField<String>(
                value: widget.selectedProduct != null
                    ? widget.selectedProduct!['selectedSubtype'] as String?
                    : null,
                items: (widget.selectedProduct!['subtypes'] as List? ?? [])
                    .map<DropdownMenuItem<String>>(
                        (sub) => DropdownMenuItem<String>(
                              value: sub['name'] as String,
                              child: Text(sub['name'] as String),
                            ))
                    .toList(),
                onChanged: (subtype) {
                  if (subtype == null) return;
                  final updated =
                      Map<String, dynamic>.from(widget.selectedProduct!);
                  updated['selectedSubtype'] = subtype;
                  widget.onProductSelected(updated);
                  try {
                    if (subtype.toString().toLowerCase().contains('net')) {
                      widget.onMosquitoNetChanged(true);
                    }
                  } catch (_) {}
                },
                decoration: InputDecoration(
                  labelText: 'Select Z Openable Subtype *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
            ],

            // ...existing code...

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
                      items: ['inches', 'cm', 'feet', 'mm'].map((unit) {
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

            // Measurement type dropdown (Sq Ft vs Running Ft)
            Row(children: [
              Text('Measure:', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.selectedMeasurement,
                    items: [
                      DropdownMenuItem(value: 'sqft', child: Text('Sq Ft')),
                      DropdownMenuItem(
                          value: 'runningft', child: Text('Running Ft')),
                    ],
                    onChanged: (v) {
                      if (v != null) widget.onMeasurementChanged(v);
                    },
                  ),
                ),
              ),
            ]),

            // Rate Field
            TextFormField(
              controller: widget.rateController,
              decoration: InputDecoration(
                labelText: 'Unit Price (₹) *',
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
            SizedBox(height: 2.h),

            // Unit Price Field (editable by user)
            // TextFormField(
            //   controller: widget.unitPriceController,
            //   decoration: InputDecoration(
            //     labelText: 'Unit Price *',
            //     hintText: '0.00',
            //     prefixIcon: Icon(
            //       Icons.price_check,
            //       color: AppTheme.lightTheme.colorScheme.primary,
            //     ),
            //   ),
            //   keyboardType: TextInputType.numberWithOptions(decimal: true),
            //   textInputAction: TextInputAction.done,
            //   inputFormatters: [
            //     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //   ],
            // ),
            // SizedBox(height: 2.h),

            // Add Grill option - responsive layout to avoid overflow on small screens
            // Grill options row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: widget.hasGrill,
                  onChanged: (v) {
                    if (v != null) widget.onHasGrillChanged(v);
                  },
                ),
                SizedBox(width: 2.w),
                Text('Add Grill',
                    style: Theme.of(context).textTheme.bodyMedium),
                if (widget.hasGrill) ...[
                  SizedBox(width: 3.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.grillOrientation,
                        items: [
                          DropdownMenuItem(
                              value: 'horizontal', child: Text('Horizontal')),
                          DropdownMenuItem(
                              value: 'vertical', child: Text('Vertical')),
                        ],
                        onChanged: (s) {
                          if (s != null) widget.onGrillOrientationChanged(s);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  SizedBox(
                    width: 28.w,
                    child: TextFormField(
                      controller: widget.grillPipeController,
                      decoration: InputDecoration(
                        labelText: 'Pipe Count',
                        hintText: 'e.g., 3',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ],
            ),

            // PVC window count row (separate line)
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Window Count:'),
                SizedBox(width: 2.w),
                SizedBox(
                  width: 20.w,
                  child: TextFormField(
                    controller: widget.pvcCountController,
                    decoration: InputDecoration(hintText: '1'),
                    keyboardType: TextInputType.number,
                    readOnly: _isZHydrolic,
                    enabled: !_isZHydrolic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Mosquito Net option - shown for all products now
            Row(
              children: [
                Checkbox(
                  value: widget.hasMosquitoNet,
                  onChanged: (v) {
                    if (v != null) widget.onMosquitoNetChanged(v);
                  },
                ),
                SizedBox(width: 2.w),
                Text('Sliding Net',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            SizedBox(height: 2.h),

            // Glass color input (free text) - shown for all products now

            // Additional metadata fields (Position, Location, System...)
            // TextFormField(
            //   controller: widget.positionController,
            //   decoration: InputDecoration(
            //     labelText: 'Position (optional)',
            //     hintText: 'e.g., 1, 2, 3',
            //     prefixIcon: Icon(Icons.pin_drop,
            //         color: AppTheme.lightTheme.colorScheme.primary),
            //   ),
            //   keyboardType: TextInputType.number,
            //   textInputAction: TextInputAction.next,
            // ),
            // SizedBox(height: 2.h),

            TextFormField(
              controller: widget.locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Living Room / Kitchen',
                prefixIcon: Icon(Icons.location_on,
                    color: AppTheme.lightTheme.colorScheme.primary),
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // TextFormField(
            //   controller: widget.systemController,
            //   decoration: InputDecoration(
            //     labelText: 'Profile System',
            //     hintText: 'e.g., 2-track / 3-track',
            //     prefixIcon: Icon(Icons.settings,
            //         color: AppTheme.lightTheme.colorScheme.primary),
            //   ),
            //   textInputAction: TextInputAction.next,
            // ),
            // SizedBox(height: 2.h),

            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: widget.profileColorController,
                  decoration: InputDecoration(
                    labelText: 'Profile Color',
                    prefixIcon: Icon(Icons.format_paint,
                        color: AppTheme.lightTheme.colorScheme.primary),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: widget.meshTypeController,
                  decoration: InputDecoration(
                    labelText: 'Mesh Type',
                    prefixIcon: Icon(Icons.grid_view,
                        color: AppTheme.lightTheme.colorScheme.primary),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ]),
            SizedBox(height: 2.h),
            TextFormField(
              controller: widget.glassColorController,
              decoration: InputDecoration(
                labelText: 'Glass Color',
                hintText: 'e.g., Clear / Tinted / Frosted',
                prefixIcon: Icon(
                  Icons.color_lens,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: widget.lockingController,
                  decoration: InputDecoration(
                    labelText: 'Locking',
                    prefixIcon: Icon(Icons.lock,
                        color: AppTheme.lightTheme.colorScheme.primary),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: widget.handleColorController,
                  decoration: InputDecoration(
                    labelText: 'Handle Color',
                    prefixIcon: Icon(Icons.color_lens,
                        color: AppTheme.lightTheme.colorScheme.primary),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ]),
            SizedBox(height: 2.h),

            TextFormField(
              controller: widget.itemRemarksController,
              decoration: InputDecoration(
                labelText: 'Item Remarks',
                hintText: 'Optional notes for this item',
                prefixIcon: Icon(Icons.note,
                    color: AppTheme.lightTheme.colorScheme.primary),
              ),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  bool _shouldShowGlassColorField(Map<String, dynamic>? product) {
    if (product == null) return false;
    final name = (product['name'] as String).toLowerCase();
    final category = (product['category'] as String).toLowerCase();
    if (category.contains('glass')) return true;
    if (name.contains('window')) return true;
    return false;
  }

  bool _shouldShowMosquitoOption(Map<String, dynamic>? product) {
    if (product == null) return false;
    final name = (product['name'] as String).toLowerCase();
    final category = (product['category'] as String).toLowerCase();

    // Show for PVC sliding windows or any aluminium frames
    if (name.contains('pvc') && name.contains('window')) return true;
    if (category.contains('aluminium')) return true;
    return false;
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
