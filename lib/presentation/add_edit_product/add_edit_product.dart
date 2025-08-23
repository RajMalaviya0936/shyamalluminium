import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_dropdown_field.dart';
import './widgets/description_field.dart';
import './widgets/image_section.dart';
import './widgets/product_form_section.dart';
import './widgets/product_name_field.dart';
import './widgets/rate_input_field.dart';

class AddEditProduct extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const AddEditProduct({
    super.key,
    this.productData,
  });

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Form validation errors
  String? _productNameError;
  String? _categoryError;
  String? _rateError;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.productData != null) {
      final data = widget.productData!;
      _productNameController.text = data['name'] ?? '';
      _selectedCategory = data['category'];
      _rateController.text = data['rate']?.toString() ?? '';
      _descriptionController.text = data['description'] ?? '';

      // Initialize images if available
      if (data['images'] != null && (data['images'] as List).isNotEmpty) {
        _selectedImages = (data['images'] as List)
            .map((imagePath) => XFile(imagePath as String))
            .toList();
      }
    }
  }

  void _setupChangeListeners() {
    _productNameController.addListener(_onFormChanged);
    _rateController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
    _clearFieldErrors();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _hasUnsavedChanges = true;
      _categoryError = null;
    });
  }

  void _onImagesChanged(List<XFile> images) {
    setState(() {
      _selectedImages = images;
      _hasUnsavedChanges = true;
    });
  }

  void _clearFieldErrors() {
    if (_productNameError != null ||
        _categoryError != null ||
        _rateError != null) {
      setState(() {
        _productNameError = null;
        _categoryError = null;
        _rateError = null;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate product name
    if (_productNameController.text.trim().isEmpty) {
      setState(() {
        _productNameError = 'Product name is required';
      });
      isValid = false;
    } else if (_productNameController.text.trim().length < 2) {
      setState(() {
        _productNameError = 'Product name must be at least 2 characters';
      });
      isValid = false;
    }

    // Validate category
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      setState(() {
        _categoryError = 'Please select a category';
      });
      isValid = false;
    }

    // Validate rate
    if (_rateController.text.trim().isEmpty) {
      setState(() {
        _rateError = 'Rate is required';
      });
      isValid = false;
    } else {
      final rate = double.tryParse(_rateController.text.trim());
      if (rate == null || rate <= 0) {
        setState(() {
          _rateError = 'Please enter a valid rate';
        });
        isValid = false;
      } else if (rate > 999999.99) {
        setState(() {
          _rateError = 'Rate cannot exceed \$999,999.99';
        });
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _saveProduct() async {
    if (!_validateForm()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate database save operation
      await Future.delayed(const Duration(milliseconds: 1500));

      final productData = {
        'id':
            widget.productData?['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'name': _productNameController.text.trim(),
        'category': _selectedCategory,
        'rate': double.parse(_rateController.text.trim()),
        'description': _descriptionController.text.trim(),
        'images': _selectedImages.map((image) => image.path).toList(),
        'createdAt': widget.productData?['createdAt'] ??
            DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Show success feedback
      HapticFeedback.lightImpact();

      final isEditing = widget.productData != null;
      final message = isEditing
          ? 'Product updated successfully!'
          : 'Product created successfully!';

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: AppTheme.lightTheme.colorScheme.onTertiary,
        fontSize: 14.sp,
      );

      // Return to previous screen with result
      if (mounted) {
        Navigator.pop(context, productData);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();

      Fluttertoast.showToast(
        msg: 'Failed to save product. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
        fontSize: 14.sp,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _saveDraft() {
    // Simulate draft saving
    HapticFeedback.lightImpact();

    Fluttertoast.showToast(
      msg: 'Draft saved',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: AppTheme.lightTheme.colorScheme.onSecondary,
      fontSize: 12.sp,
    );

    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  bool get _canSave {
    return _productNameController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _rateController.text.trim().isNotEmpty &&
        !_isLoading;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.productData != null;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Product' : 'Add Product',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges && !_isLoading)
              TextButton(
                onPressed: _saveDraft,
                child: Text(
                  'Draft',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: _isLoading
                  ? Container(
                      width: 20,
                      height: 20,
                      margin:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : TextButton(
                      onPressed: _canSave ? _saveProduct : null,
                      style: TextButton.styleFrom(
                        foregroundColor: _canSave
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                      ),
                      child: Text(
                        'Save',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Section
                ProductFormSection(
                  title: 'Basic Information',
                  children: [
                    ProductNameField(
                      controller: _productNameController,
                      errorText: _productNameError,
                      onChanged: (value) => _onFormChanged(),
                    ),
                    SizedBox(height: 3.h),
                    CategoryDropdownField(
                      selectedCategory: _selectedCategory,
                      onChanged: _onCategoryChanged,
                      errorText: _categoryError,
                    ),
                  ],
                ),

                // Pricing Section
                ProductFormSection(
                  title: 'Pricing',
                  children: [
                    RateInputField(
                      controller: _rateController,
                      errorText: _rateError,
                      onChanged: (value) => _onFormChanged(),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info_outline',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Rate will be used to calculate total price based on dimensions (width × height)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Description Section
                ProductFormSection(
                  title: 'Description',
                  children: [
                    DescriptionField(
                      controller: _descriptionController,
                      onChanged: (value) => _onFormChanged(),
                    ),
                  ],
                ),

                // Images Section
                ProductFormSection(
                  title: 'Product Images',
                  children: [
                    ImageSection(
                      selectedImages: _selectedImages,
                      onImagesChanged: _onImagesChanged,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}