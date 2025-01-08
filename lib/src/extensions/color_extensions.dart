import 'dart:ui';

extension PlayxColorExtensions on Color {
  /// Returns the color as a hex string with an optional leading hash sign.
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    if (includeAlpha)
      buffer.write((a * 255).toInt().toRadixString(16).padLeft(2, '0'));
    buffer.write((r * 255).toInt().toRadixString(16).padLeft(2, '0'));
    buffer.write((g * 255).toInt().toRadixString(16).padLeft(2, '0'));
    buffer.write((b * 255).toInt().toRadixString(16).padLeft(2, '0'));
    return buffer.toString();
  }

  /// Returns a new color object by updating the alpha or red or green or blue value of the current color.
  Color copyWith({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    return Color.from(
        alpha: alpha ?? a, red: red ?? r, green: green ?? g, blue: blue ?? b);
  }
}
