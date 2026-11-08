import 'package:flutter/widgets.dart';

const _defaultBorderColor = Color(0xFF000000);

/// Extensions on [num] to create [Radius], [BorderRadius], borders and shapes.
///
/// Values are unscaled. Apps using responsive scaling should scale the number
/// first, e.g. `12.r.borderRadius` with `flutter_screenutil`.
///
/// ```dart
/// final radius = 12.radius;            // Radius.circular(12)
/// final corners = 12.borderRadius;     // BorderRadius.circular(12)
/// final top = 16.borderRadiusTop;      // top corners only
/// final shape = 8.roundedShape;        // RoundedRectangleBorder
/// final border = 1.border(Colors.grey); // Border.all(width: 1)
/// ```
extension PlayxNumBorderExtensions on num {
  /// [Radius.circular] with this value.
  Radius get radius => Radius.circular(toDouble());

  /// [Radius.elliptical] with this value as `x` and [y].
  Radius ellipticalRadius(num y) => Radius.elliptical(toDouble(), y.toDouble());

  /// [BorderRadius.circular] with this value on all corners.
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());

  /// [BorderRadius] with this value on the top corners only.
  BorderRadius get borderRadiusTop => BorderRadius.vertical(top: radius);

  /// [BorderRadius] with this value on the bottom corners only.
  BorderRadius get borderRadiusBottom => BorderRadius.vertical(bottom: radius);

  /// [BorderRadius] with this value on the left corners only.
  BorderRadius get borderRadiusLeft => BorderRadius.horizontal(left: radius);

  /// [BorderRadius] with this value on the right corners only.
  BorderRadius get borderRadiusRight => BorderRadius.horizontal(right: radius);

  /// [BorderRadiusDirectional] with this value on the start corners only
  /// (left in LTR, right in RTL).
  BorderRadiusDirectional get borderRadiusStart =>
      BorderRadiusDirectional.horizontal(start: radius);

  /// [BorderRadiusDirectional] with this value on the end corners only
  /// (right in LTR, left in RTL).
  BorderRadiusDirectional get borderRadiusEnd =>
      BorderRadiusDirectional.horizontal(end: radius);

  /// [RoundedRectangleBorder] with this corner radius, e.g. for `Card.shape`
  /// or button shapes.
  RoundedRectangleBorder get roundedShape =>
      RoundedRectangleBorder(borderRadius: borderRadius);

  /// [BorderSide] of this width.
  BorderSide borderSide([Color color = _defaultBorderColor]) =>
      BorderSide(color: color, width: toDouble());

  /// [Border.all] of this width.
  Border border([Color color = _defaultBorderColor]) =>
      Border.all(color: color, width: toDouble());
}

/// Extensions on [Color] to create borders.
///
/// ```dart
/// Colors.grey.border(width: 2);   // Border.all
/// Colors.grey.borderSide();       // BorderSide with width 1
/// ```
extension PlayxColorBorderExtensions on Color {
  /// [BorderSide] in this color.
  BorderSide borderSide({double width = 1}) =>
      BorderSide(color: this, width: width);

  /// [Border.all] in this color.
  Border border({double width = 1}) => Border.all(color: this, width: width);
}

/// Extensions on [Widget] to round or outline it.
///
/// ```dart
/// Image.network(url).clipRounded(12);
/// Text('Hi').bordered(color: Colors.grey, radius: 8);
/// ```
extension PlayxWidgetBorderExtensions on Widget {
  /// Clips this widget with rounded corners of [radius].
  ClipRRect clipRounded(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  /// Clips this widget with [borderRadius], e.g. `16.borderRadiusTop`.
  ClipRRect clipBorderRadius(BorderRadiusGeometry borderRadius) =>
      ClipRRect(borderRadius: borderRadius, child: this);

  /// Draws a border of [width] and [color] around this widget, with rounded
  /// corners when [radius] is greater than zero.
  DecoratedBox bordered({
    Color color = _defaultBorderColor,
    double width = 1,
    double radius = 0,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width),
      borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
    ),
    child: this,
  );
}
