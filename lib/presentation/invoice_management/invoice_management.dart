import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/pdf_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../core/app_export.dart';
import './widgets/bulk_actions_toolbar_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/invoice_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class InvoiceManagement extends StatefulWidget {
  const InvoiceManagement({super.key});

  @override
  State<InvoiceManagement> createState() => _InvoiceManagementState();
}

class _InvoiceManagementState extends State<InvoiceManagement>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Search and filter state
  String _searchQuery = '';
  List<String> _activeFilters = [];
  SortOption _currentSort = SortOption.dateNewest;

  // Selection state
  Set<String> _selectedInvoices = {};
  bool _isMultiSelectMode = false;

  // Data state
  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _loadSearchSuggestions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock invoice data
    _allInvoices = [
      {
        "id": "1",
        "invoiceNumber": "INV-2024-001",
        "customerName": "John Smith Construction",
        "customerPhone": "+1 (555) 123-4567",
        "customerAddress": "123 Main St, New York, NY 10001",
        "amount": 2450.00,
        "status": "paid",
        "date": "2024-08-18T10:30:00.000Z",
        "dueDate": "2024-09-18T10:30:00.000Z",
        "items": [
          {
            "name": "Aluminium Door",
            "quantity": 2,
            "rate": 850.00,
            "total": 1700.00
          },
          {"name": "PVC Window", "quantity": 3, "rate": 250.00, "total": 750.00}
        ],
        "subtotal": 2450.00,
        "tax": 245.00,
        "total": 2695.00
      },
      {
        "id": "2",
        "invoiceNumber": "INV-2024-002",
        "customerName": "Sarah Johnson Interiors",
        "customerPhone": "+1 (555) 987-6543",
        "customerAddress": "456 Oak Ave, Los Angeles, CA 90210",
        "amount": 1850.50,
        "status": "pending",
        "date": "2024-08-19T14:15:00.000Z",
        "dueDate": "2024-09-19T14:15:00.000Z",
        "items": [
          {
            "name": "Wooden Door",
            "quantity": 1,
            "rate": 1200.00,
            "total": 1200.00
          },
          {
            "name": "Glass Panel",
            "quantity": 2,
            "rate": 325.25,
            "total": 650.50
          }
        ],
        "subtotal": 1850.50,
        "tax": 185.05,
        "total": 2035.55
      },
      {
        "id": "3",
        "invoiceNumber": "INV-2024-003",
        "customerName": "Mike Wilson Renovations",
        "customerPhone": "+1 (555) 456-7890",
        "customerAddress": "789 Pine St, Chicago, IL 60601",
        "amount": 3200.75,
        "status": "overdue",
        "date": "2024-08-10T09:45:00.000Z",
        "dueDate": "2024-08-25T09:45:00.000Z",
        "items": [
          {
            "name": "PVC Cupboard",
            "quantity": 4,
            "rate": 650.00,
            "total": 2600.00
          },
          {
            "name": "Aluminium Frame",
            "quantity": 3,
            "rate": 200.25,
            "total": 600.75
          }
        ],
        "subtotal": 3200.75,
        "tax": 320.08,
        "total": 3520.83
      },
      {
        "id": "4",
        "invoiceNumber": "INV-2024-004",
        "customerName": "Lisa Brown Designs",
        "customerPhone": "+1 (555) 321-0987",
        "customerAddress": "321 Elm St, Miami, FL 33101",
        "amount": 1675.25,
        "status": "pending",
        "date": "2024-08-20T11:20:00.000Z",
        "dueDate": "2024-09-20T11:20:00.000Z",
        "items": [
          {
            "name": "Sliding Window",
            "quantity": 5,
            "rate": 335.05,
            "total": 1675.25
          }
        ],
        "subtotal": 1675.25,
        "tax": 167.53,
        "total": 1842.78
      },
      {
        "id": "5",
        "invoiceNumber": "INV-2024-005",
        "customerName": "Robert Davis Contractors",
        "customerPhone": "+1 (555) 654-3210",
        "customerAddress": "654 Maple Dr, Seattle, WA 98101",
        "amount": 4125.00,
        "status": "paid",
        "date": "2024-08-15T16:30:00.000Z",
        "dueDate": "2024-09-15T16:30:00.000Z",
        "items": [
          {
            "name": "Wooden Door",
            "quantity": 3,
            "rate": 1200.00,
            "total": 3600.00
          },
          {
            "name": "Glass Panel",
            "quantity": 1,
            "rate": 525.00,
            "total": 525.00
          }
        ],
        "subtotal": 4125.00,
        "tax": 412.50,
        "total": 4537.50
      },
    ];

    _applyFiltersAndSort();
    setState(() => _isLoading = false);
  }

  void _loadSearchSuggestions() {
    _searchSuggestions = [
      'John Smith Construction',
      'Sarah Johnson Interiors',
      'Mike Wilson Renovations',
      'INV-2024-001',
      'INV-2024-002',
      'August 2024',
      'Paid invoices',
      'Pending invoices',
    ];
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_allInvoices);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) {
        final customerName = (invoice['customerName'] as String).toLowerCase();
        final invoiceNumber =
            (invoice['invoiceNumber'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return customerName.contains(query) || invoiceNumber.contains(query);
      }).toList();
    }

    // Apply status filters
    if (_activeFilters.isNotEmpty) {
      filtered = filtered.where((invoice) {
        final status = (invoice['status'] as String).toLowerCase();

        for (String filter in _activeFilters) {
          switch (filter.toLowerCase()) {
            case 'paid':
              if (status == 'paid') return true;
              break;
            case 'pending':
              if (status == 'pending') return true;
              break;
            case 'overdue':
              if (status == 'overdue') return true;
              break;
            case 'cancelled':
              if (status == 'cancelled') return true;
              break;
            case 'this week':
              final invoiceDate = DateTime.parse(invoice['date'] as String);
              final now = DateTime.now();
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              if (invoiceDate.isAfter(weekStart)) return true;
              break;
            case 'this month':
              final invoiceDate = DateTime.parse(invoice['date'] as String);
              final now = DateTime.now();
              if (invoiceDate.month == now.month &&
                  invoiceDate.year == now.year) return true;
              break;
            case 'last 30 days':
              final invoiceDate = DateTime.parse(invoice['date'] as String);
              final thirtyDaysAgo =
                  DateTime.now().subtract(const Duration(days: 30));
              if (invoiceDate.isAfter(thirtyDaysAgo)) return true;
              break;
          }
        }
        return false;
      }).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => DateTime.parse(b['date'] as String)
            .compareTo(DateTime.parse(a['date'] as String)));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => DateTime.parse(a['date'] as String)
            .compareTo(DateTime.parse(b['date'] as String)));
        break;
      case SortOption.amountHighest:
        filtered
            .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
        break;
      case SortOption.amountLowest:
        filtered
            .sort((a, b) => (a['amount'] as num).compareTo(b['amount'] as num));
        break;
      case SortOption.customerAZ:
        filtered.sort((a, b) => (a['customerName'] as String)
            .compareTo(b['customerName'] as String));
        break;
      case SortOption.customerZA:
        filtered.sort((a, b) => (b['customerName'] as String)
            .compareTo(a['customerName'] as String));
        break;
      case SortOption.statusPaid:
        filtered.sort((a, b) {
          final aStatus = a['status'] as String;
          final bStatus = b['status'] as String;
          if (aStatus == 'paid' && bStatus != 'paid') return -1;
          if (bStatus == 'paid' && aStatus != 'paid') return 1;
          return 0;
        });
        break;
      case SortOption.statusPending:
        filtered.sort((a, b) {
          final aStatus = a['status'] as String;
          final bStatus = b['status'] as String;
          if (aStatus == 'pending' && bStatus != 'pending') return -1;
          if (bStatus == 'pending' && aStatus != 'pending') return 1;
          return 0;
        });
        break;
    }

    setState(() {
      _filteredInvoices = filtered;
    });
  }

  Future<void> _refreshInvoices() async {
    HapticFeedback.mediumImpact();
    await _loadInvoices();
  }

  void _onInvoiceTap(Map<String, dynamic> invoice) {
    if (_isMultiSelectMode) {
      _toggleInvoiceSelection(invoice['id'] as String);
    } else {
      // Navigate to invoice detail screen
      Navigator.pushNamed(context, '/invoice-detail', arguments: invoice);
    }
  }

  void _onInvoiceLongPress(Map<String, dynamic> invoice) {
    if (!_isMultiSelectMode) {
      setState(() {
        _isMultiSelectMode = true;
        _selectedInvoices.add(invoice['id'] as String);
      });
    }
  }

  void _toggleInvoiceSelection(String invoiceId) {
    setState(() {
      if (_selectedInvoices.contains(invoiceId)) {
        _selectedInvoices.remove(invoiceId);
        if (_selectedInvoices.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedInvoices.add(invoiceId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedInvoices.clear();
      _isMultiSelectMode = false;
    });
  }

  Future<void> _exportMultiplePDFs() async {
    HapticFeedback.mediumImpact();

    if (_selectedInvoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No invoices selected to export')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating ${_selectedInvoices.length} PDFs...')),
    );

    try {
      await _generateAndShareSelectedPdfs();
      _clearSelection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generation failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _generateAndShareSelectedPdfs() async {
    final tempDir = await getTemporaryDirectory();
    final List<String> paths = [];

    for (var id in _selectedInvoices) {
      final invoice = _allInvoices.cast<Map<String, dynamic>?>().firstWhere(
            (inv) => inv != null && inv['id'] == id,
            orElse: () => null,
          );
      if (invoice == null) continue;
      try {
        final bytes = await generateInvoicePdfBytes(invoice);
        final file = File('${tempDir.path}/${invoice['invoiceNumber']}.pdf');
        await file.writeAsBytes(bytes);
        paths.add(file.path);
      } catch (e) {
        // ignore individual invoice failures and continue with others
        // ignore: avoid_print
        print(
            'Failed to generate PDF for invoice ${invoice['invoiceNumber']}: $e');
        continue;
      }
    }

    if (paths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDFs')),
      );
      return;
    }

    // Share files
    try {
      await Share.shareXFiles(paths.map((p) => XFile(p)).toList(),
          text: 'Invoices');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDFs generated and ready to share')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDFs: ${e.toString()}')),
      );
    }
  }

  void _deleteMultipleInvoices() {
    setState(() {
      _allInvoices.removeWhere(
          (invoice) => _selectedInvoices.contains(invoice['id'] as String));
      _applyFiltersAndSort();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedInvoices.length} invoices deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
    _clearSelection();
  }

  void _markSelectedAsPaid() {
    setState(() {
      for (var invoice in _allInvoices) {
        if (_selectedInvoices.contains(invoice['id'] as String)) {
          invoice['status'] = 'paid';
        }
      }
      _applyFiltersAndSort();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedInvoices.length} invoices marked as paid'),
      ),
    );
    _clearSelection();
  }

  void _editInvoice(Map<String, dynamic> invoice) {
    Navigator.pushNamed(context, '/create-quotation', arguments: invoice);
  }

  void _shareInvoice(Map<String, dynamic> invoice) {
    // Implement PDF sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing invoice ${invoice['invoiceNumber']}...'),
      ),
    );
  }

  void _deleteInvoice(Map<String, dynamic> invoice) {
    setState(() {
      _allInvoices.removeWhere((item) => item['id'] == invoice['id']);
      _applyFiltersAndSort();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice ${invoice['invoiceNumber']} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allInvoices.add(invoice);
              _applyFiltersAndSort();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? '${_selectedInvoices.length} Selected'
              : 'Invoice Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: _clearSelection,
                icon: CustomIconWidget(
                  iconName: 'close',
                  size: 24,
                  color: colorScheme.onSurface,
                ),
              )
            : null,
        actions: [
          if (!_isMultiSelectMode) ...[
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/create-quotation');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                size: 24,
                color: colorScheme.primary,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _exportMultiplePDFs,
              icon: CustomIconWidget(
                iconName: 'file_download',
                size: 24,
                color: colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: _markSelectedAsPaid,
              icon: CustomIconWidget(
                iconName: 'check_circle',
                size: 24,
                color: AppTheme.accentLight,
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          SearchFilterBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
              _applyFiltersAndSort();
            },
            activeFilters: _activeFilters,
            onFiltersChanged: (filters) {
              setState(() => _activeFilters = filters);
              _applyFiltersAndSort();
            },
            onSortPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SortBottomSheetWidget(
                  currentSort: _currentSort,
                  onSortChanged: (sort) {
                    setState(() => _currentSort = sort);
                    _applyFiltersAndSort();
                  },
                ),
              );
            },
            searchSuggestions: _searchSuggestions,
          ),

          // Bulk actions toolbar
          BulkActionsToolbarWidget(
            selectedCount: _selectedInvoices.length,
            onClearSelection: _clearSelection,
            onExportMultiple: _exportMultiplePDFs,
            onDeleteMultiple: _deleteMultipleInvoices,
            onMarkPaid: _markSelectedAsPaid,
          ),

          // Invoice list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _filteredInvoices.isEmpty
                    ? _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                        ? EmptyStateWidget.noSearchResults(query: _searchQuery)
                        : _isOffline
                            ? EmptyStateWidget.offline()
                            : EmptyStateWidget.noInvoices(
                                onCreateInvoice: () {
                                  Navigator.pushNamed(
                                      context, '/create-quotation');
                                },
                              )
                    : RefreshIndicator(
                        onRefresh: _refreshInvoices,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoices[index];
                            final invoiceId = invoice['id'] as String;

                            return InvoiceCardWidget(
                              invoice: invoice,
                              isSelected: _selectedInvoices.contains(invoiceId),
                              onTap: () => _onInvoiceTap(invoice),
                              onLongPress: () => _onInvoiceLongPress(invoice),
                              onEdit: () => _editInvoice(invoice),
                              onShare: () => _shareInvoice(invoice),
                              onDelete: () => _deleteInvoice(invoice),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Invoice Management tab
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8.0,
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/dashboard', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/product-management', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/quotation-list', (route) => false);
              break;
            case 3:
              // Current screen
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: colorScheme.primary,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'inventory_2',
              size: 24,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: CustomIconWidget(
              iconName: 'inventory_2',
              size: 24,
              color: colorScheme.primary,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'description',
              size: 24,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: CustomIconWidget(
              iconName: 'description',
              size: 24,
              color: colorScheme.primary,
            ),
            label: 'Quotations',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'receipt_long',
              size: 24,
              color: colorScheme.primary,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'receipt_long',
              size: 24,
              color: colorScheme.primary,
            ),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}
