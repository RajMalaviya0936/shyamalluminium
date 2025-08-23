import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  primary,
  secondary,
  transparent,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant
    Color? appBarBackgroundColor;
    Color? appBarForegroundColor;
    double appBarElevation;
    SystemUiOverlayStyle overlayStyle;

    switch (variant) {
      case CustomAppBarVariant.primary:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 1.0;
        overlayStyle =
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
        break;
      case CustomAppBarVariant.secondary:
        appBarBackgroundColor =
            backgroundColor ?? colorScheme.surfaceContainerHighest;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 2.0;
        overlayStyle =
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
        break;
      case CustomAppBarVariant.transparent:
        appBarBackgroundColor = backgroundColor ?? Colors.transparent;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 0.0;
        overlayStyle =
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
        break;
      case CustomAppBarVariant.minimal:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 0.0;
        overlayStyle =
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appBarForegroundColor,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      elevation: appBarElevation,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.primary.withAlpha(20),
      systemOverlayStyle: overlayStyle,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: appBarForegroundColor,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (onBackPressed != null) {
                      onBackPressed!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions?.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            onPressed: () {
              HapticFeedback.lightImpact();
              action.onPressed?.call();
            },
            color: appBarForegroundColor,
          );
        }
        return action;
      }).toList(),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  /// Factory constructor for dashboard app bar
  factory CustomAppBar.dashboard(BuildContext context) {
    return CustomAppBar(
      title: 'Dashboard',
      variant: CustomAppBarVariant.primary,
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle settings
          },
        ),
      ],
    );
  }

  /// Factory constructor for product management app bar
  factory CustomAppBar.productManagement(BuildContext context) {
    return CustomAppBar(
      title: 'Product Management',
      variant: CustomAppBarVariant.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle search
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/add-edit-product');
          },
        ),
      ],
    );
  }

  /// Factory constructor for quotation app bar
  factory CustomAppBar.quotation(BuildContext context) {
    return CustomAppBar(
      title: 'Create Quotation',
      variant: CustomAppBarVariant.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle save
          },
        ),
        IconButton(
          icon: const Icon(Icons.preview_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle preview
          },
        ),
      ],
    );
  }

  /// Factory constructor for invoice management app bar
  factory CustomAppBar.invoiceManagement(BuildContext context) {
    return CustomAppBar(
      title: 'Invoice Management',
      variant: CustomAppBarVariant.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle filter
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle more options
          },
        ),
      ],
    );
  }
}
