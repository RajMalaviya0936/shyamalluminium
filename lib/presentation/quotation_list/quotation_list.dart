import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/bulk_action_menu_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/quotation_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_options_widget.dart';

class QuotationList extends StatefulWidget {
  const QuotationList({super.key});

  @override
  State<QuotationList> createState() => _QuotationListState();
}

class _QuotationListState extends State<QuotationList>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _quotations = [];
  List<Map<String, dynamic>> _filteredQuotations = [];
  Map<String, dynamic> _currentFilters = {};
  SortOption _currentSort = SortOption.dateNewest;

  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  Set<String> _selectedQuotations = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuotations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isMultiSelectMode
          ? _buildMultiSelectAppBar()
          : CustomAppBar(
              title: 'Quotations',
              variant: CustomAppBarVariant.primary,
              showBackButton: false,
              actions: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showSortOptions();
                  },
                  icon: CustomIconWidget(
                    iconName: 'sort',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/create-quotation');
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
                onVoiceSearch: _handleVoiceSearch,
              ),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),

          // Bulk action menu
          if (_isMultiSelectMode && _selectedQuotations.isNotEmpty)
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: BulkActionMenuWidget(
                selectedCount: _selectedQuotations.length,
                onDelete: _handleBulkDelete,
                onExport: _handleBulkExport,
                onShare: _handleBulkShare,
                onCancel: _exitMultiSelectMode,
              ),
            ),
        ],
      ),
      floatingActionButton: !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/create-quotation');
              },
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: _exitMultiSelectMode,
        icon: CustomIconWidget(
          iconName: 'close',
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        '${_selectedQuotations.length} Selected',
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _selectAll,
          icon: CustomIconWidget(
            iconName: _selectedQuotations.length == _filteredQuotations.length
                ? 'deselect'
                : 'select_all',
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading && _quotations.isEmpty) {
      return _buildLoadingState();
    }

    if (_filteredQuotations.isEmpty &&
        _searchQuery.isEmpty &&
        _currentFilters.isEmpty) {
      return EmptyStateWidget(
        onButtonPressed: () {
          Navigator.pushNamed(context, '/create-quotation');
        },
      );
    }

    if (_filteredQuotations.isEmpty) {
      return EmptyStateWidget(
        title: 'No Results Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No quotations match your search criteria. Try adjusting your search terms or filters.'
            : 'No quotations match your current filters. Try adjusting your filter criteria.',
        buttonText: 'Clear Filters',
        onButtonPressed: _clearFilters,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshQuotations,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredQuotations.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredQuotations.length) {
            return _buildLoadingIndicator();
          }

          final quotation = _filteredQuotations[index];
          final quotationId = quotation['quotationNumber'] as String;
          final isSelected = _selectedQuotations.contains(quotationId);

          return QuotationCardWidget(
            quotation: quotation,
            isSelected: isSelected,
            onTap: () => _handleQuotationTap(quotation),
            onLongPress: () => _handleQuotationLongPress(quotationId),
            onEdit: () => _handleEdit(quotation),
            onDuplicate: () => _handleDuplicate(quotation),
            onConvertToInvoice: () => _handleConvertToInvoice(quotation),
            onDelete: () => _handleDelete(quotation),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 2.h),
          Text(
            'Loading quotations...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _loadQuotations() {
    setState(() {
      _isLoading = true;
    });

    // Mock quotations data
    _quotations = [
      {
        "quotationNumber": "QT-2025-001",
        "customerName": "John Smith",
        "customerPhone": "+1 234 567 8901",
        "customerAddress": "123 Main St, New York, NY 10001",
        "date": DateTime(2025, 1, 15),
        "status": "Draft",
        "totalAmount": 2450.00,
        "items": [
          {
            "productName": "Aluminium Sliding Door",
            "category": "Aluminium",
            "width": 72.0,
            "height": 84.0,
            "unit": "inches",
            "rate": 25.50,
            "quantity": 1,
            "amount": 2450.00,
          }
        ],
        "gstRate": 18.0,
        "gstAmount": 441.00,
        "finalAmount": 2891.00,
      },
      {
        "quotationNumber": "QT-2025-002",
        "customerName": "Sarah Johnson",
        "customerPhone": "+1 234 567 8902",
        "customerAddress": "456 Oak Ave, Los Angeles, CA 90210",
        "date": DateTime(2025, 1, 18),
        "status": "Sent",
        "totalAmount": 1850.00,
        "items": [
          {
            "productName": "PVC Window Frame",
            "category": "PVC",
            "width": 48.0,
            "height": 36.0,
            "unit": "inches",
            "rate": 18.75,
            "quantity": 2,
            "amount": 1850.00,
          }
        ],
        "gstRate": 18.0,
        "gstAmount": 333.00,
        "finalAmount": 2183.00,
      },
      {
        "quotationNumber": "QT-2025-003",
        "customerName": "Michael Brown",
        "customerPhone": "+1 234 567 8903",
        "customerAddress": "789 Pine St, Chicago, IL 60601",
        "date": DateTime(2025, 1, 20),
        "status": "Approved",
        "totalAmount": 3200.00,
        "items": [
          {
            "productName": "Wooden Door",
            "category": "Wooden",
            "width": 36.0,
            "height": 84.0,
            "unit": "inches",
            "rate": 45.00,
            "quantity": 2,
            "amount": 3200.00,
          }
        ],
        "gstRate": 18.0,
        "gstAmount": 576.00,
        "finalAmount": 3776.00,
      },
      {
        "quotationNumber": "QT-2025-004",
        "customerName": "Emily Davis",
        "customerPhone": "+1 234 567 8904",
        "customerAddress": "321 Elm St, Houston, TX 77001",
        "date": DateTime(2025, 1, 12),
        "status": "Converted",
        "totalAmount": 1650.00,
        "items": [
          {
            "productName": "Glass Partition",
            "category": "Glass",
            "width": 96.0,
            "height": 72.0,
            "unit": "inches",
            "rate": 22.50,
            "quantity": 1,
            "amount": 1650.00,
          }
        ],
        "gstRate": 18.0,
        "gstAmount": 297.00,
        "finalAmount": 1947.00,
      },
      {
        "quotationNumber": "QT-2025-005",
        "customerName": "David Wilson",
        "customerPhone": "+1 234 567 8905",
        "customerAddress": "654 Maple Dr, Phoenix, AZ 85001",
        "date": DateTime(2025, 1, 10),
        "status": "Rejected",
        "totalAmount": 2100.00,
        "items": [
          {
            "productName": "Aluminium Window",
            "category": "Aluminium",
            "width": 60.0,
            "height": 48.0,
            "unit": "inches",
            "rate": 28.00,
            "quantity": 2,
            "amount": 2100.00,
          }
        ],
        "gstRate": 18.0,
        "gstAmount": 378.00,
        "finalAmount": 2478.00,
      },
    ];

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _applyFiltersAndSort();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_quotations);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((quotation) {
        final customerName =
            (quotation['customerName'] as String).toLowerCase();
        final quotationNumber =
            (quotation['quotationNumber'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return customerName.contains(query) || quotationNumber.contains(query);
      }).toList();
    }

    // Apply filters
    if (_currentFilters.isNotEmpty) {
      if (_currentFilters.containsKey('dateRange')) {
        final DateTimeRange dateRange = _currentFilters['dateRange'];
        filtered = filtered.where((quotation) {
          final date = quotation['date'] as DateTime;
          return date
                  .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              date.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      if (_currentFilters.containsKey('customer')) {
        final customer = _currentFilters['customer'] as String;
        filtered = filtered.where((quotation) {
          return quotation['customerName'] == customer;
        }).toList();
      }

      if (_currentFilters.containsKey('status')) {
        final status = _currentFilters['status'] as String;
        filtered = filtered.where((quotation) {
          return quotation['status'] == status;
        }).toList();
      }
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.dateNewest:
        filtered.sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case SortOption.dateOldest:
        filtered.sort(
            (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        break;
      case SortOption.amountHighest:
        filtered.sort((a, b) =>
            (b['totalAmount'] as double).compareTo(a['totalAmount'] as double));
        break;
      case SortOption.amountLowest:
        filtered.sort((a, b) =>
            (a['totalAmount'] as double).compareTo(b['totalAmount'] as double));
        break;
      case SortOption.customerAZ:
        filtered.sort((a, b) => (a['customerName'] as String)
            .compareTo(b['customerName'] as String));
        break;
      case SortOption.customerZA:
        filtered.sort((a, b) => (b['customerName'] as String)
            .compareTo(a['customerName'] as String));
        break;
    }

    setState(() {
      _filteredQuotations = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: 80.h,
        child: FilterBottomSheetWidget(
          currentFilters: _currentFilters,
          onFiltersApplied: (filters) {
            setState(() {
              _currentFilters = filters;
            });
            _applyFiltersAndSort();
          },
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SortOptionsWidget(
        currentSort: _currentSort,
        onSortChanged: (sort) {
          setState(() {
            _currentSort = sort;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _handleVoiceSearch() {
    // Voice search functionality handled by SearchBarWidget
  }

  void _clearFilters() {
    setState(() {
      _currentFilters.clear();
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFiltersAndSort();
  }

  Future<void> _refreshQuotations() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadQuotations();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data when near bottom
      _loadMoreQuotations();
    }
  }

  void _loadMoreQuotations() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleQuotationTap(Map<String, dynamic> quotation) {
    if (_isMultiSelectMode) {
      _toggleSelection(quotation['quotationNumber'] as String);
    } else {
      // Navigate to quotation detail
      Navigator.pushNamed(
        context,
        '/quotation-detail',
        arguments: quotation,
      );
    }
  }

  void _handleQuotationLongPress(String quotationId) {
    if (!_isMultiSelectMode) {
      setState(() {
        _isMultiSelectMode = true;
        _selectedQuotations.add(quotationId);
      });
    }
  }

  void _toggleSelection(String quotationId) {
    setState(() {
      if (_selectedQuotations.contains(quotationId)) {
        _selectedQuotations.remove(quotationId);
        if (_selectedQuotations.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedQuotations.add(quotationId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedQuotations.length == _filteredQuotations.length) {
        _selectedQuotations.clear();
        _isMultiSelectMode = false;
      } else {
        _selectedQuotations = _filteredQuotations
            .map((q) => q['quotationNumber'] as String)
            .toSet();
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedQuotations.clear();
    });
  }

  void _handleEdit(Map<String, dynamic> quotation) {
    Navigator.pushNamed(
      context,
      '/create-quotation',
      arguments: {'quotation': quotation, 'mode': 'edit'},
    );
  }

  void _handleDuplicate(Map<String, dynamic> quotation) {
    Navigator.pushNamed(
      context,
      '/create-quotation',
      arguments: {'quotation': quotation, 'mode': 'duplicate'},
    );
  }

  void _handleConvertToInvoice(Map<String, dynamic> quotation) {
    Navigator.pushNamed(
      context,
      '/create-invoice',
      arguments: quotation,
    );
  }

  void _handleDelete(Map<String, dynamic> quotation) {
    final quotationNumber = quotation['quotationNumber'] as String;
    setState(() {
      _quotations.removeWhere((q) => q['quotationNumber'] == quotationNumber);
    });
    _applyFiltersAndSort();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quotation $quotationNumber deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _quotations.add(quotation);
            });
            _applyFiltersAndSort();
          },
        ),
      ),
    );
  }

  void _handleBulkDelete() {
    final selectedIds = Set.from(_selectedQuotations);
    setState(() {
      _quotations
          .removeWhere((q) => selectedIds.contains(q['quotationNumber']));
      _isMultiSelectMode = false;
      _selectedQuotations.clear();
    });
    _applyFiltersAndSort();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedIds.length} quotations deleted'),
      ),
    );
  }

  void _handleBulkExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedQuotations.length} quotations...'),
      ),
    );
    _exitMultiSelectMode();
  }

  void _handleBulkShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_selectedQuotations.length} quotations...'),
      ),
    );
    _exitMultiSelectMode();
  }
}
