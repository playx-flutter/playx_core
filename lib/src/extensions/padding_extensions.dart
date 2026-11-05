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
/// final mixed = 0.pSymmetric(horizontal: 12, vertical: 6);
/// final leftOnly = 0.pOnly(left: 10);
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
  /// Provided on [num] for API symmetry with the other padding helpers so
  /// callers can write `0.pZero` or `null.pZero` style code consistently.
  EdgeInsets get pZero => EdgeInsets.zero;

  /// Creates [EdgeInsets.symmetric] with the given [horizontal] and [vertical]
  /// values.
  ///
  /// ```dart
  /// final padding = 0.pSymmetric(horizontal: 12, vertical: 6);
  /// ```
  EdgeInsets pSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Creates [EdgeInsets.only] with the given per-side values.
  ///
  /// ```dart
  /// final padding = 0.pOnly(left: 10, top: 4);
  /// ```
  EdgeInsets pOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
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
/// ```
extension PlayxWidgetPaddingExtensions on Widget {
  /// Wraps this widget in a [Padding] with [EdgeInsets.all] of [value].
  Widget pAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  /// Wraps this widget in a [Padding] with [EdgeInsets.symmetric] using the
  /// given [horizontal] and [vertical] values.
  Widget pSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Wraps this widget in a [Padding] with [EdgeInsets.only] using the given
  /// per-side values.
  Widget pOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  /// Wraps this widget in a [Padding] with [EdgeInsets.zero].
  ///
  /// Useful as a placeholder where a padding widget is expected but no
  /// padding is required.
  Widget pZero() => Padding(
        padding: EdgeInsets.zero,
        child: this,
      );
}
