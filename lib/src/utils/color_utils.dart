import 'dart:ui';

/// A utility class that provides color related helper methods.
class ColorUtils {
  /// Returns a color with an optional alpha value from hex string
  /// alpha (defaults to 255).
  static Color fromHex({required String hex, int alpha = 255}) {
    return Color(
        int.parse(hex.replaceFirst('#', ''), radix: 16) + ((alpha << 24)));
  }

  /// Returns a color from RGB values with an optional alpha value
  static Color fromRGB(
      {required int red,
      required int green,
      required int blue,
      int alpha = 255}) {
    return Color.fromARGB(alpha, red, green, blue);
  }
}
