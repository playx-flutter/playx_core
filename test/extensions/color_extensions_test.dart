import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/color_extensions.dart';

void main() {
  group('Color Extensions Test', () {
    group('toHex()', () {
      test('toHex returns the color as a hex string', () {
        const color = Color(0xFF00FF00);
        expect(color.toHex(), "#00ff00");
      });

      test(
          'toHex returns the color as a hex string without a leading hash sign',
          () {
        const color = Color(0xFF00FF00);
        expect(color.toHex(leadingHashSign: false), "00ff00");
      });

      test('toHex returns the color as a hex string with the alpha value', () {
        const color = Color(0x8800FF00);
        expect(color.toHex(includeAlpha: true), "#8800ff00");
      });
    });
  });

  group('Color Extensions Test', () {
    group('copyWith()', () {
      test(
          'copyWith returns a new color object by updating the alpha value of the current color',
          () {
        const color = Color.fromRGBO(0, 255, 0, 1);
        final newColor = color.copyWith(alpha: .1);
        expect(newColor.a, .1);
        expect(newColor, const Color.fromRGBO(0, 255, 0, .1));
      });

      test(
          'copyWith returns a new color object by updating the red value of the current color',
          () {
        const color = Color(0xFF00FF00);
        final newColor = color.copyWith(red: 1);
        expect(newColor.r, 1);
        expect(newColor, const Color.fromRGBO(255, 255, 0, 1));
      });

      test(
          'copyWith returns a new color object by updating the green value of the current color',
          () {
        const color = Color(0xFF0000FF);
        final newColor = color.copyWith(green: 1);
        expect(newColor.g, 1);

        expect(newColor, const Color.fromRGBO(0, 255, 255, 1));
      });

      test(
          'copyWith returns a new color object by updating the blue value of the current color',
          () {
        const color = Color(0xFF00FF00);
        final newColor = color.copyWith(blue: 1);
        expect(newColor.b, 1);
        expect(newColor, const Color.fromRGBO(0, 255, 255, 1));
      });
    });
  });
}
