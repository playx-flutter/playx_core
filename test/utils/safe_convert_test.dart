import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_convert.dart';

void main() {
  group('Int conversion', () {
    test('toIntOrNull', () {
      expect(toIntOrNull(null), null);
      expect(toIntOrNull(42), 42);
      expect(toIntOrNull(42.9), 42);
      expect(toIntOrNull('42'), 42);
      expect(toIntOrNull('42.5'), 42);
      expect(toIntOrNull('not a number'), null);
      expect(toIntOrNull(true), 1);
      expect(toIntOrNull(false), 0);
      expect(toIntOrNull([]), null);
    });

    test('toIntOr', () {
      expect(toIntOr('bad', fallback: 7), 7);
      expect(toIntOr(5, fallback: 7), 5);
    });

    test('toInt', () {
      expect(() => toInt('bad'), throwsFormatException);
      expect(toInt('123'), 123);
    });
  });

  group('Double conversion', () {
    test('toDoubleOrNull', () {
      expect(toDoubleOrNull(null), null);
      expect(toDoubleOrNull(1), 1.0);
      expect(toDoubleOrNull('1.5'), 1.5);
      expect(toDoubleOrNull('bad'), null);
      expect(toDoubleOrNull(true), 1.0);
    });

    test('toDoubleOr', () {
      expect(toDoubleOr('bad', fallback: 2.2), 2.2);
      expect(toDoubleOr(3.3, fallback: 2.2), 3.3);
    });

    test('toDouble', () {
      expect(() => toDouble('bad'), throwsFormatException);
      expect(toDouble('2.5'), 2.5);
    });
  });

  group('Num conversion', () {
    test('toNumOrNull', () {
      expect(toNumOrNull(null), null);
      expect(toNumOrNull(1), 1);
      expect(toNumOrNull(1.5), 1.5);
      expect(toNumOrNull('1'), 1);
      expect(toNumOrNull('1.5'), 1.5);
      expect(toNumOrNull('bad'), null);
    });

    test('toNumOr', () {
      expect(toNumOr('bad', fallback: 2.2), 2.2);
      expect(toNumOr(3.3, fallback: 2.2), 3.3);
    });

    test('toNum', () {
      expect(() => toNum('bad'), throwsFormatException);
      expect(toNum('2.5'), 2.5);
    });
  });

  group('Bool conversion', () {
    test('toBoolOrNull', () {
      expect(toBoolOrNull(null), null);
      expect(toBoolOrNull(true), true);
      expect(toBoolOrNull(1), true);
      expect(toBoolOrNull('false'), false);
      expect(toBoolOrNull('bad'), null);
    });

    test('toBoolOr', () {
      expect(toBoolOr('bad', fallback: true), true);
      expect(toBoolOr('true', fallback: false), true);
    });

    test('toBool', () {
      expect(() => toBool('bad'), throwsFormatException);
      expect(toBool('false'), false);
    });
  });

  group('String conversion', () {
    test('toStringOrNull', () {
      expect(toStringOrNull(null), null);
      expect(toStringOrNull(123), '123');
      expect(toStringOrNull(true), 'true');
      expect(toStringOrNull('abc'), 'abc');
      expect(toStringOrNull([]), null);
    });

    test('toStringOr', () {
      expect(toStringOr(null, fallback: 'fallback'), 'fallback');
      expect(toStringOr(1, fallback: 'fallback'), '1');
    });

    test('toString', () {
      expect(() => toString({}), throwsFormatException);
      expect(toString(5), '5');
    });
  });

  group('DateTime conversion', () {
    test('toDateTimeOrNull', () {
      expect(toDateTimeOrNull(null), null);
      expect(toDateTimeOrNull('2020-01-01T00:00:00Z'),
          DateTime.parse('2020-01-01T00:00:00Z'));
      expect(toDateTimeOrNull(1577836800000),
          DateTime.fromMillisecondsSinceEpoch(1577836800000));
      expect(toDateTimeOrNull('bad'), null);
    });

    test('toDateTimeOr', () {
      final fallback = DateTime(2000);
      expect(toDateTimeOr('bad', fallback: fallback), fallback);
    });

    test('toDateTime', () {
      expect(() => toDateTime('bad'), throwsFormatException);
      expect(toDateTime('2020-01-01T00:00:00Z'),
          DateTime.parse('2020-01-01T00:00:00Z'));
    });
  });

  // local date time
  group('Local DateTime conversion', () {
    test('toLocalDateTimeOrNull', () {
      expect(toLocalDateTimeOrNull(null), null);
      expect(toLocalDateTimeOrNull('2020-01-01T00:00:00Z'),
          DateTime.parse('2020-01-01T00:00:00Z').toLocal());
      expect(toLocalDateTimeOrNull(1577836800000),
          DateTime.fromMillisecondsSinceEpoch(1577836800000).toLocal());
      expect(toLocalDateTimeOrNull('bad'), null);
    });

    test('toLocalDateTimeOr', () {
      final fallback = DateTime(2000);
      expect(toLocalDateTimeOr('bad', fallback: fallback), fallback);
    });

    test('toLocalDateTime', () {
      expect(() => toLocalDateTime('bad'), throwsFormatException);
      expect(toLocalDateTime('2020-01-01T00:00:00Z'),
          DateTime.parse('2020-01-01T00:00:00Z').toLocal());
    });
  });

  group('Map conversion', () {
    test('toMapOrNull', () {
      expect(toMapOrNull(null), null);
      expect(toMapOrNull({'a': 1}), {'a': 1});
      expect(toMapOrNull([]), null);
    });

    test('toMapOr', () {
      expect(toMapOr('bad', fallback: {'x': 1}), {'x': 1});
    });

    test('toMap', () {
      expect(() => toMap('bad'), throwsFormatException);
      expect(toMap({'a': 1}), {'a': 1});
    });
  });

  group('List conversion', () {
    test('toListOrNull', () {
      expect(toListOrNull(null), null);
      expect(toListOrNull([1, 2]), [1, 2]);
      expect(toListOrNull('bad'), null);
    });

    test('toListOr', () {
      expect(toListOr('bad', fallback: [1]), [1]);
    });

    test('toList', () {
      expect(() => toList('bad'), throwsFormatException);
      expect(toList([1]), [1]);
    });
  });

  group('Generic conversion', () {
    test('toTOrNull', () {
      expect(toTOrNull<int>('5', fromJson: (v) => int.tryParse(v) ?? 0), 5);
      expect(toTOrNull<int>('bad', fromJson: (v) => int.tryParse(v) ?? 0), 0);
    });

    test('toTOr', () {
      expect(
          toTOr<int>('bad', fromJson: (v) => int.tryParse(v) ?? 0, fallback: 7),
          0);
    });

    test('toT', () {
      expect(() => toT<int>('bad', fromJson: (v) => throw FormatException()),
          throwsFormatException);
      expect(toT<int>('5', fromJson: (v) => int.parse(v)), 5);
    });
  });
}
