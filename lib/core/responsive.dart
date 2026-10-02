import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

/// Breakpoints + helpers so every screen adapts to phone / tablet / web.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double maxAppWidth = 1100;

  static double width(BuildContext c) => MediaQuery.sizeOf(c).width;
  static double height(BuildContext c) => MediaQuery.sizeOf(c).height;

  static DeviceType type(BuildContext c) {
    final w = width(c);
    if (w >= desktopBreakpoint) return DeviceType.desktop;
    if (w >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext c) => type(c) == DeviceType.mobile;
  static bool isTablet(BuildContext c) => type(c) == DeviceType.tablet;
  static bool isDesktop(BuildContext c) => type(c) == DeviceType.desktop;

  /// Pick a value per device type.
  static T value<T>(BuildContext c,
      {required T mobile, T? tablet, T? desktop}) {
    switch (type(c)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Number of product grid columns.
  static int gridCount(BuildContext c) =>
      value<int>(c, mobile: 2, tablet: 3, desktop: 4);

  /// Horizontal screen padding.
  static double hPad(BuildContext c) =>
      value<double>(c, mobile: 16, tablet: 24, desktop: 32);

  /// Scale a font size slightly on larger screens.
  static double sp(BuildContext c, double size) =>
      size * value<double>(c, mobile: 1, tablet: 1.08, desktop: 1.15);
}

/// Centers content and limits its width (great for tablets / web).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsiveCenter(
      {super.key, required this.child, this.maxWidth = Responsive.maxAppWidth});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
