import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  primary,
  secondary,
  minimal,
  pills,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final CustomTabBarVariant variant;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double? indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.variant = CustomTabBarVariant.primary,
    this.isScrollable = false,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight,
    this.labelPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine styling based on variant
    Color? tabBackgroundColor;
    Color? tabIndicatorColor;
    Color? tabLabelColor;
    Color? tabUnselectedLabelColor;
    double tabIndicatorWeight;
    EdgeInsetsGeometry tabLabelPadding;
    Decoration? indicator;

    switch (variant) {
      case CustomTabBarVariant.primary:
        tabBackgroundColor = backgroundColor ?? colorScheme.surface;
        tabIndicatorColor = indicatorColor ?? colorScheme.primary;
        tabLabelColor = labelColor ?? colorScheme.primary;
        tabUnselectedLabelColor =
            unselectedLabelColor ?? colorScheme.onSurface.withAlpha(153);
        tabIndicatorWeight = indicatorWeight ?? 3.0;
        tabLabelPadding =
            labelPadding ?? const EdgeInsets.symmetric(horizontal: 16.0);
        break;
      case CustomTabBarVariant.secondary:
        tabBackgroundColor =
            backgroundColor ?? colorScheme.surfaceContainerHighest;
        tabIndicatorColor = indicatorColor ?? colorScheme.primary;
        tabLabelColor = labelColor ?? colorScheme.onSurface;
        tabUnselectedLabelColor =
            unselectedLabelColor ?? colorScheme.onSurface.withAlpha(153);
        tabIndicatorWeight = indicatorWeight ?? 2.0;
        tabLabelPadding =
            labelPadding ?? const EdgeInsets.symmetric(horizontal: 16.0);
        break;
      case CustomTabBarVariant.minimal:
        tabBackgroundColor = backgroundColor ?? Colors.transparent;
        tabIndicatorColor = indicatorColor ?? colorScheme.primary;
        tabLabelColor = labelColor ?? colorScheme.primary;
        tabUnselectedLabelColor =
            unselectedLabelColor ?? colorScheme.onSurface.withAlpha(153);
        tabIndicatorWeight = indicatorWeight ?? 1.0;
        tabLabelPadding =
            labelPadding ?? const EdgeInsets.symmetric(horizontal: 12.0);
        break;
      case CustomTabBarVariant.pills:
        tabBackgroundColor = backgroundColor ?? colorScheme.surface;
        tabIndicatorColor = indicatorColor ?? colorScheme.primary;
        tabLabelColor = labelColor ?? colorScheme.onPrimary;
        tabUnselectedLabelColor =
            unselectedLabelColor ?? colorScheme.onSurface.withAlpha(153);
        tabIndicatorWeight = indicatorWeight ?? 0.0;
        tabLabelPadding = labelPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
        indicator = BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(20.0),
        );
        break;
    }

    return Container(
      color: tabBackgroundColor,
      child: TabBar(
        controller: controller,
        onTap: (index) {
          HapticFeedback.lightImpact();
          onTap?.call(index);
        },
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        isScrollable: isScrollable,
        indicator: indicator ??
            UnderlineTabIndicator(
              borderSide: BorderSide(
                color: tabIndicatorColor,
                width: tabIndicatorWeight,
              ),
              insets: EdgeInsets.symmetric(
                horizontal: variant == CustomTabBarVariant.minimal ? 0.0 : 16.0,
              ),
            ),
        indicatorSize: variant == CustomTabBarVariant.pills
            ? TabBarIndicatorSize.tab
            : TabBarIndicatorSize.label,
        labelColor: tabLabelColor,
        unselectedLabelColor: tabUnselectedLabelColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelPadding: tabLabelPadding,
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(26),
        ),
        splashFactory: InkRipple.splashFactory,
        dividerColor: variant == CustomTabBarVariant.minimal
            ? Colors.transparent
            : colorScheme.outline.withAlpha(51),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  /// Factory constructor for product management tabs
  factory CustomTabBar.productManagement({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      tabs: const ['All Products', 'Active', 'Inactive', 'Low Stock'],
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.primary,
      isScrollable: true,
    );
  }

  /// Factory constructor for quotation tabs
  factory CustomTabBar.quotation({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      tabs: const ['Draft', 'Sent', 'Approved', 'Rejected'],
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.pills,
      isScrollable: true,
    );
  }

  /// Factory constructor for invoice tabs
  factory CustomTabBar.invoice({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      tabs: const ['Pending', 'Paid', 'Overdue', 'Cancelled'],
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.secondary,
      isScrollable: true,
    );
  }

  /// Factory constructor for dashboard analytics tabs
  factory CustomTabBar.analytics({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      tabs: const ['Today', 'Week', 'Month', 'Year'],
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.minimal,
      isScrollable: false,
    );
  }
}
