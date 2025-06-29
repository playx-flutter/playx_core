import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_json_convert.dart';

void main() {
  group('Int conversion', () {
    test('asIntOrNull', () {
      expect(asIntOrNull(null, 'k'), null);
      expect(asIntOrNull({}, 'k'), null);
      expect(asIntOrNull({'k': 1}, 'k'), 1);
      expect(asIntOrNull({'k': 1.9}, 'k'), 1);
      expect(asIntOrNull({'k': '2'}, 'k'), 2);
      expect(asIntOrNull({'k': 'bad'}, 'k'), null);
    });

    test('asIntOr', () {
      expect(asIntOr({'k': 'bad'}, 'k', fallback: 7), 7);
      expect(asIntOr({'k': 5}, 'k', fallback: 7), 5);
    });

    test('asInt', () {
      expect(() => asInt({'k': 'bad'}, 'k'), throwsFormatException);
      expect(asInt({'k': '123'}, 'k'), 123);
    });
  });

  group('Double conversion', () {
    test('asDoubleOrNull', () {
      expect(asDoubleOrNull(null, 'k'), null);
      expect(asDoubleOrNull({'k': 1}, 'k'), 1.0);
      expect(asDoubleOrNull({'k': '1.5'}, 'k'), 1.5);
      expect(asDoubleOrNull({'k': 'bad'}, 'k'), null);
    });

    test('asDoubleOr', () {
      expect(asDoubleOr({'k': 'bad'}, 'k', fallback: 2.2), 2.2);
      expect(asDoubleOr({'k': 3.3}, 'k', fallback: 2.2), 3.3);
    });

    test('asDouble', () {
      expect(() => asDouble({'k': 'bad'}, 'k'), throwsFormatException);
      expect(asDouble({'k': '2.5'}, 'k'), 2.5);
    });
  });

  group('Bool conversion', () {
    test('asBoolOrNull', () {
      expect(asBoolOrNull(null, 'k'), null);
      expect(asBoolOrNull({'k': true}, 'k'), true);
      expect(asBoolOrNull({'k': 1}, 'k'), true);
      expect(asBoolOrNull({'k': 'false'}, 'k'), false);
      expect(asBoolOrNull({'k': 'bad'}, 'k'), null);
    });

    test('asBoolOr', () {
      expect(asBoolOr({'k': 'bad'}, 'k', fallback: true), true);
      expect(asBoolOr({'k': 'true'}, 'k', fallback: false), true);
    });

    test('asBool', () {
      expect(() => asBool({'k': 'bad'}, 'k'), throwsFormatException);
      expect(asBool({'k': 'false'}, 'k'), false);
    });
  });

  group('String conversion', () {
    test('asStringOrNull', () {
      expect(asStringOrNull(null, 'k'), null);
      expect(asStringOrNull({'k': 123}, 'k'), '123');
      expect(asStringOrNull({'k': true}, 'k'), 'true');
      expect(asStringOrNull({'k': 'abc'}, 'k'), 'abc');
      expect(asStringOrNull({'k': []}, 'k'), null);
    });

    test('asStringOr', () {
      expect(asStringOr({'k': null}, 'k', fallback: 'fallback'), 'fallback');
      expect(asStringOr({'k': 1}, 'k', fallback: 'fallback'), '1');
    });

    test('asString', () {
      expect(() => asString({'k': {}}, 'k'), throwsFormatException);
      expect(asString({'k': 5}, 'k'), '5');
    });
  });

  group('DateTime conversion', () {
    test('asDateTimeOrNull', () {
      expect(asDateTimeOrNull(null, 'k'), null);
      expect(
        asDateTimeOrNull({'k': '2020-01-01T00:00:00Z'}, 'k'),
        DateTime.parse('2020-01-01T00:00:00Z'),
      );
      expect(
        asDateTimeOrNull({'k': 1577836800000}, 'k'),
        DateTime.fromMillisecondsSinceEpoch(1577836800000),
      );
      expect(asDateTimeOrNull({'k': 'bad'}, 'k'), null);
    });

    test('asDateTimeOr', () {
      final fallback = DateTime(2000);
      expect(asDateTimeOr({'k': 'bad'}, 'k', fallback: fallback), fallback);
    });

    test('asDateTime', () {
      expect(() => asDateTime({'k': 'bad'}, 'k'), throwsFormatException);
      expect(
        asDateTime({'k': '2020-01-01T00:00:00Z'}, 'k'),
        DateTime.parse('2020-01-01T00:00:00Z'),
      );
    });

    test('asLocalDateTimeOrNull', () {
      final utc = DateTime.utc(2020, 1, 1);
      final local = asLocalDateTimeOrNull({'k': utc.toIso8601String()}, 'k');
      expect(local?.isUtc, false);
      expect(local?.toUtc(), utc);
    });

    test('asLocalDateTime', () {
      final utc = DateTime.utc(2020, 1, 1);
      final local = asLocalDateTime({'k': utc.toIso8601String()}, 'k');
      expect(local.isUtc, false);
      expect(local.toUtc(), utc);
      expect(() => asLocalDateTime({'k': 'bad'}, 'k'), throwsFormatException);
    });

    test('asLocalDateTimeOr', () {
      final fallback = DateTime(2000);
      expect(
        asLocalDateTimeOr({'k': 'bad'}, 'k', fallback: fallback),
        fallback,
      );
      expect(
        asLocalDateTimeOr({}, 'k', fallback: fallback),
        fallback,
      );
    });
  });

  group('Map conversion', () {
    test('asMapOrNull', () {
      expect(asMapOrNull(null, 'k'), null);
      expect(
          asMapOrNull({
            'k': {'a': 1}
          }, 'k'),
          {'a': 1});
      expect(asMapOrNull({'k': []}, 'k'), null);
    });

    test('asMapOr', () {
      expect(asMapOr({'k': 'bad'}, 'k', fallback: {'x': 1}), {'x': 1});
    });

    test('asMap', () {
      expect(() => asMap({'k': 'bad'}, 'k'), throwsFormatException);
      expect(
          asMap({
            'k': {'a': 1}
          }, 'k'),
          {'a': 1});
    });
  });

  group('List conversion', () {
    test('asListOrNull', () {
      expect(asListOrNull(null, 'k'), null);
      expect(
          asListOrNull({
            'k': [1, 2]
          }, 'k'),
          [1, 2]);
      expect(asListOrNull({'k': 'bad'}, 'k'), null);
    });

    test('asListOr', () {
      expect(asListOr({'k': 'bad'}, 'k', fallback: [1]), [1]);
    });

    test('asList', () {
      expect(() => asList({'k': 'bad'}, 'k'), throwsFormatException);
      expect(
          asList({
            'k': [1]
          }, 'k'),
          [1]);
    });
  });

  group('List<int> conversion', () {
    test('asListIntOrNull', () {
      expect(asListIntOrNull(null, 'k'), null);
      expect(
          asListIntOrNull({
            'k': [1, 2]
          }, 'k'),
          [1, 2]);
      expect(
          asListIntOrNull({
            'k': ['1', '2']
          }, 'k'),
          [1, 2]);
      expect(
          asListIntOrNull({
            'k': ['a', 'b']
          }, 'k'),
          null);
    });

    test('asListIntOr', () {
      expect(asListIntOr({'k': 'bad'}, 'k', fallback: [1]), [1]);
    });

    test('asListInt', () {
      expect(
          () => asListInt({
                'k': ['a', 'b']
              }, 'k'),
          throwsFormatException);
      expect(
          asListInt({
            'k': [1, 2]
          }, 'k'),
          [1, 2]);
    });
  });

  group('List<String> conversion', () {
    test('asListStringOrNull', () {
      expect(asListStringOrNull(null, 'k'), null);
      expect(
          asListStringOrNull({
            'k': ['a', 'b']
          }, 'k'),
          ['a', 'b']);
      expect(
          asListStringOrNull({
            'k': [1, 2]
          }, 'k'),
          ['1', '2']);
      expect(
          asListStringOrNull({
            'k': [{}]
          }, 'k'),
          null);
    });

    test('asListStringOr', () {
      expect(asListStringOr({'k': 'bad'}, 'k', fallback: ['a']), ['a']);
    });

    test('asListString', () {
      expect(
          asListString({
            'k': [1, 2]
          }, 'k'),
          ['1', '2']);
      expect(
          asListString({
            'k': ['a', 'b']
          }, 'k'),
          ['a', 'b']);
      expect(
          () => asListString({
                'k': [{}]
              }, 'k'),
          throwsFormatException);
    });
  });

  group('Generic conversion', () {
    test('asTOrNull', () {
      expect(
          asTOrNull<int>({'k': '5'}, 'k',
              fromJson: (v) => int.tryParse(v) ?? 0),
          5);
      expect(
          asTOrNull<int>({'k': 'bad'}, 'k',
              fromJson: (v) => int.tryParse(v) ?? 0),
          0);
    });
  });

  group('Generic List conversion', () {
    test('asListOrNull generic', () {
      expect(
        asListOrNull<int>({
          'k': ['1', '2']
        }, 'k', fromJson: (v) => int.tryParse(v) ?? 0),
        [1, 2],
      );
    });
  });
}
