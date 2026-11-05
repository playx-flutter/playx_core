import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  group('num', () {
    test('radius and border radius', () {
      expect(12.radius, const Radius.circular(12));
      expect(4.ellipticalRadius(8), const Radius.elliptical(4, 8));
      expect(12.borderRadius, BorderRadius.circular(12));
      expect(
        12.borderRadiusTop,
        const BorderRadius.vertical(top: Radius.circular(12)),
      );
      expect(
        12.borderRadiusBottom,
        const BorderRadius.vertical(bottom: Radius.circular(12)),
      );
      expect(
        12.borderRadiusLeft,
        const BorderRadius.horizontal(left: Radius.circular(12)),
      );
      expect(
        12.borderRadiusRight,
        const BorderRadius.horizontal(right: Radius.circular(12)),
      );
    });

    test('directional border radius follows the text direction', () {
      expect(
        12.borderRadiusStart.resolve(TextDirection.ltr),
        const BorderRadius.horizontal(left: Radius.circular(12)),
      );
      expect(
        12.borderRadiusStart.resolve(TextDirection.rtl),
        const BorderRadius.horizontal(right: Radius.circular(12)),
      );
      expect(
        12.borderRadiusEnd.resolve(TextDirection.ltr),
        const BorderRadius.horizontal(right: Radius.circular(12)),
      );
    });

    test('shape, border and border side', () {
      expect(
        8.roundedShape,
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
      expect(
        2.borderSide(Colors.red),
        const BorderSide(color: Colors.red, width: 2),
      );
      expect(2.border(Colors.red), Border.all(color: Colors.red, width: 2));
      expect(1.border(), Border.all(color: const Color(0xFF000000)));
    });
  });

  group('Color', () {
    test('border and border side', () {
      expect(Colors.blue.borderSide(), const BorderSide(color: Colors.blue));
      expect(
        Colors.blue.border(width: 3),
        Border.all(color: Colors.blue, width: 3),
      );
    });
  });

  group('Widget', () {
    test('clipRounded and clipBorderRadius', () {
      const child = SizedBox();
      expect(child.clipRounded(10).borderRadius, BorderRadius.circular(10));
      expect(
        child.clipBorderRadius(16.borderRadiusTop).borderRadius,
        16.borderRadiusTop,
      );
      expect(child.clipRounded(10).child, same(child));
    });

    test('bordered', () {
      const child = SizedBox();
      final rounded =
          child.bordered(color: Colors.grey, width: 2, radius: 8).decoration
              as BoxDecoration;
      expect(rounded.border, Border.all(color: Colors.grey, width: 2));
      expect(rounded.borderRadius, BorderRadius.circular(8));

      final square = child.bordered().decoration as BoxDecoration;
      expect(square.borderRadius, isNull);
    });
  });
}
