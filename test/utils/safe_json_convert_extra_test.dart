import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_json_convert.dart';

enum Mode { light, dark }

void main() {
  group('key lookup', () {
    final json = {
      'user': {
        'name': 'Jane',
        'tags': ['a', 'b'],
        'friends': [
          {'name': 'John'},
        ],
      },
      'a.b': 'literal dotted key',
    };

    test('reads nested keys with dot notation', () {
      expect(asStringOrNull(json, 'user.name'), 'Jane');
      expect(asStringOrNull(json, 'user.tags.1'), 'b');
      expect(asStringOrNull(json, 'user.friends.0.name'), 'John');
    });

    test('prefers a literal key containing a dot', () {
      expect(asStringOrNull(json, 'a.b'), 'literal dotted key');
    });

    test('returns null for missing paths and bad indexes', () {
      expect(asStringOrNull(json, 'user.age'), isNull);
      expect(asStringOrNull(json, 'user.tags.5'), isNull);
      expect(asStringOrNull(json, 'user.tags.-1'), isNull);
      expect(asStringOrNull(json, 'user.tags.x'), isNull);
      expect(asStringOrNull(json, 'user.name.first'), isNull);
      expect(asStringOrNull(null, 'user.name'), isNull);
      expect(asStringOrNull('not a map', 'user'), isNull);
      expect(asStringOrNull(json, 'missing'), isNull);
    });
  });

  group('num conversion', () {
    final json = {'a': '1.5', 'b': 2, 'c': 'x'};

    test('asNumOrNull, asNumOr and asNum', () {
      expect(asNumOrNull(json, 'a'), 1.5);
      expect(asNumOrNull(json, 'b'), 2);
      expect(asNumOrNull(json, 'c'), isNull);
      expect(asNumOr(json, 'c', fallback: 9), 9);
      expect(asNumOr(json, 'a'), 1.5);
      expect(asNum(json, 'b'), 2);
      expect(() => asNum(json, 'c'), throwsFormatException);
    });
  });

  group('enum conversion', () {
    final json = {'mode': 'DARK', 'bad': 'blue'};

    test('asEnumOrNull, asEnumOr and asEnum', () {
      expect(asEnumOrNull(json, 'mode', Mode.values), Mode.dark);
      expect(asEnumOrNull(json, 'bad', Mode.values), isNull);
      expect(
        asEnumOr(json, 'bad', Mode.values, fallback: Mode.light),
        Mode.light,
      );
      expect(asEnum(json, 'mode', Mode.values), Mode.dark);
      expect(() => asEnum(json, 'bad', Mode.values), throwsFormatException);
    });
  });

  group('Uri conversion', () {
    final json = {'url': 'https://example.com/a', 'bad': 'http://['};

    test('asUriOrNull, asUriOr and asUri', () {
      final fallback = Uri.parse('https://fallback.dev');
      expect(asUriOrNull(json, 'url'), Uri.parse('https://example.com/a'));
      expect(asUriOrNull(json, 'bad'), isNull);
      expect(asUriOr(json, 'bad', fallback: fallback), fallback);
      expect(asUri(json, 'url'), Uri.parse('https://example.com/a'));
      expect(() => asUri(json, 'bad'), throwsFormatException);
    });
  });

  group('Map conversion', () {
    final json = {
      'm': {'a': 1},
      'x': 'text',
    };

    test('asMapOrNull, asMapOr and asMap', () {
      expect(asMapOrNull<String, int>(json, 'm'), {'a': 1});
      expect(asMapOrNull<String, int>(json, 'x'), isNull);
      expect(asMapOr<String, int>(json, 'x', fallback: {'z': 0}), {'z': 0});
      expect(asMap<String, int>(json, 'm'), {'a': 1});
      expect(() => asMap<String, int>(json, 'x'), throwsFormatException);
    });
  });

  group('lists', () {
    final json = {
      'ints': [1, '2', 3.0],
      'badInts': [1, 'x'],
      'strings': ['a', 1, true],
      'mixed': [{}, 'a'],
      'text': 'x',
    };

    test('asListIntOrNull, asListIntOr and asListInt', () {
      expect(asListIntOrNull(json, 'ints'), [1, 2, 3]);
      expect(asListIntOrNull(json, 'badInts'), isNull);
      expect(asListIntOrNull(json, 'text'), isNull);
      expect(asListIntOr(json, 'text', fallback: [0]), [0]);
      expect(asListInt(json, 'ints'), [1, 2, 3]);
      expect(() => asListInt(json, 'text'), throwsFormatException);
    });

    test('asListStringOrNull, asListStringOr and asListString', () {
      expect(asListStringOrNull(json, 'strings'), ['a', '1', 'true']);
      expect(asListStringOrNull(json, 'mixed'), isNull);
      expect(asListStringOr(json, 'text', fallback: ['z']), ['z']);
      expect(asListString(json, 'strings'), ['a', '1', 'true']);
      expect(() => asListString(json, 'mixed'), throwsFormatException);
    });

    test('asListOrNull, asListOr and asList', () {
      expect(asListOrNull<int>(json, 'ints'), isNull); // 3.0 is not an int
      expect(asListOrNull<dynamic>(json, 'mixed'), [{}, 'a']);
      expect(asListOr<int>(json, 'text', fallback: [0]), [0]);
      expect(asList<dynamic>(json, 'mixed'), [{}, 'a']);
      expect(() => asList<int>(json, 'text'), throwsFormatException);
    });
  });

  group('generic conversion', () {
    final json = {
      'int': '5',
      'double': 1,
      'string': 7,
      'bool': 'true',
      'list': [1],
      'map': {'a': 1},
      'date': '2024-05-01',
      'uri': 'https://example.com',
    };

    test('asTOrNull converts to common types', () {
      expect(asTOrNull<int>(json, 'int'), 5);
      expect(asTOrNull<double>(json, 'double'), 1.0);
      expect(asTOrNull<String>(json, 'string'), '7');
      expect(asTOrNull<bool>(json, 'bool'), isTrue);
      expect(asTOrNull<List>(json, 'list'), [1]);
      expect(asTOrNull<Map<String, dynamic>>(json, 'map'), {'a': 1});
      expect(asTOrNull<DateTime>(json, 'date'), DateTime(2024, 5, 1));
      expect(asTOrNull<Uri>(json, 'uri'), Uri.parse('https://example.com'));
    });

    test('asTOrNull uses fromJson and returns null on errors', () {
      expect(
        asTOrNull<int>(
          json,
          'int',
          fromJson: (v) => int.parse(v as String) * 2,
        ),
        10,
      );
      expect(
        asTOrNull<int>(json, 'bool', fromJson: (v) => int.parse(v as String)),
        isNull,
      );
      expect(asTOrNull<int>(json, 'missing'), isNull);
      expect(asTOrNull<Mode>(json, 'int'), isNull);
    });

    test('asTOr and asT', () {
      expect(asTOr<int>(json, 'missing', fallback: 3), 3);
      expect(asTOr<int>(json, 'int', fallback: 3), 5);
      expect(asT<int>(json, 'int'), 5);
      expect(() => asT<int>(json, 'missing'), throwsFormatException);
    });
  });

  group('date and time', () {
    test('asDateTime variants', () {
      final json = {'at': '2024-05-01T10:00:00Z', 'bad': 'x'};
      final fallback = DateTime(2000);
      expect(asDateTimeOrNull(json, 'at'), DateTime.utc(2024, 5, 1, 10));
      expect(asDateTimeOr(json, 'bad', fallback: fallback), fallback);
      expect(asDateTime(json, 'at'), DateTime.utc(2024, 5, 1, 10));
      expect(() => asDateTime(json, 'bad'), throwsFormatException);
    });

    test('asLocalDateTime variants', () {
      final json = {'at': '2024-05-01T10:00:00Z', 'bad': 'x'};
      final fallback = DateTime(2000);
      expect(
        asLocalDateTimeOrNull(json, 'at')!.toUtc(),
        DateTime.utc(2024, 5, 1, 10),
      );
      expect(asLocalDateTimeOr(json, 'bad', fallback: fallback), fallback);
      expect(asLocalDateTime(json, 'at').toUtc(), DateTime.utc(2024, 5, 1, 10));
      expect(() => asLocalDateTime(json, 'bad'), throwsFormatException);
    });
  });
}
