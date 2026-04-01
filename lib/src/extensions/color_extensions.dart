import 'package:flutter/painting.dart';

extension PlayxColorExtensions on Color {
  /// Returns the color as a hex string with an optional leading hash sign.
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    
    final aInt = (a * 255).round();
    final rInt = (r * 255).round();
    final gInt = (g * 255).round();
    final bInt = (b * 255).round();

    if (includeAlpha) {
      buffer.write(aInt.toRadixString(16).padLeft(2, '0'));
    }
    buffer.write(rInt.toRadixString(16).padLeft(2, '0'));
    buffer.write(gInt.toRadixString(16).padLeft(2, '0'));
    buffer.write(bInt.toRadixString(16).padLeft(2, '0'));
    return buffer.toString();
  }

  /// Creates a [Color] from a hex string (e.g., '#RRGGBB' or 'RRGGBBAA').
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Returns a new color object by updating the alpha, red, green, or blue value of the current color.
  /// Uses [double] values from 0.0 to 1.0.
  Color copyWith({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    return withValues(
      alpha: alpha,
      red: red,
      green: green,
      blue: blue,
    );
  }

  /// Lightens the color by a given [amount] (0.0 to 1.0).
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Darkens the color by a given [amount] (0.0 to 1.0).
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Computes whether this color is considered dark, useful for dynamically picking text color overlay.
  bool get isDark {
    // Standard relative luminance check
    final relativeLuminance = computeLuminance();
    return relativeLuminance < 0.5;
  }
}
