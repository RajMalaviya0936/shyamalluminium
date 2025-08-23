import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_action_button_widget.dart';
import './widgets/recent_activity_item_widget.dart';
import '../../widgets/custom_bottom_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  // Mock data for dashboard metrics
  final List<Map<String, dynamic>> _metrics = [
    {
      "title": "Total Products",
      "value": "156",
      "trend": "+12% this month",
      "isPositive": true,
      "route": "/product-management",
    },
    {
      "title": "Total Quotations",
      "value": "89",
      "trend": "+8% this week",
      "isPositive": true,
      "route": "/quotation-list",
    },
    {
      "title": "Total Invoices",
      "value": "234",
      "trend": "+15% this month",
      "isPositive": true,
      "route": "/invoice-management",
    },
  ];

  // Mock data for recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "type": "invoice",
      "customerName": "John Smith Construction",
      "date": "Aug 19, 2025",
      "amount": "\$2,450.00",
      "status": "paid",
    },
    {
      "id": 2,
      "type": "quotation",
      "customerName": "Sarah Johnson Interiors",
      "date": "Aug 18, 2025",
      "amount": "\$1,890.00",
      "status": "pending",
    },
    {
      "id": 3,
      "type": "invoice",
      "customerName": "Mike Davis Builders",
      "date": "Aug 17, 2025",
      "amount": "\$3,200.00",
      "status": "overdue",
    },
    {
      "id": 4,
      "type": "quotation",
      "customerName": "Lisa Chen Designs",
      "date": "Aug 16, 2025",
      "amount": "\$1,650.00",
      "status": "approved",
    },
    {
      "id": 5,
      "type": "invoice",
      "customerName": "Robert Wilson Homes",
      "date": "Aug 15, 2025",
      "amount": "\$2,100.00",
      "status": "paid",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard refreshed successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _navigateToRoute(String route) {
    Navigator.pushNamed(context, route);
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    final String type = (activity["type"] as String?) ?? "invoice";
    final String route =
        type == "quotation" ? "/quotation-list" : "/invoice-management";
    _navigateToRoute(route);
  }

  void _handleActivityEdit(Map<String, dynamic> activity) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Edit ${(activity["customerName"] as String?) ?? "item"}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleActivityShare(Map<String, dynamic> activity) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Share ${(activity["customerName"] as String?) ?? "item"} PDF'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
          'Shyam Alluminium',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Metrics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Business Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ..._metrics.map((metric) => MetricCardWidget(
                            title: (metric["title"] as String?) ?? "",
                            value: (metric["value"] as String?) ?? "0",
                            trend: (metric["trend"] as String?) ?? "",
                            isPositiveTrend:
                                (metric["isPositive"] as bool?) ?? true,
                            onTap: () => _navigateToRoute(
                                (metric["route"] as String?) ?? "/dashboard"),
                          )),
                    ],
                  ),
                ),
              ),

              // Quick Actions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          QuickActionButtonWidget(
                            title: 'Create New Quotation',
                            iconName: 'add_circle',
                            isPrimary: true,
                            onTap: () => _navigateToRoute('/create-quotation'),
                          ),
                          QuickActionButtonWidget(
                            title: 'Add Product',
                            iconName: 'inventory_2',
                            onTap: () => _navigateToRoute('/add-edit-product'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'Recent Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Recent Activity List or Empty State
              _recentActivities.isEmpty
                  ? SliverFillRemaining(
                      child: EmptyStateWidget(
                        title: 'No Recent Activity',
                        description:
                            'Start by creating your first quotation or adding products to your inventory.',
                        buttonText: 'Create Quotation',
                        iconName: 'description',
                        onButtonPressed: () =>
                            _navigateToRoute('/create-quotation'),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _recentActivities.length) return null;
                          final activity = _recentActivities[index];
                          return RecentActivityItemWidget(
                            activity: activity,
                            onTap: () => _handleActivityTap(activity),
                            onEdit: () => _handleActivityEdit(activity),
                            onShare: () => _handleActivityShare(activity),
                          );
                        },
                        childCount: _recentActivities.length,
                      ),
                    ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _navigateToRoute('/create-quotation');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        icon: CustomIconWidget(
          iconName: 'add',
          color: colorScheme.onPrimary,
          size: 5.w,
        ),
        label: Text(
          'New Quote',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Set the correct index for dashboard
        onTap: (index) {
          // Navigation logic for bottom bar
          switch (index) {
            case 0:
              _navigateToRoute('/dashboard');
              break;
            case 1:
              _navigateToRoute('/product-management');
              break;
            case 2:
              _navigateToRoute('/quotation-list');
              break;
            case 3:
              _navigateToRoute('/invoice-management');
              break;
          }
        },
      ),
    );
  }
}
