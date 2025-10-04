import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/pdf_service.dart';
import '../../core/models/quotation.dart' as qmodels;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import './widgets/calculation_summary_widget.dart';
import './widgets/customer_details_widget.dart';
import './widgets/live_preview_widget.dart';
import './widgets/product_list_widget.dart';
import './widgets/product_selection_widget.dart';

class CreateQuotation extends StatefulWidget {
  const CreateQuotation({super.key});

  @override
  State<CreateQuotation> createState() => _CreateQuotationState();
}

class _CreateQuotationState extends State<CreateQuotation> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _glassColorController = TextEditingController();
  // New controllers for additional product metadata
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _systemController = TextEditingController();
  final TextEditingController _profileColorController = TextEditingController();
  final TextEditingController _meshTypeController = TextEditingController();
  final TextEditingController _lockingController = TextEditingController();
  final TextEditingController _handleColorController = TextEditingController();
  final TextEditingController _itemRemarksController = TextEditingController();
  // Grill and PVC controls
  bool _hasGrill = false;
  String _grillOrientation = 'horizontal';
  final TextEditingController _grillPipeController = TextEditingController();
  final TextEditingController _pvcCountController =
      TextEditingController(text: '1');

  // Form state
  String? _selectedTopCategory;
  Map<String, dynamic>? _selectedProduct;
  String _selectedUnit = 'mm';
  String _selectedMeasurement = 'sqft'; // 'sqft' or 'runningft'
  bool _hasMosquitoNet = false;
  // GST and discount controls
  bool _gstEnabled = false;
  final TextEditingController _gstRateController =
      TextEditingController(text: '18');
  final TextEditingController _discountPercentController =
      TextEditingController(text: '0');
  final TextEditingController _discountAmountController =
      TextEditingController(text: '0');
  List<Map<String, dynamic>> _addedProducts = [];
  int? _editingIndex;
  final GlobalKey _previewKey = GlobalKey();

  // Validation errors
  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _productError;
  String? _dimensionError;
  String? _rateError;

  // Mock data
  final List<String> _topCategories = [
    'Window',
    'Door',
    'Partitions',
    'Railing',
    'Bathroom Items',
    'Kitchen Items',
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    // Main Category
    {
      "id": 101,
      "name": "Dumal",
      "category": "Main",
      "rate": 0.0,
      "description": "Main category: Dumal",
      "subtypes": [
        {"name": "2 track", "rate": 0.0},
        {"name": "3 track", "rate": 0.0},
        {"name": "2 shutter glass with 1 shutter net", "rate": 0.0},
        {"name": "2 with sliding net", "rate": 0.0},
        {"name": "2 with grill", "rate": 0.0},
      ],
    },
    {
      "id": 102,
      "name": "Z openable",
      "category": "Main",
      "rate": 0.0,
      "description": "Main category: Z openable",
      "subtypes": [
        {"name": "2 in 1", "rate": 0.0},
        {"name": "3 in 1", "rate": 0.0},
      ],
    },
    {
      "id": 103,
      "name": "Z Hydrolic",
      "category": "Main",
      "rate": 0.0,
      "description": "Main category: Z Hydrolic",
      "forceSinglePane": true,
      "subtypes": [],
    },
    // Sub Category
    {
      "id": 201,
      "name": "2 track",
      "category": "Sub",
      "parent": "Dumal",
      "rate": 0.0,
      "description": "Dumal - 2 track",
    },
    {
      "id": 202,
      "name": "3 track",
      "category": "Sub",
      "parent": "Dumal",
      "rate": 0.0,
      "description": "Dumal - 3 track",
    },
    {
      "id": 203,
      "name": "2 shutter glass with 1 shutter net",
      "category": "Sub",
      "parent": "Dumal",
      "rate": 0.0,
      "description": "Dumal - 2 shutter glass with 1 shutter net",
    },
    {
      "id": 204,
      "name": "2 with sliding net",
      "category": "Sub",
      "parent": "Dumal",
      "rate": 0.0,
      "description": "Dumal - 2 with sliding net",
    },
    {
      "id": 205,
      "name": "2 with grill",
      "category": "Sub",
      "parent": "Dumal",
      "rate": 0.0,
      "description": "Dumal - 2 with grill",
    },
    {
      "id": 206,
      "name": "2 in 1",
      "category": "Sub",
      "parent": "Z openable",
      "rate": 0.0,
      "description": "Z openable - 2 in 1",
    },
    {
      "id": 207,
      "name": "3 in 1",
      "category": "Sub",
      "parent": "Z openable",
      "rate": 0.0,
      "description": "Z openable - 3 in 1",
    },
    // Existing products (for reference)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Quotation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _clearForm();
            },
            child: Text(
              'Clear',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 768;

          if (isTablet) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomerDetailsWidget(
            nameController: _nameController,
            phoneController: _phoneController,
            addressController: _addressController,
            nameError: _nameError,
            phoneError: _phoneError,
            addressError: _addressError,
          ),

          ProductSelectionWidget(
            topCategories: _topCategories,
            selectedTopCategory: _selectedTopCategory,
            onTopCategoryChanged: (category) {
              setState(() {
                _selectedTopCategory = category;
              });
            },
            products: _mockProducts,
            selectedProduct: _selectedProduct,
            onProductSelected: _onProductSelected,
            hasMosquitoNet: _hasMosquitoNet,
            onMosquitoNetChanged: (val) {
              setState(() {
                _hasMosquitoNet = val;
              });
            },
            glassColorController: _glassColorController,
            unitPriceController: _unitPriceController,
            positionController: _positionController,
            locationController: _locationController,
            systemController: _systemController,
            profileColorController: _profileColorController,
            meshTypeController: _meshTypeController,
            lockingController: _lockingController,
            handleColorController: _handleColorController,
            itemRemarksController: _itemRemarksController,
            hasGrill: _hasGrill,
            onHasGrillChanged: (v) => setState(() => _hasGrill = v),
            grillOrientation: _grillOrientation,
            onGrillOrientationChanged: (s) =>
                setState(() => _grillOrientation = s),
            grillPipeController: _grillPipeController,
            pvcCountController: _pvcCountController,
            widthController: _widthController,
            heightController: _heightController,
            rateController: _rateController,
            selectedUnit: _selectedUnit,
            onUnitChanged: _onUnitChanged,
            selectedMeasurement: _selectedMeasurement,
            onMeasurementChanged: (m) {
              setState(() {
                _selectedMeasurement = m;
              });
            },
            productError: _productError,
            dimensionError: _dimensionError,
            rateError: _rateError,
          ),

          RepaintBoundary(
            key: _previewKey,
            child: LivePreviewWidget(
              selectedProduct: _selectedProduct,
              width: double.tryParse(_widthController.text) ?? 0.0,
              height: double.tryParse(_heightController.text) ?? 0.0,
              unit: _selectedUnit,
              hasMosquitoNet: _hasMosquitoNet,
              hasGrill: _hasGrill,
              grillOrientation: _grillOrientation,
              grillPipeCount: int.tryParse(_grillPipeController.text) ?? 0,
              pvcWindowCount: int.tryParse(_pvcCountController.text) ?? 1,
            ),
          ),

          if (_selectedProduct != null &&
              _widthController.text.isNotEmpty &&
              _heightController.text.isNotEmpty &&
              _rateController.text.isNotEmpty)
            _buildAddProductButton(),

          ProductListWidget(
            products: _addedProducts,
            onRemoveProduct: _onRemoveProduct,
            onEditProduct: _onEditProduct,
          ),

          // GST and Discount controls
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _gstEnabled,
                          onChanged: (v) =>
                              setState(() => _gstEnabled = v ?? false),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text('Enable GST',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          width: 28.w,
                          child: TextField(
                            controller: _gstRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(suffixText: '%'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _discountPercentController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Discount (%)'),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: TextField(
                            controller: _discountAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Discount Amount'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          CalculationSummaryWidget(
            products: _addedProducts,
            gstRate: double.tryParse(_gstRateController.text) ?? 18.0,
            gstEnabled: _gstEnabled,
            discountPercent:
                double.tryParse(_discountPercentController.text) ?? 0.0,
            discountAmount:
                double.tryParse(_discountAmountController.text) ?? 0.0,
          ),

          SizedBox(height: 10.h), // Space for bottom action bar
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side - Form
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(right: 2.w),
            child: Column(
              children: [
                CustomerDetailsWidget(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                  nameError: _nameError,
                  phoneError: _phoneError,
                  addressError: _addressError,
                ),
                ProductSelectionWidget(
                  topCategories: _topCategories,
                  selectedTopCategory: _selectedTopCategory,
                  onTopCategoryChanged: (category) {
                    setState(() {
                      _selectedTopCategory = category;
                    });
                  },
                  products: _mockProducts,
                  selectedProduct: _selectedProduct,
                  onProductSelected: _onProductSelected,
                  hasMosquitoNet: _hasMosquitoNet,
                  onMosquitoNetChanged: (val) {
                    setState(() {
                      _hasMosquitoNet = val;
                    });
                  },
                  glassColorController: _glassColorController,
                  unitPriceController: _unitPriceController,
                  hasGrill: _hasGrill,
                  onHasGrillChanged: (v) => setState(() => _hasGrill = v),
                  grillOrientation: _grillOrientation,
                  onGrillOrientationChanged: (s) =>
                      setState(() => _grillOrientation = s),
                  grillPipeController: _grillPipeController,
                  pvcCountController: _pvcCountController,
                  positionController: _positionController,
                  locationController: _locationController,
                  systemController: _systemController,
                  profileColorController: _profileColorController,
                  meshTypeController: _meshTypeController,
                  lockingController: _lockingController,
                  handleColorController: _handleColorController,
                  itemRemarksController: _itemRemarksController,
                  widthController: _widthController,
                  heightController: _heightController,
                  rateController: _rateController,
                  selectedUnit: _selectedUnit,
                  onUnitChanged: _onUnitChanged,
                  selectedMeasurement: _selectedMeasurement,
                  onMeasurementChanged: (m) {
                    setState(() {
                      _selectedMeasurement = m;
                    });
                  },
                  productError: _productError,
                  dimensionError: _dimensionError,
                  rateError: _rateError,
                ),
                if (_selectedProduct != null &&
                    _widthController.text.isNotEmpty &&
                    _heightController.text.isNotEmpty &&
                    _rateController.text.isNotEmpty)
                  _buildAddProductButton(),
                ProductListWidget(
                  products: _addedProducts,
                  onRemoveProduct: _onRemoveProduct,
                  onEditProduct: _onEditProduct,
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),

        // Right side - Preview and Summary
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 2.w),
            child: Column(
              children: [
                // Ensure the visible preview on wider screens is wrapped by the
                // same RepaintBoundary keyed by _previewKey so capture works
                // consistently across mobile and desktop layouts.
                RepaintBoundary(
                  key: _previewKey,
                  child: LivePreviewWidget(
                    selectedProduct: _selectedProduct,
                    width: double.tryParse(_widthController.text) ?? 0.0,
                    height: double.tryParse(_heightController.text) ?? 0.0,
                    unit: _selectedUnit,
                    hasMosquitoNet: _hasMosquitoNet,
                    hasGrill: _hasGrill,
                    grillOrientation: _grillOrientation,
                    grillPipeCount:
                        int.tryParse(_grillPipeController.text) ?? 0,
                    pvcWindowCount: int.tryParse(_pvcCountController.text) ?? 1,
                  ),
                ),
                // GST and Discount controls (tablet right column)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _gstEnabled,
                                onChanged: (v) =>
                                    setState(() => _gstEnabled = v ?? false),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text('Enable GST',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(
                                width: 24.w,
                                child: TextField(
                                  controller: _gstRateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration:
                                      const InputDecoration(suffixText: '%'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _discountPercentController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: 'Discount (%)'),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: TextField(
                                  controller: _discountAmountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: 'Discount Amount'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                CalculationSummaryWidget(
                  products: _addedProducts,
                  gstRate: double.tryParse(_gstRateController.text) ?? 18.0,
                  gstEnabled: _gstEnabled,
                  discountPercent:
                      double.tryParse(_discountPercentController.text) ?? 0.0,
                  discountAmount:
                      double.tryParse(_discountAmountController.text) ?? 0.0,
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddProductButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addProduct,
        icon: CustomIconWidget(
          iconName: _editingIndex != null ? 'update' : 'add',
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          _editingIndex != null ? 'Update Product' : 'Add Product',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSaveAsDraftDialog();
                },
                child: Text(
                  'Save as Draft',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),

            // Download PDF button
            Expanded(
              child: OutlinedButton(
                onPressed: _addedProducts.isNotEmpty
                    ? () async {
                        if (!_validateCustomerForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Please fill in all customer details'),
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        // Generate a temporary quotation id using customer's phone if available
                        final rawPhone = _phoneController.text.trim();
                        final phoneDigits =
                            rawPhone.replaceAll(RegExp(r'\D+'), '');
                        final qId = phoneDigits.isNotEmpty
                            ? 'QT-$phoneDigits'
                            : 'QT-${DateTime.now().millisecondsSinceEpoch}';

                        // Build Quotation model
                        double subtotal = 0.0;
                        for (final product in _addedProducts) {
                          final rate = (product['rate'] as num).toDouble();
                          final unitPrice =
                              (product['unitPrice'] as num).toDouble();
                          final qty = (product['quantity'] is int)
                              ? (product['quantity'] as int)
                              : 1;
                          final value = rate * unitPrice * qty;
                          subtotal += value;
                        }
                        final gstRate = _gstEnabled
                            ? (double.tryParse(_gstRateController.text) ?? 0)
                            : 0.0;
                        final gstAmount =
                            _gstEnabled ? subtotal * (gstRate / 100) : 0.0;
                        // discount: prefer explicit amount if > 0 else percent
                        final discountPercent =
                            double.tryParse(_discountPercentController.text) ??
                                0.0;
                        final discountAmountInput =
                            double.tryParse(_discountAmountController.text) ??
                                0.0;
                        final discountAmount = discountAmountInput > 0
                            ? discountAmountInput
                            : subtotal * (discountPercent / 100);
                        final total = subtotal + gstAmount - discountAmount;

                        final quotation = qmodels.Quotation(
                          id: qId,
                          customerName: _nameController.text.trim(),
                          customerPhone: _phoneController.text.trim(),
                          customerAddress: _addressController.text.trim(),
                          gstEnabled: _gstEnabled,
                          gstRate: _gstEnabled
                              ? (double.tryParse(_gstRateController.text) ?? 0)
                              : 0,
                          discountPercent: double.tryParse(
                                  _discountPercentController.text) ??
                              0,
                          discountAmount:
                              double.tryParse(_discountAmountController.text) ??
                                  0,
                          quotationDate: DateTime.now(),
                          totalAmount: total,
                          status: 'Draft',
                          items: _addedProducts.map((product) {
                            return qmodels.QuotationItem(
                              itemName: product['name']?.toString() ?? '',
                              category: product['category']?.toString() ?? '',
                              size:
                                  '${product['width']?.toString() ?? ''} ${product['unit'] ?? ''} x ${product['height']?.toString() ?? ''} ${product['unit'] ?? ''}',
                              rate: (product['rate'] is num)
                                  ? (product['rate'] as num).toDouble()
                                  : double.tryParse(
                                          product['rate']?.toString() ?? '0') ??
                                      0.0,
                              unitPrice: (product['unitPrice'] is num)
                                  ? (product['unitPrice'] as num).toDouble()
                                  : double.tryParse(
                                          product['unitPrice']?.toString() ??
                                              '0') ??
                                      0.0,
                              subtype: (product['subtype'] ??
                                      product['selectedSubtype'])
                                  ?.toString(),
                              area: product['area'] is num
                                  ? (product['area'] as num).toDouble()
                                  : (double.tryParse(
                                          product['area']?.toString() ?? '') ??
                                      null),
                              quantity: (product['quantity'] is int)
                                  ? (product['quantity'] as int)
                                  : 1,
                              glassColor:
                                  product['glassColor']?.toString() ?? '',
                              hasMosquitoNet: product['hasMosquitoNet'] == true,
                              hasGrill: product['hasGrill'] == true,
                              grillOrientation:
                                  product['grillOrientation']?.toString() ??
                                      'horizontal',
                              grillPipeCount: product['grillPipeCount'] is int
                                  ? product['grillPipeCount'] as int
                                  : (product['grillPipeCount'] != null
                                      ? int.tryParse(
                                          product['grillPipeCount'].toString())
                                      : null),
                              pvcWindowCount: product['pvcWindowCount'] is int
                                  ? product['pvcWindowCount'] as int
                                  : (product['pvcWindowCount'] != null
                                      ? int.tryParse(
                                          product['pvcWindowCount'].toString())
                                      : null),
                              position: product['position'] is int
                                  ? product['position'] as int
                                  : (product['position'] != null
                                      ? int.tryParse(
                                          product['position'].toString())
                                      : null),
                              location: product['location']?.toString() ?? '',
                              system: product['system']?.toString() ?? '',
                              profileColor:
                                  product['profileColor']?.toString() ?? '',
                              meshType: product['meshType']?.toString() ?? '',
                              locking: product['locking']?.toString() ?? '',
                              handleColor:
                                  product['handleColor']?.toString() ?? '',
                              remarks: product['remarks']?.toString() ?? '',
                            );
                          }).toList(),
                        );

                        // quotation built above; continue to PDF generation

                        try {
                          final itemPreviews = await _capturePreviewsForItems();
                          final file = await PdfService().generateQuotationPdf(
                              quotation,
                              itemPreviews: itemPreviews);
                          final bytes = await file.readAsBytes();
                          await Printing.sharePdf(
                              bytes: bytes,
                              filename: 'quotation_${quotation.id}.pdf');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to generate PDF: $e')),
                          );
                        }
                      }
                    : null,
                child: Text(
                  'Download PDF',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            Expanded(
              child: ElevatedButton(
                onPressed: _addedProducts.isNotEmpty ? _saveQuotation : null,
                child: Text(
                  'Save Quotation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onProductSelected(Map<String, dynamic> product) {
    setState(() {
      _selectedProduct = product;
      _productError = null;
      // reset mosquito net selection when a new product is chosen
      _hasMosquitoNet = false;
    });
  }

  void _onUnitChanged(String unit) {
    setState(() {
      _selectedUnit = unit;
    });
  }

  // Capture the repaint boundary and crop to the interior preview area (pane only).
  Future<Uint8List?> _captureInteriorPreviewAsPng(
      {required Map<String, dynamic> product,
      required double productWidth,
      required double productHeight,
      required String unit,
      required bool hasMosquitoNet}) async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // Use devicePixelRatio to capture at correct resolution for the current display.
      final pixelRatio = ui.window.devicePixelRatio.clamp(1.0, 4.0);
      final ui.Image fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      // On desktop platforms the precise crop math can accidentally trim
      // visible edges (ticks, labels or outer frame). To ensure the PDF
      // contains the full visible preview, return the entire RepaintBoundary
      // capture as PNG and let the PDF layout scale it as needed.
      final byteData =
          await fullImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      // on any failure return null so PDF generator can fallback
      return null;
    }
  }

  // Capture a preview image for each added product by temporarily
  // updating the preview state and capturing the repaint boundary.
  Future<List<Uint8List?>> _capturePreviewsForItems() async {
    final previews = <Uint8List?>[];
    // save current state
    final prevSelected = _selectedProduct;
    final prevWidthText = _widthController.text;
    final prevHeightText = _heightController.text;
    final prevUnit = _selectedUnit;
    final prevHasNet = _hasMosquitoNet;
    final prevHasGrill = _hasGrill;
    final prevGrillOrientation = _grillOrientation;
    final prevGrillPipeText = _grillPipeController.text;
    final prevPvcCountText = _pvcCountController.text;

    for (int i = 0; i < _addedProducts.length; i++) {
      final product = _addedProducts[i];
      try {
        setState(() {
          _selectedProduct = product;
          _widthController.text = (product['width'] as double).toString();
          _heightController.text = (product['height'] as double).toString();
          _selectedUnit = product['unit'] as String;
          _hasMosquitoNet = product['hasMosquitoNet'] == true;
          _hasGrill = product['hasGrill'] == true;
          _grillOrientation =
              product['grillOrientation']?.toString() ?? 'horizontal';
          _grillPipeController.text =
              (product['grillPipeCount']?.toString() ?? '0');
          _pvcCountController.text =
              (product['pvcWindowCount']?.toString() ?? '1');
          // If the product is Dumal or Z openable, ensure pvc count is at least 2
          try {
            final name = (product['name'] ?? '').toString();
            if (name.toLowerCase() == 'dumal' ||
                name.toLowerCase() == 'z openable') {
              final cur = _pvcCountController.text.trim();
              if (cur.isEmpty || cur == '1') _pvcCountController.text = '2';
            }
          } catch (_) {}
        });

        // wait longer to ensure the widget finishes painting on slower platforms like Windows
        await Future.delayed(const Duration(milliseconds: 300));
        final bytes = await _captureInteriorPreviewAsPng(
          product: product,
          productWidth: (product['width'] as double),
          productHeight: (product['height'] as double),
          unit: product['unit'] as String,
          hasMosquitoNet: product['hasMosquitoNet'] == true,
        );

        // Diagnostic dump: when running on Windows or in debug mode, write the
        // captured PNG to the system temp directory so we can inspect whether
        // the capture produced a valid image on that platform.
        if (bytes != null) {
          try {
            if (kDebugMode || io.Platform.isWindows) {
              final ts = DateTime.now().millisecondsSinceEpoch;
              final tmp = io.Directory.systemTemp;
              final file = io.File(
                  '${tmp.path}${io.Platform.pathSeparator}preview_debug_${i}_$ts.png');
              await file.writeAsBytes(bytes);
              // ignore: avoid_print
              print('Wrote debug preview to: ${file.path}');
            }
          } catch (_) {}
        }

        previews.add(bytes);
      } catch (_) {
        previews.add(null);
      }
    }

    // restore previous state
    setState(() {
      _selectedProduct = prevSelected;
      _widthController.text = prevWidthText;
      _heightController.text = prevHeightText;
      _selectedUnit = prevUnit;
      _hasMosquitoNet = prevHasNet;
      _hasGrill = prevHasGrill;
      _grillOrientation = prevGrillOrientation;
      _grillPipeController.text = prevGrillPipeText;
      _pvcCountController.text = prevPvcCountText;
    });
    // allow a short delay for the UI to settle after restore
    await Future.delayed(const Duration(milliseconds: 150));
    return previews;
  }

  void _addProduct() {
    if (_validateProductForm()) {
      final width = double.tryParse(_widthController.text) ?? 0.0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final unit = _selectedUnit;
      double area = 0.0;
      switch (unit) {
        case 'mm':
          area = (width * height) / 92903.04;
          break;
        case 'inches':
          area = (width / 12) * (height / 12);
          break;
        case 'cm':
          area = (width / 30.48) * (height / 30.48);
          break;
        default:
          area = width * height;
      }
      final unitPrice = double.tryParse(_rateController.text) ?? 0.0;
      final value = unitPrice * area;
      final productData = {
        'id': _selectedProduct != null ? _selectedProduct!['id'] : null,
        'name': _selectedProduct != null ? _selectedProduct!['name'] : '',
        'topCategory': _selectedTopCategory,
        'category':
            _selectedProduct != null ? _selectedProduct!['category'] : '',
        'subtype': _selectedProduct != null &&
                _selectedProduct!.containsKey('selectedSubtype')
            ? _selectedProduct!['selectedSubtype']
            : null,
        'width': width,
        'height': height,
        'unit': unit,
        'measurementType': _selectedMeasurement,
        'rate': unitPrice,
        'unitPrice': unitPrice,
        'area': area,
        'value': value,
        'glassColor': _glassColorController.text.trim(),
        'hasMosquitoNet': _hasMosquitoNet,
        'position': int.tryParse(_positionController.text),
        'location': _locationController.text.trim(),
        'system': _systemController.text.trim(),
        'profileColor': _profileColorController.text.trim(),
        'meshType': _meshTypeController.text.trim(),
        'locking': _lockingController.text.trim(),
        'handleColor': _handleColorController.text.trim(),
        'remarks': _itemRemarksController.text.trim(),
        'hasGrill': _hasGrill,
        'grillOrientation': _grillOrientation,
        'grillPipeCount': int.tryParse(_grillPipeController.text) ?? 0,
        'pvcWindowCount': int.tryParse(_pvcCountController.text) ?? 1,
        'forceSinglePane': _selectedProduct != null &&
            (_selectedProduct!['forceSinglePane'] == true),
      };

      debugPrint('Adding product: ${productData.toString()}');
      setState(() {
        if (_editingIndex != null) {
          _addedProducts[_editingIndex!] = productData;
          _editingIndex = null;
        } else {
          _addedProducts.add(productData);
        }
        _clearProductForm();
      });

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingIndex != null
                ? 'Product updated successfully!'
                : 'Product added successfully!',
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    } else {
      debugPrint('Product form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not added: Please check all required fields.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _onRemoveProduct(int index) {
    setState(() {
      _addedProducts.removeAt(index);
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Product removed'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality if needed
          },
        ),
      ),
    );
  }

  void _onEditProduct(int index) {
    final product = _addedProducts[index];
    setState(() {
      _editingIndex = index;
      _selectedTopCategory = product['topCategory'] as String?;
      _selectedProduct = _mockProducts.firstWhere(
        (p) => p['id'] == product['id'],
        orElse: () => product,
      );
      _widthController.text = (product['width'] as double).toString();
      _heightController.text = (product['height'] as double).toString();
      _rateController.text = (product['rate'] as double).toString();
      _selectedUnit = product['unit'] as String;
      _glassColorController.text = (product['glassColor'] ?? '') as String;
      _positionController.text = (product['position']?.toString() ?? '');
      _locationController.text = (product['location']?.toString() ?? '');
      _systemController.text = (product['system']?.toString() ?? '');
      _profileColorController.text =
          (product['profileColor']?.toString() ?? '');
      _meshTypeController.text = (product['meshType']?.toString() ?? '');
      _lockingController.text = (product['locking']?.toString() ?? '');
      _handleColorController.text = (product['handleColor']?.toString() ?? '');
      _itemRemarksController.text = (product['remarks']?.toString() ?? '');
      _selectedMeasurement = product['measurementType']?.toString() ?? 'sqft';
      _hasMosquitoNet = product['hasMosquitoNet'] == true;
      _unitPriceController.text = (product['unitPrice']?.toString() ?? '0');
      _hasGrill = product['hasGrill'] == true;
      _grillOrientation =
          product['grillOrientation']?.toString() ?? 'horizontal';
      _grillPipeController.text =
          (product['grillPipeCount']?.toString() ?? '0');
      _pvcCountController.text = (product['pvcWindowCount']?.toString() ?? '1');
      // If the product is Dumal or Z openable, ensure pvc count is at least 2
      try {
        final name = (product['name'] ?? '').toString();
        if (name.toLowerCase() == 'dumal' ||
            name.toLowerCase() == 'z openable') {
          final cur = _pvcCountController.text.trim();
          if (cur.isEmpty || cur == '1') _pvcCountController.text = '2';
        }
      } catch (_) {}
    });

    // Scroll to product selection
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _validateProductForm() {
    // Check if top category is selected
    if (_selectedTopCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return false;
    }
    // No other required field validation, always return true
    return true;
  }

  bool _validateCustomerForm() {
    bool isValid = true;

    setState(() {
      _nameError = null;
      _phoneError = null;
      _addressError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Customer name is required';
      });
      isValid = false;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (_phoneController.text.trim().length < 10) {
      setState(() {
        _phoneError = 'Please enter valid phone number';
      });
      isValid = false;
    }

    if (_addressController.text.trim().isEmpty) {
      setState(() {
        _addressError = 'Address is required';
      });
      isValid = false;
    }

    return isValid;
  }

  void _clearProductForm() {
    _widthController.clear();
    _heightController.clear();
    _rateController.clear();
    _glassColorController.clear();
    _positionController.clear();
    _locationController.clear();
    _systemController.clear();
    _profileColorController.clear();
    _meshTypeController.clear();
    _lockingController.clear();
    _handleColorController.clear();
    _itemRemarksController.clear();
    setState(() {
      _selectedTopCategory = null;
      _selectedProduct = null;
      _selectedUnit = 'feet';
      _productError = null;
      _dimensionError = null;
      _rateError = null;
      _selectedMeasurement = 'sqft';
      _hasMosquitoNet = false;
      _unitPriceController.clear();
    });
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _clearProductForm();
    setState(() {
      _addedProducts.clear();
      _editingIndex = null;
      _nameError = null;
      _phoneError = null;
      _addressError = null;
    });
  }

  void _showSaveAsDraftDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Save as Draft',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: const Text(
          'This quotation will be saved as draft and can be completed later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveDraft();
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    // Generate draft ID
    final draftId = 'DRAFT-${DateTime.now().millisecondsSinceEpoch}';

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved with ID: $draftId'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _saveQuotation() {
    if (!_validateCustomerForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all customer details'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    if (_addedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one product'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Generate quotation ID using customer's phone if available
    final rawPhone = _phoneController.text.trim();
    final phoneDigits = rawPhone.replaceAll(RegExp(r'\D+'), '');
    final quotationId = phoneDigits.isNotEmpty
        ? 'QT-$phoneDigits'
        : 'QT-${DateTime.now().millisecondsSinceEpoch}';

    // Calculate totals
    double subtotal = 0.0;
    for (final product in _addedProducts) {
      final rate = (product['rate'] as num).toDouble();
      final unitPrice = (product['unitPrice'] as num).toDouble();
      final qty =
          (product['quantity'] is int) ? (product['quantity'] as int) : 1;
      subtotal += rate * unitPrice * qty;
    }
    final gstAmount = subtotal * 0.18;
    final total = subtotal + gstAmount;

    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Quotation Saved',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quotation ID: $quotationId'),
            SizedBox(height: 1.h),
            Text('Customer: ${_nameController.text}'),
            SizedBox(height: 1.h),
            Text('Total Amount: ₹${total.toStringAsFixed(2)}'),
            SizedBox(height: 1.h),
            Text('Products: ${_addedProducts.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Build Quotation model from current form data
              final quotation = qmodels.Quotation(
                id: quotationId,
                customerName: _nameController.text.trim(),
                customerPhone: _phoneController.text.trim(),
                customerAddress: _addressController.text.trim(),
                quotationDate: DateTime.now(),
                totalAmount: total,
                status: 'Draft',
                items: _addedProducts.map((product) {
                  return qmodels.QuotationItem(
                    itemName: product['name']?.toString() ?? '',
                    category: product['category']?.toString() ?? '',
                    size:
                        '${product['width']?.toString() ?? ''} ${product['unit'] ?? ''} x ${product['height']?.toString() ?? ''} ${product['unit'] ?? ''}',
                    width: (product['width'] is num)
                        ? (product['width'] as num).toDouble()
                        : double.tryParse(product['width']?.toString() ?? ''),
                    height: (product['height'] is num)
                        ? (product['height'] as num).toDouble()
                        : double.tryParse(product['height']?.toString() ?? ''),
                    unit: product['unit']?.toString() ?? 'feet',
                    measurementType:
                        product['measurementType']?.toString() ?? 'sqft',
                    rate: (product['rate'] is num)
                        ? (product['rate'] as num).toDouble()
                        : double.tryParse(product['rate']?.toString() ?? '0') ??
                            0.0,
                    quantity: (product['quantity'] is int)
                        ? (product['quantity'] as int)
                        : 1,
                    glassColor: product['glassColor']?.toString() ?? '',
                    hasMosquitoNet: product['hasMosquitoNet'] == true,
                    position: product['position'] is int
                        ? product['position'] as int
                        : (product['position'] != null
                            ? int.tryParse(product['position'].toString())
                            : null),
                    location: product['location']?.toString() ?? '',
                    system: product['system']?.toString() ?? '',
                    profileColor: product['profileColor']?.toString() ?? '',
                    meshType: product['meshType']?.toString() ?? '',
                    locking: product['locking']?.toString() ?? '',
                    handleColor: product['handleColor']?.toString() ?? '',
                    remarks: product['remarks']?.toString() ?? '',
                    unitPrice: (product['unitPrice'] is num)
                        ? (product['unitPrice'] as num).toDouble()
                        : double.tryParse(
                                product['unitPrice']?.toString() ?? '0') ??
                            0.0,
                    subtype: (product['subtype'] ?? product['selectedSubtype'])
                        ?.toString(),
                    area: product['area'] is num
                        ? (product['area'] as num).toDouble()
                        : (double.tryParse(product['area']?.toString() ?? '') ??
                            null),
                  );
                }).toList(),
              );

              // Show progress
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generating PDF...')),
              );

              try {
                final itemPreviews = await _capturePreviewsForItems();
                final file = await PdfService().generateQuotationPdf(quotation,
                    itemPreviews: itemPreviews);
                final bytes = await file.readAsBytes();
                await Printing.sharePdf(
                    bytes: bytes, filename: 'quotation_${quotation.id}.pdf');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to generate PDF: $e')),
                );
              }

              _clearForm();
            },
            child: const Text('Generate PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/quotation-list');
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  // area calculation moved to preview and other widgets where needed

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _rateController.dispose();
    _unitPriceController.dispose();
    _glassColorController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _systemController.dispose();
    _profileColorController.dispose();
    _meshTypeController.dispose();
    _lockingController.dispose();
    _handleColorController.dispose();
    _itemRemarksController.dispose();
    super.dispose();
  }
}
