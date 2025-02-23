import 'dart:ui';

extension PlayxColorExtensions on Color {
  /// Returns the color as a hex string with an optional leading hash sign.
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    if (includeAlpha) {
      buffer.write(alpha.toRadixString(16).padLeft(2, '0'));
    }
    buffer.write(red.toRadixString(16).padLeft(2, '0'));
    buffer.write(green.toRadixString(16).padLeft(2, '0'));
    buffer.write(blue.toRadixString(16).padLeft(2, '0'));
    return buffer.toString();
  }

  /// Returns a new color object by updating the alpha, red, green, or blue value of the current color.
  Color copyWith({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    return Color.fromRGBO(
      (red ?? r * 255).toInt(),
      (green ?? g * 255).toInt(),
      (blue ?? b * 255).toInt(),
      (alpha ?? a),
    );
  }
}
