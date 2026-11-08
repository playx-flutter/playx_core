import 'package:flutter/material.dart';

/// * MediaQuery shortcuts
extension ContextMediaQueryExtensions on BuildContext {
  /// shortcut for `MediaQuery.of(context)`
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// shortcut for `MediaQuery.of(context).size`
  ///
  /// Note: [BuildContext] has its own `size` member (the size of the widget's
  /// render object), which wins over this extension getter when called as
  /// `context.size`. Use [width], [height] and [aspectRatio], or
  /// `ContextMediaQueryExtensions(context).size`, for the screen size.
  Size get size => mediaQuery.size;

  /// shortcut for `MediaQuery.of(context).size.width`
  double get width => size.width;

  /// shortcut for `MediaQuery.of(context).size.height`
  double get height => size.height;

  /// shortcut for `MediaQuery.of(this).size.aspectRatio`
  double get aspectRatio => size.aspectRatio;

  /// shortcut for `MediaQuery.of(context).padding`
  EdgeInsets get mediaQueryPadding => mediaQuery.padding;

  /// shortcut for `MediaQuery.of(context).orientation`
  Orientation get orientation => mediaQuery.orientation;

  /// shortcut for `MediaQuery.of(context).orientation == Orientation.portrait`
  bool get isPortrait => orientation == Orientation.portrait;

  /// shortcut for `MediaQuery.of(context).orientation == Orientation.landscape`
  bool get isLandscape => orientation == Orientation.landscape;

  /// shortcut for `MediaQuery.of(context).alwaysUse24HourFormat`
  bool get alwaysUse24HourFormat => mediaQuery.alwaysUse24HourFormat;

  /// Number of grid columns for the current screen width, e.g. for
  /// `GridView.count(crossAxisCount: context.crossAxisCount())`.
  ///
  /// Returns [wide] when the width is at least [wideBreakpoint], [medium] when
  /// it is at least [mediumBreakpoint], and [compact] otherwise.
  int crossAxisCount({
    double mediumBreakpoint = 840,
    double wideBreakpoint = 1400,
    int compact = 1,
    int medium = 2,
    int wide = 3,
  }) {
    if (width >= wideBreakpoint) return wide;
    if (width >= mediumBreakpoint) return medium;
    return compact;
  }
}
