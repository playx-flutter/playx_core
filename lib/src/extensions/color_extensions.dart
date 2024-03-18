import 'dart:ui';

extension ColorExtensions on Color {
  /// Returns the color as a hex string with an optional leading hash sign.
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    if (includeAlpha) buffer.write(alpha.toRadixString(16).padLeft(2, '0'));
    buffer.write(red.toRadixString(16).padLeft(2, '0'));
    buffer.write(green.toRadixString(16).padLeft(2, '0'));
    buffer.write(blue.toRadixString(16).padLeft(2, '0'));

    return buffer.toString();
  }

  /// Returns a new color object by updating the alpha or red or green or blue value of the current color.
  Color copyWith({
    int? alpha,
    int? red,
    int? green,
    int? blue,
  }) {
    return Color.fromARGB(alpha ?? this.alpha, red ?? this.red,
        green ?? this.green, blue ?? this.blue);
  }
}
