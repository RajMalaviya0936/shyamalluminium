import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final CustomBottomBarVariant variant;
  final double? elevation;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.elevation,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  static const List<_BottomBarItem> _items = [
    _BottomBarItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    _BottomBarItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Products',
      route: '/product-management',
    ),
    _BottomBarItem(
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      label: 'Quotations',
      route: '/quotation-list',
    ),
    _BottomBarItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Invoices',
      route: '/invoice-management',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine styling based on variant
    double barElevation;
    Color? barBackgroundColor;
    Color? barSelectedItemColor;
    Color? barUnselectedItemColor;

    switch (variant) {
      case CustomBottomBarVariant.standard:
        barElevation = elevation ?? 8.0;
        barBackgroundColor = backgroundColor ?? colorScheme.surface;
        barSelectedItemColor = selectedItemColor ?? colorScheme.primary;
        barUnselectedItemColor =
            unselectedItemColor ?? colorScheme.onSurface.withAlpha(153);
        break;
      case CustomBottomBarVariant.floating:
        barElevation = elevation ?? 12.0;
        barBackgroundColor = backgroundColor ?? colorScheme.surface;
        barSelectedItemColor = selectedItemColor ?? colorScheme.primary;
        barUnselectedItemColor =
            unselectedItemColor ?? colorScheme.onSurface.withAlpha(153);
        break;
      case CustomBottomBarVariant.minimal:
        barElevation = elevation ?? 0.0;
        barBackgroundColor = backgroundColor ?? colorScheme.surface;
        barSelectedItemColor = selectedItemColor ?? colorScheme.primary;
        barUnselectedItemColor =
            unselectedItemColor ?? colorScheme.onSurface.withAlpha(153);
        break;
    }

    if (variant == CustomBottomBarVariant.floating) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: barBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(20),
              blurRadius: barElevation,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: _buildBottomNavigationBar(
            theme,
            barBackgroundColor,
            barSelectedItemColor,
            barUnselectedItemColor,
            0.0, // No elevation for floating variant container
          ),
        ),
      );
    }

    return _buildBottomNavigationBar(
      theme,
      barBackgroundColor,
      barSelectedItemColor,
      barUnselectedItemColor,
      barElevation,
    );
  }

  Widget _buildBottomNavigationBar(
    ThemeData theme,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double elevation,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!(index);
        } else {
          // Default navigation behavior
          final context = navigatorKey.currentContext;
          if (context != null && index < _items.length) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              _items[index].route,
              (route) => false,
            );
          }
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      elevation: elevation,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      items: _items.map((item) {
        final isSelected = _items.indexOf(item) == currentIndex;
        return BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              key: ValueKey(isSelected),
              size: 24,
            ),
          ),
          label: item.label,
        );
      }).toList(),
    );
  }

  /// Factory constructor for standard bottom bar
  factory CustomBottomBar.standard({
    required int currentIndex,
    ValueChanged<int>? onTap,
  }) {
    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
    );
  }

  /// Factory constructor for floating bottom bar
  factory CustomBottomBar.floating({
    required int currentIndex,
    ValueChanged<int>? onTap,
  }) {
    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.floating,
    );
  }

  /// Factory constructor for minimal bottom bar
  factory CustomBottomBar.minimal({
    required int currentIndex,
    ValueChanged<int>? onTap,
  }) {
    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.minimal,
    );
  }
}

class _BottomBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _BottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

// Global navigator key for navigation from static context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
