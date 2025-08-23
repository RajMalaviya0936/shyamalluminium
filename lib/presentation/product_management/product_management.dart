import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bulk_actions_toolbar_widget.dart';
import './widgets/category_filter_chip_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_bar_widget.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isMultiSelectMode = false;
  bool _isGridView = false;
  Set<int> _selectedProducts = {};
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'Aluminium',
    'PVC',
    'Wooden',
    'Glass'
  ];

  // Mock product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "name": "Aluminium Sliding Window",
      "category": "Aluminium",
      "price": 299.99,
      "description":
          "High-quality aluminium sliding window with double glazing and weather sealing.",
      "image":
          "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 25,
    },
    {
      "id": 2,
      "name": "PVC Kitchen Cabinet Door",
      "category": "PVC",
      "price": 89.50,
      "description":
          "Durable PVC cabinet door with modern finish, perfect for kitchen renovations.",
      "image":
          "https://images.pexels.com/photos/2724749/pexels-photo-2724749.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 42,
    },
    {
      "id": 3,
      "name": "Wooden Entry Door",
      "category": "Wooden",
      "price": 450.00,
      "description":
          "Solid wood entry door with decorative glass panel and premium hardware.",
      "image":
          "https://images.pexels.com/photos/1571463/pexels-photo-1571463.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 8,
    },
    {
      "id": 4,
      "name": "Tempered Glass Panel",
      "category": "Glass",
      "price": 125.75,
      "description":
          "Safety tempered glass panel suitable for doors, windows, and partitions.",
      "image":
          "https://images.pexels.com/photos/1571468/pexels-photo-1571468.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 15,
    },
    {
      "id": 5,
      "name": "Aluminium Bi-fold Door",
      "category": "Aluminium",
      "price": 850.00,
      "description":
          "Premium aluminium bi-fold door system with smooth operation and modern design.",
      "image":
          "https://images.pexels.com/photos/1571461/pexels-photo-1571461.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": false,
      "stockQuantity": 0,
    },
    {
      "id": 6,
      "name": "PVC Window Frame",
      "category": "PVC",
      "price": 180.25,
      "description":
          "Energy-efficient PVC window frame with multi-chamber design for superior insulation.",
      "image":
          "https://images.pexels.com/photos/2724748/pexels-photo-2724748.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 18,
    },
    {
      "id": 7,
      "name": "Wooden Wardrobe Door",
      "category": "Wooden",
      "price": 220.00,
      "description":
          "Elegant wooden wardrobe door with soft-close hinges and natural wood finish.",
      "image":
          "https://images.pexels.com/photos/1571464/pexels-photo-1571464.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 12,
    },
    {
      "id": 8,
      "name": "Glass Shower Door",
      "category": "Glass",
      "price": 320.50,
      "description":
          "Frameless glass shower door with premium hardware and easy-clean coating.",
      "image":
          "https://images.pexels.com/photos/1571469/pexels-photo-1571469.jpeg?auto=compress&cs=tinysrgb&w=800",
      "inStock": true,
      "stockQuantity": 6,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          (product["category"] as String).toLowerCase() ==
              _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          (product["name"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (product["category"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int _getCategoryCount(String category) {
    if (category == 'All') return _allProducts.length;
    return _allProducts
        .where((product) =>
            (product["category"] as String).toLowerCase() ==
            category.toLowerCase())
        .length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });
  }

  void _onProductSelectionChanged(int productId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedProducts.add(productId);
        if (!_isMultiSelectMode) {
          _isMultiSelectMode = true;
        }
      } else {
        _selectedProducts.remove(productId);
        if (_selectedProducts.isEmpty) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _selectAllProducts() {
    setState(() {
      _selectedProducts =
          _filteredProducts.map((product) => product["id"] as int).toSet();
    });
  }

  void _deselectAllProducts() {
    setState(() {
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });
  }

  void _cancelMultiSelect() {
    setState(() {
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });
  }

  void _bulkDeleteProducts() {
    setState(() {
      _allProducts
          .removeWhere((product) => _selectedProducts.contains(product["id"]));
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Products deleted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _bulkDuplicateProducts() {
    final productsToAdd = <Map<String, dynamic>>[];
    final maxId =
        _allProducts.map((p) => p["id"] as int).reduce((a, b) => a > b ? a : b);
    int newId = maxId + 1;

    for (final productId in _selectedProducts) {
      final originalProduct =
          _allProducts.firstWhere((p) => p["id"] == productId);
      final duplicatedProduct = Map<String, dynamic>.from(originalProduct);
      duplicatedProduct["id"] = newId++;
      duplicatedProduct["name"] = "${duplicatedProduct["name"]} (Copy)";
      productsToAdd.add(duplicatedProduct);
    }

    setState(() {
      _allProducts.addAll(productsToAdd);
      _selectedProducts.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${productsToAdd.length} product${productsToAdd.length == 1 ? '' : 's'} duplicated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/add-edit-product',
      arguments: {'product': product, 'isEdit': true},
    );
  }

  void _duplicateProduct(Map<String, dynamic> product) {
    final maxId =
        _allProducts.map((p) => p["id"] as int).reduce((a, b) => a > b ? a : b);
    final duplicatedProduct = Map<String, dynamic>.from(product);
    duplicatedProduct["id"] = maxId + 1;
    duplicatedProduct["name"] = "${duplicatedProduct["name"]} (Copy)";

    setState(() {
      _allProducts.add(duplicatedProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product duplicated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    setState(() {
      _allProducts.removeWhere((p) => p["id"] == product["id"]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product["name"]} deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allProducts.add(product);
            });
          },
        ),
      ),
    );
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Products refreshed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Product Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _toggleViewMode,
            icon: CustomIconWidget(
              iconName: _isGridView ? 'view_list' : 'grid_view',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-edit-product');
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: colorScheme.primary,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          BulkActionsToolbarWidget(
            selectedCount: _selectedProducts.length,
            onSelectAll: _selectAllProducts,
            onDeselectAll: _deselectAllProducts,
            onBulkDelete: _bulkDeleteProducts,
            onBulkDuplicate: _bulkDuplicateProducts,
            onCancel: _cancelMultiSelect,
          ),
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search products by name or category...',
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          ),
          Container(
            height: 8.h,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryFilterChipWidget(
                  category: category,
                  isSelected: _selectedCategory == category,
                  count: _getCategoryCount(category),
                  onTap: () => _onCategorySelected(category),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: filteredProducts.isEmpty
                  ? EmptyStateWidget(
                      category: _selectedCategory,
                      searchQuery: _searchQuery,
                      onAddProduct: () {
                        Navigator.pushNamed(context, '/add-edit-product');
                      },
                    )
                  : _isGridView
                      ? _buildGridView(filteredProducts)
                      : _buildListView(filteredProducts),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/add-edit-product');
        },
        backgroundColor: colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: colorScheme.onPrimary,
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> products) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product["id"] as int;

        return ProductCardWidget(
          product: product,
          isSelected: _selectedProducts.contains(productId),
          isMultiSelectMode: _isMultiSelectMode,
          onTap: () {
            // Navigate to product detail
            Navigator.pushNamed(
              context,
              '/add-edit-product',
              arguments: {'product': product, 'isView': true},
            );
          },
          onEdit: () => _editProduct(product),
          onDuplicate: () => _duplicateProduct(product),
          onDelete: () => _deleteProduct(product),
          onSelectionChanged: (isSelected) {
            _onProductSelectionChanged(productId, isSelected ?? false);
          },
        );
      },
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> products) {
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product["id"] as int;

        return _buildGridProductCard(product, productId);
      },
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product, int productId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedProducts.contains(productId);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_isMultiSelectMode) {
          _onProductSelectionChanged(productId, !isSelected);
        } else {
          Navigator.pushNamed(
            context,
            '/add-edit-product',
            arguments: {'product': product, 'isView': true},
          );
        }
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _onProductSelectionChanged(productId, !isSelected);
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: product["image"] != null &&
                              (product["image"] as String).isNotEmpty
                          ? CustomImageWidget(
                              imageUrl: product["image"] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: CustomIconWidget(
                                iconName: _getCategoryIcon(
                                    product["category"] as String? ?? ""),
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                                size: 10.w,
                              ),
                            ),
                    ),
                  ),
                  if (_isMultiSelectMode)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          _onProductSelectionChanged(productId, value ?? false);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product["name"] as String? ?? "Unknown Product",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                                    product["category"] as String? ?? "")
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product["category"] as String? ?? "Unknown",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getCategoryColor(
                                  product["category"] as String? ?? ""),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "\$${(product["price"] as double? ?? 0.0).toStringAsFixed(2)}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
