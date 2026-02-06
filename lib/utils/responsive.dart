import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities
class Responsive {
  /// Mobile breakpoint
  static const double mobile = 600;

  /// Tablet breakpoint
  static const double tablet = 900;

  /// Desktop breakpoint
  static const double desktop = 1200;

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(isMobile(context) ? 16.0 : 24.0);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: isMobile(context) ? 16.0 : 24.0);
  }

  /// Get responsive card width
  static double cardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.3;
    } else if (isTablet(context)) {
      return screenWidth * 0.45;
    }
    return screenWidth - 32;
  }

  /// Get responsive grid column count
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    if (isTablet(context)) return baseSize * 1.1;
    if (isDesktop(context)) return baseSize * 1.2;
    return baseSize;
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(width: Responsive.cardWidth(context), child: child);
      }).toList(),
    );
  }
}
