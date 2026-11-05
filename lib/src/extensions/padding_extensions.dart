import 'package:flutter/widgets.dart';

/// Extensions on [num] to easily create [EdgeInsets] for padding.
///
/// These helpers return unscaled [EdgeInsets] using the receiver's
/// [num.toDouble] value. Apps that need responsive scaling should scale the
/// numeric input before applying the extension, e.g. `16.r.p` when using
/// `flutter_screenutil`.
///
/// ```dart
/// final padding = 16.p;              // EdgeInsets.all(16)
/// final hPadding = 8.px;             // EdgeInsets.symmetric(horizontal: 8)
/// final vPadding = 4.py;             // EdgeInsets.symmetric(vertical: 4)
/// final topOnly = 12.pt;             // EdgeInsets.only(top: 12)
/// final startOnly = 12.ps;           // EdgeInsetsDirectional.only(start: 12)
/// ```
extension PlayxNumPaddingExtensions on num {
  /// Creates [EdgeInsets.all] with the current value on all sides.
  EdgeInsets get p => EdgeInsets.all(toDouble());

  /// Creates [EdgeInsets.symmetric] with the current value on the horizontal
  /// (left and right) sides.
  EdgeInsets get px => EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates [EdgeInsets.symmetric] with the current value on the vertical
  /// (top and bottom) sides.
  EdgeInsets get py => EdgeInsets.symmetric(vertical: toDouble());

  /// Creates [EdgeInsets.only] with the current value on the top side.
  EdgeInsets get pt => EdgeInsets.only(top: toDouble());

  /// Creates [EdgeInsets.only] with the current value on the bottom side.
  EdgeInsets get pb => EdgeInsets.only(bottom: toDouble());

  /// Creates [EdgeInsets.only] with the current value on the left side.
  EdgeInsets get pl => EdgeInsets.only(left: toDouble());

  /// Creates [EdgeInsets.only] with the current value on the right side.
  EdgeInsets get pr => EdgeInsets.only(right: toDouble());

  /// Creates [EdgeInsetsDirectional.only] with the current value on the start
  /// side (left in LTR, right in RTL).
  EdgeInsetsDirectional get ps => EdgeInsetsDirectional.only(start: toDouble());

  /// Creates [EdgeInsetsDirectional.only] with the current value on the end
  /// side (right in LTR, left in RTL).
  EdgeInsetsDirectional get pe => EdgeInsetsDirectional.only(end: toDouble());

  /// Creates [EdgeInsets.all] with the current value on all sides.
  ///
  /// Explicit alias of [p] for cases where a named form reads better.
  EdgeInsets get pAll => EdgeInsets.all(toDouble());

  /// Creates [EdgeInsets.symmetric] with the current value on the left and
  /// right sides.
  ///
  /// Explicit alias of [px].
  EdgeInsets get pLR => EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates [EdgeInsets.symmetric] with the current value on the top and
  /// bottom sides.
  ///
  /// Explicit alias of [py].
  EdgeInsets get pTB => EdgeInsets.symmetric(vertical: toDouble());

  /// Creates [EdgeInsets.zero], ignoring the receiver value.
  ///
  /// Provided on [num] for API symmetry with the other padding helpers.
  EdgeInsets get pZero => EdgeInsets.zero;
}

/// Extensions on [Widget] to easily wrap it in a [Padding] widget.
///
/// These helpers are thin wrappers around [Padding] for the most common
/// padding patterns. They return unscaled [EdgeInsets] and do not depend on
/// any responsive-scaling package.
///
/// ```dart
/// Text('Hello').pAll(16);
/// Text('Hello').pSymmetric(horizontal: 12, vertical: 6);
/// Text('Hello').pOnly(left: 10);
/// Text('Hello').pDirectional(start: 10);
/// Text('Hello').withPadding(16.px);
/// ```
extension PlayxWidgetPaddingExtensions on Widget {
  /// Wraps this widget in a [Padding] with [padding], e.g. `16.p` or
  /// `EdgeInsetsDirectional.only(start: 8)`.
  Padding withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);

  /// Wraps this widget in a [Padding] with [EdgeInsets.all] of [value].
  Padding pAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Wraps this widget in a [Padding] with [EdgeInsets.symmetric] using the
  /// given [horizontal] and [vertical] values.
  Padding pSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  /// Wraps this widget in a [Padding] with [EdgeInsets.only] using the given
  /// per-side values.
  Padding pOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  /// Wraps this widget in a [Padding] with [EdgeInsetsDirectional.only], so
  /// [start] and [end] follow the text direction (RTL aware).
  Padding pDirectional({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    ),
    child: this,
  );

  /// Wraps this widget in a [Padding] with [EdgeInsets.zero].
  ///
  /// Useful as a placeholder where a padding widget is expected but no
  /// padding is required.
  Padding pZero() => Padding(padding: EdgeInsets.zero, child: this);
}
