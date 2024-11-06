import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_json_convert.dart';

void main() {
  group('asIntOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asIntOrNull(null, 'key'), null);
      expect(asIntOrNull({}, 'key'), null);
    });

    test('handles int, double, and valid string values', () {
      expect(asIntOrNull({'key': 1}, 'key'), 1);
      expect(asIntOrNull({'key': 1.0}, 'key'), 1);
      expect(asIntOrNull({'key': "123"}, 'key'), 123);
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asIntOrNull({'key': "invalid"}, 'key'), null);
      expect(asIntOrNull({'key': []}, 'key'), null);
    });
  });

  group('asDoubleOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asDoubleOrNull(null, 'key'), null);
      expect(asDoubleOrNull({}, 'key'), null);
    });

    test('handles double, int, and valid string values', () {
      expect(asDoubleOrNull({'key': 1.5}, 'key'), 1.5);
      expect(asDoubleOrNull({'key': 2}, 'key'), 2.0);
      expect(asDoubleOrNull({'key': "123.45"}, 'key'), 123.45);
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asDoubleOrNull({'key': "invalid"}, 'key'), null);
      expect(asDoubleOrNull({'key': []}, 'key'), null);
    });
  });

  group('asBoolOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asBoolOrNull(null, 'key'), null);
      expect(asBoolOrNull({}, 'key'), null);
    });

    test('handles bool values', () {
      expect(asBoolOrNull({'key': true}, 'key'), true);
      expect(asBoolOrNull({'key': false}, 'key'), false);
      expect(asBoolOrNull({'key': "true"}, 'key'), true);
      expect(asBoolOrNull({'key': 1}, 'key'), true);
      expect(asBoolOrNull({'key': 1.0}, 'key'), true);
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asBoolOrNull({'key': []}, 'key'), null);
      expect(
          asBoolOrNull({
            'key': "",
          }, 'key'),
          null);
      expect(
          asBoolOrNull({
            'key': 1.4,
          }, 'key'),
          null);
    });
  });

  group('asStringOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asStringOrNull(null, 'key'), null);
      expect(asStringOrNull({}, 'key'), null);
    });

    test('handles String values', () {
      expect(asStringOrNull({'key': 'hello'}, 'key'), 'hello');
      expect(asStringOrNull({'key': '123'}, 'key'), '123');
      expect(asStringOrNull({'key': 123}, 'key'), '123');
      expect(asStringOrNull({'key': 1.4}, 'key'), '1.4');
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asStringOrNull({'key': []}, 'key'), null);
      expect(asStringOrNull({'key': {}}, 'key'), null);
    });
  });

  group('asMapOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asMapOrNull(null, 'key'), null);
      expect(asMapOrNull({}, 'key'), null);
    });

    test('handles Map<String, dynamic> values', () {
      expect(
          asMapOrNull({
            'key': {'nestedKey': 'value'}
          }, 'key'),
          {'nestedKey': 'value'});
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asMapOrNull({'key': "string"}, 'key'), null);
      expect(asMapOrNull({'key': []}, 'key'), null);
    });
  });

  group('asListOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asListOrNull(null, 'key'), null);
      expect(asListOrNull({}, 'key'), null);
    });

    test('handles List values', () {
      expect(
          asListOrNull({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
      expect(
          asListOrNull({
            'key': ['a', 'b', 'c']
          }, 'key'),
          ['a', 'b', 'c']);
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(asListOrNull({'key': "string"}, 'key'), null);
      expect(asListOrNull({'key': {}}, 'key'), null);
    });
  });

  group('asListIntOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asListIntOrNull(null, 'key'), null);
      expect(asListIntOrNull({}, 'key'), null);
    });

    test('handles List<int> values', () {
      expect(
          asListIntOrNull({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
    });

    test('returns null for non-int values in the list', () {
      expect(
          asListIntOrNull({
            'key': ['1', '2', '3']
          }, 'key'),
          [1, 2, 3]);
      expect(
          asListIntOrNull({
            'key': ['a', 'b', 'c']
          }, 'key'),
          null);
    });
  });

  group('asListStringOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asListStringOrNull(null, 'key'), null);
      expect(asListStringOrNull({}, 'key'), null);
    });

    test('handles List<String> values', () {
      expect(
          asListStringOrNull({
            'key': ['apple', 'banana', 'cherry']
          }, 'key'),
          ['apple', 'banana', 'cherry']);
      expect(
          asListStringOrNull({
            'key': [1, 2, 3]
          }, 'key'),
          ['1', '2', '3']);
    });

    test('returns null for non-string values in the list', () {
      expect(
          asListStringOrNull({
            'key': ['a', 'b', 'c']
          }, 'key'),
          ['a', 'b', 'c']);
      expect(asListStringOrNull({'key': {}}, 'key'), null);
    });
  });

  group('asListOrNullT', () {
    test('returns null if json is null or key is missing', () {
      expect(asListOrNullT<int>(null, 'key', fromJson: (json) => json as int),
          null);
      expect(
          asListOrNullT<int>({}, 'key', fromJson: (json) => json as int), null);
    });

    test('handles List values and transforms using fromJson', () {
      expect(
          asListOrNullT<int>({
            'key': [1, 2, 3]
          }, 'key', fromJson: (json) => json as int),
          [1, 2, 3]);
      expect(
          asListOrNullT<String>({
            'key': [1, 2, 3]
          }, 'key', fromJson: (json) => json.toString()),
          ['1', '2', '3']);
    });

    test('returns null for invalid formats or unsupported types', () {
      expect(
          asListOrNullT<int>({
            'key': ['a', 'b', 'c']
          }, 'key', fromJson: (json) => json as int),
          null);
      expect(
          asListOrNullT<String>({
            'key': [1, 2, 3]
          }, 'key', fromJson: (json) => json.toString()),
          ['1', '2', '3']);
    });
  });

  group('asTOrNull', () {
    test('returns null if json is null or key is missing', () {
      expect(asTOrNull<int>(null, 'key'), null);
      expect(asTOrNull<int>({}, 'key'), null);
    });

    test('handles T values and transforms using fromJson', () {
      expect(asTOrNull<int>({'key': 123}, 'key'), 123);
      expect(asTOrNull<double>({'key': 123.45}, 'key'), 123.45);
      expect(asTOrNull<String>({'key': 'test'}, 'key'), 'test');
    });

    test('returns null for unsupported types or invalid formats', () {
      expect(asTOrNull<int>({'key': 'not an int'}, 'key'), null);

      expect(
          asTOrNull<List<int>>({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
    });
  });

  group('asIntOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asIntOr(null, 'key'), 0);
      expect(asIntOr({}, 'key'), 0);
    });

    test('handles int, double, and valid string values', () {
      expect(asIntOr({'key': 1}, 'key'), 1);
      expect(asIntOr({'key': 1.0}, 'key'), 1);
      expect(asIntOr({'key': "123"}, 'key'), 123);
    });

    test('returns fallback for invalid formats or unsupported types', () {
      expect(asIntOr({'key': "invalid"}, 'key'), 0);
      expect(asIntOr({'key': []}, 'key'), 0);
    });
  });

  group('asDoubleOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asDoubleOr(null, 'key'), 0.0);
      expect(asDoubleOr({}, 'key'), 0.0);
    });

    test('handles double, int, and valid string values', () {
      expect(asDoubleOr({'key': 1.5}, 'key'), 1.5);
      expect(asDoubleOr({'key': 2}, 'key'), 2.0);
      expect(asDoubleOr({'key': "3.14"}, 'key'), 3.14);
    });

    test('returns fallback for invalid formats or unsupported types', () {
      expect(asDoubleOr({'key': "invalid"}, 'key'), 0.0);
      expect(asDoubleOr({'key': []}, 'key'), 0.0);
    });
  });

  group('asBoolOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asBoolOr(null, 'key'), false);
      expect(asBoolOr({}, 'key'), false);
    });

    test('handles boolean and numeric representations', () {
      expect(asBoolOr({'key': true}, 'key'), true);
      expect(asBoolOr({'key': 1}, 'key'), true);
      expect(asBoolOr({'key': 0}, 'key'), false);
    });

    test('returns fallback for unsupported types', () {
      expect(asBoolOr({'key': "invalid"}, 'key'), false);
    });
  });

  group('asStringOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asStringOr(null, 'key'), '');
      expect(asStringOr({}, 'key'), '');
    });

    test('handles various types by converting to string', () {
      expect(asStringOr({'key': 123}, 'key'), '123');
      expect(asStringOr({'key': true}, 'key'), 'true');
      expect(asStringOr({'key': "test"}, 'key'), 'test');
    });

    test('returns fallback for unsupported types', () {
      expect(asStringOr({'key': []}, 'key'), '');
    });
  });

  group('asMapOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asMapOr(null, 'key'), {});
      expect(asMapOr({}, 'key'), {});
    });

    test('handles valid map structures', () {
      expect(
          asMapOr({
            'key': {'nested': 1}
          }, 'key'),
          {'nested': 1});
    });

    test('returns fallback for non-map types', () {
      expect(asMapOr({'key': 123}, 'key'), {});
      expect(asMapOr({'key': []}, 'key'), {});
    });
  });

  group('asListOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asListOr(null, 'key'), []);
      expect(asListOr({}, 'key'), []);
    });

    test('handles valid list structures', () {
      expect(
          asListOr({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
    });

    test('returns fallback for non-list types', () {
      expect(asListOr({'key': 123}, 'key'), []);
    });
  });

  group('asListTOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asListTOr<int>(null, 'key'), []);
      expect(asListTOr<int>({}, 'key'), []);
    });

    test('handles valid lists of generic type', () {
      expect(
          asListTOr<int>({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
      expect(
          asListTOr<String>({
            'key': ["a", "b"]
          }, 'key'),
          ["a", "b"]);
    });
  });

  group('asListFromJsonOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asListFromJsonOr(null, 'key', (json) => json), []);
    });

    test('transforms each element using fromJson function', () {
      expect(
          asListFromJsonOr({
            'key': [1, 2]
          }, 'key', (json) => json * 2),
          [2, 4]);
    });
  });

  group('asListIntOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asListIntOr(null, 'key'), []);
    });

    test('returns list of integers if valid', () {
      expect(
          asListIntOr({
            'key': [1, 2]
          }, 'key'),
          [1, 2]);
    });
  });

  group('asListStringOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asListStringOr(null, 'key'), []);
    });

    test('returns list of strings if valid', () {
      expect(
          asListStringOr({
            'key': ["a", "b"]
          }, 'key'),
          ["a", "b"]);
    });
  });

  group('asTOr', () {
    test('returns fallback if json is null or key is missing', () {
      expect(asTOr<int>(null, 'key', (json) => json, fallback: 0), 0);
    });

    test('returns transformed value if valid', () {
      expect(
          asTOr({'key': 123}, 'key', (json) => json.toString(), fallback: ''),
          '123');
    });
  });

  group('asInt', () {
    test('should return correct int value when valid value is provided', () {
      expect(asInt({'key': 123}, 'key'), 123);
    });

    test('should throw FormatException when value cannot be converted to int',
        () {
      expect(() => asInt({'key': 'not an int'}, 'key'), throwsFormatException);
      expect(() => asInt({'key': []}, 'key'), throwsFormatException);
    });
  });

  group('asDouble', () {
    test('should return correct double value when valid value is provided', () {
      expect(asDouble({'key': 123.45}, 'key'), 123.45);
    });

    test(
        'should throw FormatException when value cannot be converted to double',
        () {
      expect(() => asDouble({'key': 'not a double'}, 'key'),
          throwsFormatException);
      expect(() => asDouble({'key': []}, 'key'), throwsFormatException);
    });
  });

  group('asBool', () {
    test('should return correct bool value when valid value is provided', () {
      expect(asBool({'key': true}, 'key'), true);
      expect(asBool({'key': false}, 'key'), false);
    });

    test('should throw FormatException when value cannot be converted to bool',
        () {
      expect(() => asBool({'key': 'not a bool'}, 'key'), throwsFormatException);
      expect(() => asBool({'key': []}, 'key'), throwsFormatException);
    });
  });

  group('asString', () {
    test('should return correct String value when valid value is provided', () {
      expect(asString({'key': 'value'}, 'key'), 'value');
      expect(asString({'key': 123}, 'key'), '123');
    });

    test(
        'should throw FormatException when value cannot be converted to String',
        () {
      expect(() => asString({'key': []}, 'key'), throwsFormatException);
      expect(() => asString({'key': {}}, 'key'), throwsFormatException);
    });
  });

  group('asMap', () {
    test('should return correct Map value when valid value is provided', () {
      expect(
          asMap({
            'key': {'innerKey': 'innerValue'}
          }, 'key'),
          {'innerKey': 'innerValue'});
    });

    test('should throw FormatException when value cannot be converted to Map',
        () {
      expect(() => asMap({'key': 'not a map'}, 'key'), throwsFormatException);
      expect(() => asMap({'key': []}, 'key'), throwsFormatException);
    });
  });

  group('asList', () {
    test('should return correct List value when valid value is provided', () {
      expect(
          asList({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
    });

    test('should throw FormatException when value cannot be converted to List',
        () {
      expect(() => asList({'key': 'not a list'}, 'key'), throwsFormatException);
      expect(() => asList({'key': {}}, 'key'), throwsFormatException);
    });
  });

  group('asListT', () {
    test('should return correct List<T> value when valid value is provided',
        () {
      expect(
          asListT<int>({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
      expect(
          asListT<String>({
            'key': ['a', 'b', 'c']
          }, 'key'),
          ['a', 'b', 'c']);
    });

    test(
        'should throw FormatException when value cannot be converted to List<T>',
        () {
      expect(
          () => asListT<int>({
                'key': ['a', 'b', 'c']
              }, 'key'),
          throwsFormatException);
      expect(
          () => asListT<String>({
                'key': [1, 2, 3]
              }, 'key'),
          throwsFormatException);
    });
  });

  group('asListFromJson', () {
    test('should return correct List<T> from json conversion', () {
      expect(
          asListFromJson<int>({
            'key': [1, 2, 3]
          }, 'key', (json) => json as int),
          [1, 2, 3]);
    });

    test(
        'should throw FormatException when value cannot be converted to List<T> from json',
        () {
      expect(
          () => asListFromJson<int>({
                'key': ['a', 'b', 'c']
              }, 'key', (json) => int.parse(json)),
          throwsFormatException);
    });
  });

  group('asListInt', () {
    test('should return correct List<int> when valid value is provided', () {
      expect(
          asListInt({
            'key': [1, 2, 3]
          }, 'key'),
          [1, 2, 3]);
    });

    test(
        'should throw FormatException when value cannot be converted to List<int>',
        () {
      expect(
          () => asListInt({
                'key': ['a', 'b', 'c']
              }, 'key'),
          throwsFormatException);
    });
  });

  group('asListString', () {
    test('should return correct List<String> when valid value is provided', () {
      expect(
          asListString({
            'key': ['a', 'b', 'c']
          }, 'key'),
          ['a', 'b', 'c']);
    });

    test(
        'should throw FormatException when value cannot be converted to List<String>',
        () {
      expect(
          () => asListString({
                'key': [1, 2, 3]
              }, 'key'),
          throwsFormatException);
    });
  });

  group('asT', () {
    test('should return correct value when valid value is provided', () {
      expect(asT<int>({'key': 123}, (json) => json as int, 'key'), 123);
      expect(asT<String>({'key': 'test'}, (json) => json as String, 'key'),
          'test');
    });

    test('should throw FormatException when value cannot be converted to T',
        () {
      expect(
          () => asT<int>({'key': 'not an int'}, (json) => json as int, 'key'),
          throwsFormatException);
      expect(() => asT<String>({'key': 123}, (json) => json as String, 'key'),
          throwsFormatException);
    });
  });
}
