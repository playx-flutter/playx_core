import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_convert.dart';

enum Color { red, green }

int parseInt(dynamic value) => int.parse(value as String);

void main() {
  group('bool conversion', () {
    test('numbers and strings', () {
      expect(toBoolOrNull(1), isTrue);
      expect(toBoolOrNull(0), isFalse);
      expect(toBoolOrNull(2), isNull);
      expect(toBoolOrNull('TRUE'), isTrue);
      expect(toBoolOrNull('false'), isFalse);
      expect(toBoolOrNull('1'), isTrue);
      expect(toBoolOrNull('0'), isFalse);
      expect(toBoolOrNull('2'), isNull);
      expect(toBoolOrNull('maybe'), isNull);
      expect(toBoolOrNull([]), isNull);
    });

    test('fallback and throwing variants', () {
      expect(toBoolOr('maybe', fallback: true), isTrue);
      expect(toBool('true'), isTrue);
      expect(() => toBool('maybe'), throwsFormatException);
    });
  });

  group('enum conversion', () {
    test('matches by name, ignoring case', () {
      expect(toEnumOrNull('RED', Color.values), Color.red);
      expect(toEnumOrNull('green', Color.values), Color.green);
      expect(toEnumOrNull(Color.green, Color.values), Color.green);
    });

    test('returns null for missing or unknown values', () {
      expect(toEnumOrNull(null, Color.values), isNull);
      expect(toEnumOrNull('blue', Color.values), isNull);
      expect(toEnumOrNull(const <int>[], Color.values), isNull);
    });

    test('fallback and throwing variants', () {
      expect(toEnumOr('blue', Color.values, fallback: Color.red), Color.red);
      expect(toEnum('green', Color.values), Color.green);
      expect(() => toEnum('blue', Color.values), throwsFormatException);
    });
  });

  group('Uri conversion', () {
    test('parses strings and keeps Uris', () {
      expect(
        toUriOrNull('https://example.com/a?b=1'),
        Uri.parse('https://example.com/a?b=1'),
      );
      expect(toUriOrNull(Uri.parse('/x')), Uri.parse('/x'));
      expect(toUriOrNull(null), isNull);
      expect(toUriOrNull(const <int>[]), isNull);
      expect(toUriOrNull('http://['), isNull);
    });

    test('fallback and throwing variants', () {
      final fallback = Uri.parse('https://fallback.dev');
      expect(toUriOr('http://[', fallback: fallback), fallback);
      expect(toUri('https://example.com'), Uri.parse('https://example.com'));
      expect(() => toUri(null), throwsFormatException);
    });
  });

  group('list conversion with converters', () {
    test('converts items with fromJson', () {
      expect(
        toListOrNull<int>(['1', '2'], fromJson: (e) => int.parse(e as String)),
        [1, 2],
      );
    });

    test('returns null when an item cannot be converted', () {
      expect(
        toListOrNull<int>(['1', 'x'], fromJson: (e) => int.parse(e as String)),
        isNull,
      );
      expect(toListOrNull<int>(['a', 'b']), isNull);
    });

    test('fallback and throwing variants', () {
      expect(toListOr<int>('x', fallback: [9]), [9]);
      expect(toList<int>([1, 2]), [1, 2]);
      expect(() => toList<int>('x'), throwsFormatException);
    });
  });

  group('generic conversion', () {
    test('toTOr and toT use fromJson', () {
      expect(toTOr<int>('5', fromJson: parseInt, fallback: 0), 5);
      expect(toTOr<int>('x', fromJson: parseInt, fallback: 0), 0);
      expect(toT<int>('7', fromJson: parseInt), 7);
      expect(() => toT<int>('x', fromJson: parseInt), throwsFormatException);
      expect(toTOrNull<int>(null, fromJson: parseInt), isNull);
      expect(toTOrNull<int>(3, fromJson: parseInt), 3);
    });
  });

  group('map conversion', () {
    test('empty maps convert, other maps need the right type', () {
      expect(toMapOrNull<String, int>(<dynamic, dynamic>{}), <String, int>{});
      expect(toMapOrNull<String, int>({'a': 1}), {'a': 1});
      expect(toMapOrNull<String, int>('x'), isNull);
    });

    test('fallback and throwing variants', () {
      expect(toMapOr<String, int>('x', fallback: {'z': 0}), {'z': 0});
      expect(toMap<String, int>({'a': 1}), {'a': 1});
      expect(() => toMap<String, int>('x'), throwsFormatException);
    });
  });
}
