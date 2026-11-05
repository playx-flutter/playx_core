import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/bool_extensions.dart';

void main() {
  group('Bool Extensions', () {
    group('toInt()', () {
      test('toInt() returns 1 if true', () {
        final value = true.toInt();
        expect(
          value,
          1,
        );
      });

      test('toInt() returns 0 if false', () {
        final value = false.toInt();
        expect(
          value,
          0,
        );
      });
    });

    group('toggle()', () {
      test('toggle() returns false if value is true', () {
        final value = true.toggle();
        expect(
          value,
          false,
        );
      });

      test('toggle() returns true if value is false', () {
        final value = false.toggle();
        expect(
          value,
          true,
        );
      });
    });
  });

  group('NullableBoolExtensions', () {
    test('isTrue is true only for an explicit true', () {
      bool? value;
      expect(value.isTrue, isFalse);
      value = false;
      expect(value.isTrue, isFalse);
      value = true;
      expect(value.isTrue, isTrue);
    });

    test('isFalse is true only for an explicit false', () {
      bool? value;
      expect(value.isFalse, isFalse);
      value = true;
      expect(value.isFalse, isFalse);
      value = false;
      expect(value.isFalse, isTrue);
    });
  });
}
