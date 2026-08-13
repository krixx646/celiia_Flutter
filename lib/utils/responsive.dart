import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared layout breakpoints (Material compact / medium).
class Breakpoints {
  static const double tablet = 600;
  static const double wide = 900;
}

/// Prefer all orientations on tablets; phones keep upright + landscape.
Future<void> configureAppOrientations() async {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    return;
  }

  final view = views.first;
  final shortestSide =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  final tablet = shortestSide >= Breakpoints.tablet;

  if (tablet) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isTablet => screenSize.shortestSide >= Breakpoints.tablet;

  bool get isWide => screenSize.width >= Breakpoints.wide;

  bool get isLandscape => screenSize.width > screenSize.height;

  /// Library / card grids: 1 phone, 2 tablet, 3 landscape wide.
  int get libraryCrossAxisCount {
    final width = screenSize.width;
    if (width >= 1100) return 3;
    if (width >= Breakpoints.tablet) return 2;
    return 1;
  }

  /// Horizontal inset that keeps content readable on large tablets.
  double get contentHorizontalPadding {
    final width = screenSize.width;
    if (width >= Breakpoints.wide) {
      return ((width - 840) / 2).clamp(32.0, 160.0);
    }
    if (isTablet) return 32;
    return 24;
  }
}

/// Centers [child] and caps width so phone layouts don't stretch on iPad.
class AdaptivePageBody extends StatelessWidget {
  const AdaptivePageBody({
    super.key,
    required this.child,
    this.maxWidth = 840,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
