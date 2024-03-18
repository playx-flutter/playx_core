import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/color_utils.dart';

void main() {
  group('ColorUtils', () {
    group('fromHex', () {
      test('fromHex returns a color from hex string', () {
        final color = ColorUtils.fromHex(hex: '#00FF00');
        expect(color, const Color(0xFF00FF00));
      });

      test('fromHex returns a color from hex string without leading hash sign',
          () {
        final color = ColorUtils.fromHex(
          hex: '00FF00',
        );
        expect(color, const Color(0xFF00FF00));
      });
      test(
          'fromHex returns a color with an optional alpha value from hex string',
          () {
        final color = ColorUtils.fromHex(hex: '#00FF00', alpha: 128);
        expect(color, const Color(0x8000FF00));
      });
    });

    test('fromRGB returns a color from RGB values with an optional alpha value',
        () {
      final color = ColorUtils.fromRGB(red: 0, green: 255, blue: 0);
      expect(color, const Color(0xFF00FF00));
    });
  });
}
