import 'package:flutter/painting.dart';

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

  group('PlayxColorExtensions', () {
    test('fromHex parses 6, 7 and 8 digit strings', () {
      expect(PlayxColorExtensions.fromHex('336699'), const Color(0xFF336699));
      expect(PlayxColorExtensions.fromHex('#336699'), const Color(0xFF336699));
      expect(
        PlayxColorExtensions.fromHex('#80336699'),
        const Color(0x80336699),
      );
    });

    test('toHex and fromHex round-trip', () {
      const color = Color(0xFF123456);
      expect(PlayxColorExtensions.fromHex(color.toHex()), color);
      expect(color.toHex(leadingHashSign: false), '123456');
      expect(color.toHex(includeAlpha: true), '#ff123456');
    });

    test('copyWith overrides the given channels', () {
      const color = Color(0xFF336699);
      expect(color.copyWith(alpha: 0.5).a, closeTo(0.5, 0.01));
      expect(color.copyWith(red: 1).r, 1);
      expect(color.copyWith(green: 0).g, 0);
      expect(color.copyWith(blue: 0).b, 0);
      expect(color.copyWith().toARGB32(), color.toARGB32());
    });

    test('lighten and darken change the lightness', () {
      const color = Color(0xFF808080);
      final base = HSLColor.fromColor(color).lightness;
      expect(
        HSLColor.fromColor(color.lighten(0.2)).lightness,
        closeTo(base + 0.2, 0.01),
      );
      expect(
        HSLColor.fromColor(color.darken(0.2)).lightness,
        closeTo(base - 0.2, 0.01),
      );
      expect(color.lighten(), isNot(color));
      expect(color.darken(), isNot(color));
    });

    test('lighten and darken clamp to white and black', () {
      expect(const Color(0xFFFFFFFF).lighten(1), const Color(0xFFFFFFFF));
      expect(const Color(0xFF000000).darken(1), const Color(0xFF000000));
    });

    test('isDark follows the luminance', () {
      expect(const Color(0xFF000000).isDark, isTrue);
      expect(const Color(0xFF112233).isDark, isTrue);
      expect(const Color(0xFFFFFFFF).isDark, isFalse);
      expect(const Color(0xFFFFEE88).isDark, isFalse);
    });
  });
}
