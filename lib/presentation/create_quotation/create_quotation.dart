import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/pdf_service.dart';
import '../../core/models/quotation.dart' as qmodels;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
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
  final TextEditingController _glassColorController = TextEditingController();

  // Form state
  Map<String, dynamic>? _selectedProduct;
  String _selectedUnit = 'feet';
  bool _hasMosquitoNet = false;
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
  final List<Map<String, dynamic>> _mockProducts = [
    {
      "id": 1,
      "name": "Aluminium Sliding Door",
      "category": "Aluminium",
      "rate": 45.50,
      "description":
          "Premium quality aluminium sliding door with smooth operation",
      "image":
          "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 2,
      "name": "PVC Sliding Window",
      "category": "PVC",
      "rate": 32.75,
      "description": "Energy efficient PVC sliding window with double glazing",
      "image":
          "https://images.pexels.com/photos/1571463/pexels-photo-1571463.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 3,
      "name": "Wooden Main Door",
      "category": "Wooden",
      "rate": 65.00,
      "description": "Solid wood main door with traditional design",
      "image":
          "https://images.pexels.com/photos/1571468/pexels-photo-1571468.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 4,
      "name": "Glass Partition",
      "category": "Glass",
      "rate": 28.90,
      "description": "Tempered glass partition for modern office spaces",
      "image":
          "https://images.pexels.com/photos/1571471/pexels-photo-1571471.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 5,
      "name": "PVC Kitchen Cupboard",
      "category": "PVC",
      "rate": 38.25,
      "description": "Waterproof PVC kitchen cupboard with modern finish",
      "image":
          "https://images.pexels.com/photos/1571475/pexels-photo-1571475.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 6,
      "name": "Aluminium Window Frame",
      "category": "Aluminium",
      "rate": 42.80,
      "description": "Durable aluminium window frame with powder coating",
      "image":
          "https://images.pexels.com/photos/1571478/pexels-photo-1571478.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 7,
      "name": "Wooden Wardrobe Door",
      "category": "Wooden",
      "rate": 55.60,
      "description": "Premium wooden wardrobe door with mirror finish",
      "image":
          "https://images.pexels.com/photos/1571481/pexels-photo-1571481.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 8,
      "name": "Glass Shower Door",
      "category": "Glass",
      "rate": 48.75,
      "description": "Tempered glass shower door with chrome handles",
      "image":
          "https://images.pexels.com/photos/1571484/pexels-photo-1571484.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
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
            widthController: _widthController,
            heightController: _heightController,
            rateController: _rateController,
            selectedUnit: _selectedUnit,
            onUnitChanged: _onUnitChanged,
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

          CalculationSummaryWidget(
            products: _addedProducts,
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
                  widthController: _widthController,
                  heightController: _heightController,
                  rateController: _rateController,
                  selectedUnit: _selectedUnit,
                  onUnitChanged: _onUnitChanged,
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
                LivePreviewWidget(
                  selectedProduct: _selectedProduct,
                  width: double.tryParse(_widthController.text) ?? 0.0,
                  height: double.tryParse(_heightController.text) ?? 0.0,
                  unit: _selectedUnit,
                  hasMosquitoNet: _hasMosquitoNet,
                ),
                CalculationSummaryWidget(
                  products: _addedProducts,
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

                        // Generate a temporary quotation id
                        final qId =
                            'QUO-${DateTime.now().millisecondsSinceEpoch}';

                        // Build Quotation model
                        double subtotal = 0.0;
                        for (final product in _addedProducts) {
                          final area = _calculateArea(
                            product['width'] as double,
                            product['height'] as double,
                            product['unit'] as String,
                          );
                          subtotal += area * (product['rate'] as double);
                        }
                        final gstAmount = subtotal * 0.18;
                        final total = subtotal + gstAmount;

                        final quotation = qmodels.Quotation(
                          id: qId,
                          customerName: _nameController.text.trim(),
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
                              quantity: (product['quantity'] is int)
                                  ? (product['quantity'] as int)
                                  : 1,
                              glassColor:
                                  product['glassColor']?.toString() ?? '',
                              hasMosquitoNet: product['hasMosquitoNet'] == true,
                            );
                          }).toList(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Generating PDF...')),
                        );

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
      const double pixelRatio = 3.0;
      final ui.Image fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      // compute interior rect using same logic as ProductPreviewPainter
      final fullW = fullImage.width.toDouble();
      final fullH = fullImage.height.toDouble();
      final centerX = fullW / 2;
      final centerY = fullH / 2;
      final maxWidth = fullW * 0.7;
      final maxHeight = fullH * 0.7;

      final aspectRatio = (productWidth > 0 && productHeight > 0)
          ? (productWidth / productHeight)
          : 1.0;
      double drawW, drawH;
      if (aspectRatio > 1) {
        drawW = maxWidth;
        drawH = maxWidth / aspectRatio;
      } else {
        drawH = maxHeight;
        drawW = maxHeight * aspectRatio;
      }

      final srcRect = Rect.fromCenter(
          center: Offset(centerX, centerY), width: drawW, height: drawH);

      // clamp to image bounds
      final clamped = Rect.fromLTRB(
        srcRect.left.clamp(0.0, fullW),
        srcRect.top.clamp(0.0, fullH),
        srcRect.right.clamp(0.0, fullW),
        srcRect.bottom.clamp(0.0, fullH),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final dstW = (clamped.width).toInt();
      final dstH = (clamped.height).toInt();
      if (dstW <= 0 || dstH <= 0) {
        // fallback: return full image bytes
        final byteData =
            await fullImage.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }

      // draw the cropped region into a new canvas
      final dstRect = Rect.fromLTWH(0, 0, clamped.width, clamped.height);
      final paint = Paint();
      canvas.drawImageRect(fullImage, clamped, dstRect, paint);
      final picture = recorder.endRecording();
      final ui.Image cropped = await picture.toImage(dstW, dstH);
      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
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

    for (final product in _addedProducts) {
      try {
        setState(() {
          _selectedProduct = product;
          _widthController.text = (product['width'] as double).toString();
          _heightController.text = (product['height'] as double).toString();
          _selectedUnit = product['unit'] as String;
          _hasMosquitoNet = product['hasMosquitoNet'] == true;
        });

        // wait a frame for the widget to rebuild and paint
        await Future.delayed(const Duration(milliseconds: 150));
        final bytes = await _captureInteriorPreviewAsPng(
          product: product,
          productWidth: (product['width'] as double),
          productHeight: (product['height'] as double),
          unit: product['unit'] as String,
          hasMosquitoNet: product['hasMosquitoNet'] == true,
        );
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
    });
    await Future.delayed(const Duration(milliseconds: 100));
    return previews;
  }

  void _addProduct() {
    if (_validateProductForm()) {
      final productData = {
        'id': _selectedProduct!['id'],
        'name': _selectedProduct!['name'],
        'category': _selectedProduct!['category'],
        'width': double.parse(_widthController.text),
        'height': double.parse(_heightController.text),
        'unit': _selectedUnit,
        'rate': double.parse(_rateController.text),
        'glassColor': _glassColorController.text.trim(),
        'hasMosquitoNet': _hasMosquitoNet,
      };

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
      _selectedProduct = _mockProducts.firstWhere(
        (p) => p['id'] == product['id'],
        orElse: () => product,
      );
      _widthController.text = (product['width'] as double).toString();
      _heightController.text = (product['height'] as double).toString();
      _rateController.text = (product['rate'] as double).toString();
      _selectedUnit = product['unit'] as String;
      _glassColorController.text = (product['glassColor'] ?? '') as String;
    });

    // Scroll to product selection
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _validateProductForm() {
    bool isValid = true;

    setState(() {
      _productError = null;
      _dimensionError = null;
      _rateError = null;
    });

    if (_selectedProduct == null) {
      setState(() {
        _productError = 'Please select a product';
      });
      isValid = false;
    }

    if (_widthController.text.isEmpty || _heightController.text.isEmpty) {
      setState(() {
        _dimensionError = 'Please enter both width and height';
      });
      isValid = false;
    } else {
      final width = double.tryParse(_widthController.text);
      final height = double.tryParse(_heightController.text);
      if (width == null || height == null || width <= 0 || height <= 0) {
        setState(() {
          _dimensionError = 'Please enter valid dimensions';
        });
        isValid = false;
      }
    }

    if (_rateController.text.isEmpty) {
      setState(() {
        _rateError = 'Please enter rate';
      });
      isValid = false;
    } else {
      final rate = double.tryParse(_rateController.text);
      if (rate == null || rate <= 0) {
        setState(() {
          _rateError = 'Please enter valid rate';
        });
        isValid = false;
      }
    }

    return isValid;
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
    setState(() {
      _selectedProduct = null;
      _selectedUnit = 'feet';
      _productError = null;
      _dimensionError = null;
      _rateError = null;
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

    // Generate quotation ID
    final quotationId = 'QUO-${DateTime.now().millisecondsSinceEpoch}';

    // Calculate totals
    double subtotal = 0.0;
    for (final product in _addedProducts) {
      final area = _calculateArea(
        product['width'] as double,
        product['height'] as double,
        product['unit'] as String,
      );
      subtotal += area * (product['rate'] as double);
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
            Text('Total Amount: \$${total.toStringAsFixed(2)}'),
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
                        : double.tryParse(product['rate']?.toString() ?? '0') ??
                            0.0,
                    quantity: (product['quantity'] is int)
                        ? (product['quantity'] as int)
                        : 1,
                    glassColor: product['glassColor']?.toString() ?? '',
                    hasMosquitoNet: product['hasMosquitoNet'] == true,
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _rateController.dispose();
    _glassColorController.dispose();
    super.dispose();
  }
}
