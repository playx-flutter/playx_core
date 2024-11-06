import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/safe_convert.dart';

void main() {
  group('Test to Or null functions', () {
    // test toIntOrNull
    test('Test toIntOrNull', () {
      // Test null
      expect(toIntOrNull(null), null);
      // Test int values
      expect(toIntOrNull(1), 1);
      expect(toIntOrNull(0), 0);
      expect(toIntOrNull(-1), -1);

      // Test double values
      expect(toIntOrNull(1.0), 1);
      expect(toIntOrNull(0.0), 0);

      // Test bool values
      expect(toIntOrNull(true), 1);
      expect(toIntOrNull(false), 0);

      // Test string values
      expect(toIntOrNull("1"), 1);
      expect(toIntOrNull("1.0"), 1);
      expect(toIntOrNull("1.1"), 1);
      expect(toIntOrNull("1.9"), 1);
      expect(toIntOrNull("1.0.0"), null);
      expect(toIntOrNull(""), null);
      expect(toIntOrNull("0.0"), 0);
      expect(toIntOrNull("0.1"), 0);
      expect(toIntOrNull("-"), null);

      // Test other values
      expect(toIntOrNull([]), null);
      expect(toIntOrNull({}), null);
    });

    // test toDoubleOrNull
    test('Test toDoubleOrNull', () {
      // Test null
      expect(toDoubleOrNull(null), null);
      // Test int values
      expect(toDoubleOrNull(1), 1.0);
      expect(toDoubleOrNull(0), 0.0);
      expect(toDoubleOrNull(-1), -1.0);

      // Test double values
      expect(toDoubleOrNull(1.0), 1.0);
      expect(toDoubleOrNull(0.0), 0.0);

      // Test bool values
      expect(toDoubleOrNull(true), 1.0);
      expect(toDoubleOrNull(false), 0.0);

      // Test string values
      expect(toDoubleOrNull("1"), 1.0);
      expect(toDoubleOrNull("1.0"), 1.0);
      expect(toDoubleOrNull("1.1"), 1.1);
      expect(toDoubleOrNull("1.9"), 1.9);
      expect(toDoubleOrNull("1.0.0"), null);
      expect(toDoubleOrNull(""), null);
      expect(toDoubleOrNull("0.0"), 0.0);
      expect(toDoubleOrNull("0.1"), 0.1);
      expect(toDoubleOrNull("-"), null);

      // Test other values
      expect(toDoubleOrNull([]), null);
      expect(toDoubleOrNull({}), null);
    });

    // test toBoolOrNull
    test('Test toBoolOrNull', () {
      // Test null
      expect(toBoolOrNull(null), null);
      // Test int values
      expect(toBoolOrNull(1), true);
      expect(toBoolOrNull(0), false);
      expect(toBoolOrNull(-1), true);

      // Test double values
      expect(toBoolOrNull(1.0), true);
      expect(toBoolOrNull(0.0), false);

      // Test bool values
      expect(toBoolOrNull(true), true);
      expect(toBoolOrNull(false), false);

      // Test string values
      expect(toBoolOrNull("true"), true);
      expect(toBoolOrNull("false"), false);
      expect(toBoolOrNull("TRUE"), true);
      expect(toBoolOrNull("FALSE"), false);
      expect(toBoolOrNull("True"), true);
      expect(toBoolOrNull("False"), false);

      // Test string correct 1 or 0 values
      expect(toBoolOrNull("1"), true);
      expect(toBoolOrNull("1.0"), true);
      expect(toBoolOrNull("0.0"), false);

      // Test string incorrect values
      expect(toBoolOrNull("1.1"), null);
      expect(toBoolOrNull("1.9"), null);
      expect(toBoolOrNull("1.0.0"), null);
      expect(toBoolOrNull(""), null);
      expect(toBoolOrNull("0.1"), null);
      expect(toBoolOrNull("-"), null);

      // Test other values
      expect(toBoolOrNull([]), null);
      expect(toBoolOrNull({}), null);
    });

    // test toStringOrNull
    test('Test toStringOrNull', () {
      // Test null
      expect(toStringOrNull(null), null);
      // Test int values
      expect(toStringOrNull(1), "1");
      expect(toStringOrNull(0), "0");
      expect(toStringOrNull(-1), "-1");

      // Test double values
      expect(toStringOrNull(1.0), "1.0");
      expect(toStringOrNull(0.0), "0.0");

      // Test bool values
      expect(toStringOrNull(true), "true");
      expect(toStringOrNull(false), "false");

      // Test string values
      expect(toStringOrNull("test"), "test");
      expect(toStringOrNull("Test"), "Test");
      expect(toStringOrNull("TRUE"), "TRUE");

      // Test other values
      expect(toStringOrNull([]), null);
      expect(toStringOrNull({}), null);
    });

    // test toMapOrNull
    test('Test toMapOrNull', () {
      // Test null
      expect(toMapOrNull(null), null);
      // Test Map values
      expect(toMapOrNull({"key": "value"}), {"key": "value"});
      expect(toMapOrNull({}), {});
      expect(toMapOrNull({"key": 1}), {"key": 1});

      // Test other values
      expect(toMapOrNull([]), null);
      expect(toMapOrNull(1), null);
      expect(toMapOrNull("test"), null);
      expect(toMapOrNull(true), null);
    });

    test('Test toMapOrNullAny', () {
      // Test null
      expect(toMapOrNullAny(null), null);
      // Test Map values
      expect(toMapOrNullAny({"key": "value"}), {"key": "value"});
      expect(toMapOrNullAny({}), {});

      expect(toMapOrNullAny<String, int>({"key": 1}), {"key": 1});
      expect(toMapOrNullAny<String, int>({"key": 1.0}), null);
      expect(toMapOrNullAny<String, int>({"key": "1"}), null);

      // Test other values
      expect(toMapOrNullAny<String, int>([]), null);
      expect(toMapOrNullAny<String, int>(1), null);
      expect(toMapOrNullAny<String, int>("test"), null);
      expect(toMapOrNullAny<String, int>(true), null);
    });

    test('Test toListOrNull', () {
      // Test null
      expect(toListOrNull(null), null);
      // Test List values
      expect(toListOrNull([1, 2, 3]), [1, 2, 3]);
      expect(toListOrNull([]), []);
      expect(toListOrNull([1]), [1]);

      // Test other values
      expect(toListOrNull({}), null);
      expect(toListOrNull(1), null);
      expect(toListOrNull("test"), null);
      expect(toListOrNull(true), null);
    });

    test('Test toListOrNullT', () {
      // Test null
      expect(toListOrNullT<int>(null), null);
      // Test List values
      expect(toListOrNullT<int>([1, 2, 3]), [1, 2, 3]);
      expect(toListOrNullT<int>([]), []);
      expect(toListOrNullT<int>([1]), [1]);

      expect(toListOrNullT<String>([1]), null);
      expect(toListOrNullT<int>([1.0]), null);

      // Test other values
      expect(toListOrNullT<int>({}), null);
      expect(toListOrNullT<int>(1), null);
      expect(toListOrNullT<int>("test"), null);
      expect(toListOrNullT<int>(true), null);
    });

    test('Test toListOrNullFromJson', () {
      // Test null
      expect(toListOrNullFromJson(null, (json) => json), null);
      // Test List values
      expect(toListOrNullFromJson([1, 2, 3], (json) => json), [1, 2, 3]);

      expect(
          toListOrNullFromJson(['1.0', '4.5'], (value) => double.parse(value)),
          [1.0, 4.5]);

      expect(toListOrNullFromJson([], (json) => json), []);

      expect(toListOrNullFromJson([1], (json) => json), [1]);

      expect(
          toListOrNullFromJson(['true', 'false'], (value) => bool.parse(value)),
          [true, false]);

      // Test other values
      expect(toListOrNullFromJson({}, (json) => json), null);
      expect(toListOrNullFromJson(1, (json) => json), null);
      expect(toListOrNullFromJson("test", (json) => json), null);
      expect(toListOrNullFromJson(true, (json) => json), null);
    });

    test('Test toTOrNull', () {
      // Test null
      expect(toTOrNull<int>(null, fromJson: (json) => json), null);
      // Test List values
      expect(toTOrNull<int>(1, fromJson: (json) => json), 1);

      expect(toTOrNull<String>("test", fromJson: (json) => json), "test");

      expect(toTOrNull<double>(1.0, fromJson: (json) => json), 1.0);
      expect(toTOrNull<double>('1.0', fromJson: (value) => double.parse(value)),
          1.0);

      expect(toTOrNull<bool>(true, fromJson: (json) => json), true);
      expect(toTOrNull<bool>('true', fromJson: (value) => bool.parse(value)),
          true);

      // Test other values
      expect(toTOrNull<int>({}, fromJson: (json) => json), null);
      expect(toTOrNull<int>([], fromJson: (json) => json), null);
      expect(toTOrNull<int>(1, fromJson: (json) => json), 1);
    });
  });

  group('Test to Or functions', () {
    // test toIntOr
    test('Test toIntOr', () {
      // Test null
      expect(toIntOr(null, fallback: 1), 1);
      // Test int values
      expect(toIntOr(1, fallback: 0), 1);
      expect(toIntOr(0, fallback: 1), 0);
      expect(toIntOr(-1, fallback: 0), -1);

      // Test double values
      expect(toIntOr(1.0, fallback: 0), 1);
      expect(toIntOr(0.0, fallback: 0), 0);

      // Test bool values
      expect(toIntOr(true, fallback: 0), 1);
      expect(toIntOr(false, fallback: 0), 0);

      // Test string values
      expect(toIntOr("1", fallback: 0), 1);
      expect(toIntOr("1.0", fallback: 0), 1);
      expect(toIntOr("1.1", fallback: 0), 1);
      expect(toIntOr("1.9", fallback: 0), 1);
      expect(toIntOr("1.0.0", fallback: 2), 2);
      expect(toIntOr("", fallback: 1), 1);
      expect(toIntOr("0.0", fallback: 1), 1);
      expect(toIntOr("0.1", fallback: 1), 1);
      expect(toIntOr("-", fallback: 0), 0);

      // Test other values
      expect(toIntOr([], fallback: 0), 0);
      expect(toIntOr({}, fallback: 0), 0);
    });

    // test toDoubleOr
    test('Test toDoubleOr', () {
      // Test null
      expect(toDoubleOr(null, fallback: 1.0), 1.0);
      // Test int values
      expect(toDoubleOr(1, fallback: 0.0), 1.0);
      expect(toDoubleOr(0, fallback: 1.0), 0.0);
      expect(toDoubleOr(-1, fallback: 0.0), -1.0);

      // Test double values
      expect(toDoubleOr(1.0, fallback: 0.0), 1.0);
      expect(toDoubleOr(0.0, fallback: 1.0), 0.0);

      // Test bool values
      expect(toDoubleOr(true, fallback: 0.0), 1.0);
      expect(toDoubleOr(false, fallback: 1.0), 0.0);

      // Test string values
      expect(toDoubleOr("1", fallback: 0.0), 1.0);
      expect(toDoubleOr("1.0", fallback: 0.0), 1.0);
      expect(toDoubleOr("1.1", fallback: 0.0), 1.1);
      expect(toDoubleOr("1.9", fallback: 0.0), 1.9);
      expect(toDoubleOr("1.0.0", fallback: 2.0), 2.0);
      expect(toDoubleOr("", fallback: 1.0), 1.0);
      expect(toDoubleOr("0.0", fallback: 1.0), 1.0);
      expect(toDoubleOr("0.1", fallback: 1.0), 1.0);
      expect(toDoubleOr("-", fallback: 0.0), 0.0);

      // Test other values
      expect(toDoubleOr([], fallback: 0.0), 0.0);
      expect(toDoubleOr({}, fallback: 0.0), 0.0);
    });

    // test toBoolOr
    test('Test toBoolOr', () {
      // Test null
      expect(toBoolOr(null, fallback: true), true);
      // Test int values
      expect(toBoolOr(1, fallback: false), true);
      expect(toBoolOr(0, fallback: true), false);
      expect(toBoolOr(-1, fallback: true), true);

      // Test double values
      expect(toBoolOr(1.0, fallback: false), true);
      expect(toBoolOr(0.0, fallback: true), false);

      // Test bool values
      expect(toBoolOr(true, fallback: false), true);
      expect(toBoolOr(false, fallback: true), false);

      // Test string values
      expect(toBoolOr("true", fallback: false), true);
      expect(toBoolOr("false", fallback: true), false);
      expect(toBoolOr("TRUE", fallback: false), true);
      expect(toBoolOr("FALSE", fallback: true), false);
      expect(toBoolOr("True", fallback: false), true);
      expect(toBoolOr("False", fallback: true), false);

      // Test string correct 1 or 0 values
      expect(toBoolOr("1", fallback: false), true);
      expect(toBoolOr("1.0", fallback: false), true);
      expect(toBoolOr("0.0", fallback: true), false);

      // Test string incorrect values
      expect(toBoolOr("1.1", fallback: true), true);
      expect(toBoolOr("1.9", fallback: false), false);
      expect(toBoolOr("1.0.0", fallback: true), true);
      expect(toBoolOr("", fallback: false), false);
      expect(toBoolOr("0.1", fallback: true), true);
      expect(toBoolOr("-", fallback: false), false);

      // Test other values
      expect(toBoolOr([], fallback: true), true);
      expect(toBoolOr({}, fallback: false), false);
    });

    // test toStringOr
    test('Test toStringOr', () {
      // Test null
      expect(toStringOr(null, fallback: "1"), "1");
      // Test int values
      expect(toStringOr(1, fallback: "0"), "1");
      expect(toStringOr(0, fallback: "1"), "0");
      expect(toStringOr(-1, fallback: "0"), "-1");

      // Test double values
      expect(toStringOr(1.0, fallback: "0"), "1.0");
      expect(toStringOr(0.0, fallback: "0"), "0.0");

      // Test bool values
      expect(toStringOr(true, fallback: "0"), "true");
      expect(toStringOr(false, fallback: "1"), "false");

      // Test string values
      expect(toStringOr("test", fallback: "1"), "test");
      expect(toStringOr("Test", fallback: "1"), "Test");
      expect(toStringOr("TRUE", fallback: "1"), "TRUE");

      // Test other values
      expect(toStringOr([], fallback: "1"), "1");
      expect(toStringOr({}, fallback: "1"), "1");
    });

    // test toMapOr
    test('Test toMapOr', () {
      // Test null
      expect(toMapOr(null, fallback: {"key": "value"}), {"key": "value"});
      // Test Map values
      expect(toMapOr({"key": "value"}, fallback: {}), {"key": "value"});
      expect(toMapOr({}, fallback: {"key": 1}), {"key": 1});

      // Test other values
      expect(toMapOr([], fallback: {}), {});
      expect(toMapOr(1, fallback: {}), {});
      expect(toMapOr("test", fallback: {}), {});
      expect(toMapOr(true, fallback: {}), {});
    });

    // test toListOr
    test('Test toListOr', () {
      // Test null
      expect(toListOr(null, fallback: [1, 2, 3]), [1, 2, 3]);
      // Test List values
      expect(toListOr([1, 2, 3], fallback: []), [1, 2, 3]);
      expect(toListOr([], fallback: [1]), [1]);

      // Test other values
      expect(toListOr({}, fallback: []), []);
      expect(toListOr(1, fallback: []), []);
      expect(toListOr("test", fallback: []), []);
      expect(toListOr(true, fallback: []), []);
    });

    // test toListOrT
    test('Test toListOrT', () {
      // Test null
      expect(toListTOr<int>(null, fallback: [1, 2, 3]), [1, 2, 3]);
      // Test List values
      expect(toListTOr<int>([1, 2, 3], fallback: []), [1, 2, 3]);
      expect(toListTOr<int>([], fallback: [1]), [1]);

      expect(toListTOr<String>([1], fallback: []), []);
      expect(toListTOr<int>([1.0], fallback: []), []);
      // Test other values
      expect(toListTOr<int>({}, fallback: []), []);
      expect(toListTOr<int>(1, fallback: []), []);
      expect(toListTOr<int>("test", fallback: []), []);
      expect(toListTOr<int>(true, fallback: []), []);
    });

    // test toListOrFromJson
    test('Test toListOrFromJson', () {
      // Test null
      expect(toListFromJsonOr(null, (json) => json, fallback: [1, 2, 3]),
          [1, 2, 3]);
      // Test List values
      expect(
          toListFromJsonOr([1, 2, 3], (json) => json, fallback: []), [1, 2, 3]);
      expect(toListFromJsonOr([], (json) => json, fallback: [1]), [1]);

      expect(
          toListFromJsonOr(['1.0', '4.5'], (value) => double.parse(value),
              fallback: []),
          [1.0, 4.5]);

      // Test other values
      expect(toListFromJsonOr({}, (json) => json, fallback: []), []);
      expect(toListFromJsonOr(1, (json) => json, fallback: []), []);
      expect(toListFromJsonOr("test", (json) => json, fallback: []), []);
      expect(toListFromJsonOr(true, (json) => json, fallback: []), []);
    });

    // test toTOr
    test('Test toTOr', () {
      // Test null
      expect(toTOr<int>(null, fromJson: (json) => json, fallback: 1), 1);
      // Test List values
      expect(toTOr<int>(1, fromJson: (json) => json, fallback: 0), 1);
      expect(toTOr<String>("test", fromJson: (json) => json, fallback: "1"),
          "test");

      expect(toTOr<double>(1.0, fromJson: (json) => json, fallback: 0.0), 1.0);
      expect(
          toTOr<double>('1.0',
              fromJson: (value) => double.parse(value), fallback: 0.0),
          1.0);

      expect(
          toTOr<bool>(true, fromJson: (json) => json, fallback: false), true);
      expect(
          toTOr<bool>('true',
              fromJson: (value) => bool.parse(value), fallback: false),
          true);

      // Test other values
      expect(toTOr<int>({}, fromJson: (json) => json, fallback: 0), 0);
      expect(toTOr<int>([], fromJson: (json) => json, fallback: 0), 0);
      expect(toTOr<int>(1, fromJson: (json) => json, fallback: 1), 1);
    });
  });

  group('Test to functions with error', () {
    // test toIntOr
    test('Test toInt with error', () {
      // Test null
      expect(() => toInt(null), throwsA(isA<FormatException>()));
      // Test int values
      expect(toInt(1), 1);
      expect(toInt(0), 0);
      expect(toInt(-1), -1);

      // Test double values
      expect(toInt(1.0), 1);
      expect(toInt(0.0), 0);

      // Test bool values
      expect(toInt(true), 1);
      expect(toInt(false), 0);

      // Test string values
      expect(toInt("1"), 1);
      expect(toInt("1.0"), 1);
      expect(toInt("1.1"), 1);
      expect(toInt("1.9"), 1);
      expect(() => toInt("1.0.0"), throwsA(isA<FormatException>()));
      expect(() => toInt(""), throwsA(isA<FormatException>()));
      expect(toInt("0.0"), 0);
      expect(toInt("0.1"), 0);
      expect(() => toInt("-"), throwsA(isA<FormatException>()));

      // Test other values
      expect(() => toInt([]), throwsA(isA<FormatException>()));
      expect(() => toInt({}), throwsA(isA<FormatException>()));
    });

    // test toDoubleOr
    test('Test toDouble with error', () {
      // Test null
      expect(() => toDouble(null), throwsA(isA<FormatException>()));
      // Test int values
      expect(toDouble(1), 1.0);
      expect(toDouble(0), 0.0);
      expect(toDouble(-1), -1.0);

      // Test double values
      expect(toDouble(1.0), 1.0);
      expect(toDouble(0.0), 0.0);

      // Test bool values
      expect(toDouble(true), 1.0);
      expect(toDouble(false), 0.0);

      // Test string values
      expect(toDouble("1"), 1.0);
      expect(toDouble("1.0"), 1.0);
      expect(toDouble("1.1"), 1.1);
      expect(toDouble("1.9"), 1.9);
      expect(() => toDouble("1.0.0"), throwsA(isA<FormatException>()));
      expect(() => toDouble(""), throwsA(isA<FormatException>()));
      expect(toDouble("0.0"), 0.0);
      expect(toDouble("0.1"), 0.1);
      expect(() => toDouble("-"), throwsA(isA<FormatException>()));

      // Test other values
      expect(() => toDouble([]), throwsA(isA<FormatException>()));
      expect(() => toDouble({}), throwsA(isA<FormatException>()));
    });

    // test toBoolOr
    test('Test toBool with error', () {
      // Test null
      expect(() => toBool(null), throwsA(isA<FormatException>()));
      // Test int values
      expect(toBool(1), true);
      expect(toBool(0), false);
      expect(toBool(-1), true);

      // Test double values
      expect(toBool(1.0), true);
      expect(toBool(0.0), false);

      // Test bool values
      expect(toBool(true), true);
      expect(toBool(false), false);

      // Test string values
      expect(toBool("true"), true);
      expect(toBool("false"), false);
      expect(toBool("TRUE"), true);
      expect(toBool("FALSE"), false);
      expect(toBool("True"), true);
      expect(toBool("False"), false);

      // Test string correct 1 or 0 values
      expect(toBool("1"), true);
      expect(toBool("1.0"), true);
      expect(toBool("0.0"), false);

      // Test string incorrect values
      expect(() => toBool("1.1"), throwsA(isA<FormatException>()));
      expect(() => toBool("1.9"), throwsA(isA<FormatException>()));
      expect(() => toBool("1.0.0"), throwsA(isA<FormatException>()));
      expect(() => toBool(""), throwsA(isA<FormatException>()));
      expect(() => toBool("0.1"), throwsA(isA<FormatException>()));
      expect(() => toBool("-"), throwsA(isA<FormatException>()));

      // Test other values
      expect(() => toBool([]), throwsA(isA<FormatException>()));
      expect(() => toBool({}), throwsA(isA<FormatException>()));
    });

    // test toMapOr
    test('Test toMap with error', () {
      // Test null
      expect(() => toMap(null), throwsA(isA<FormatException>()));
      // Test Map values
      expect(toMap({"key": "value"}), {"key": "value"});
      expect(toMap({}), {});
      expect(toMap({"key": 1}), {"key": 1});

      // Test other values
      expect(() => toMap([]), throwsA(isA<FormatException>()));
      expect(() => toMap(1), throwsA(isA<FormatException>()));
      expect(() => toMap("test"), throwsA(isA<FormatException>()));
      expect(() => toMap(true), throwsA(isA<FormatException>()));
    });

    // test toListOr
    test('Test toList with error', () {
      // Test null
      expect(() => toList(null), throwsA(isA<FormatException>()));
      // Test List values
      expect(toList([1, 2, 3]), [1, 2, 3]);
      expect(toList([]), []);
      expect(toList([1]), [1]);

      // Test other values
      expect(() => toList({}), throwsA(isA<FormatException>()));
      expect(() => toList(1), throwsA(isA<FormatException>()));
      expect(() => toList("test"), throwsA(isA<FormatException>()));
      expect(() => toList(true), throwsA(isA<FormatException>()));
    });

    // test toListOrT
    test('Test toListT with error', () {
      // Test null
      expect(() => toListT<int>(null), throwsA(isA<FormatException>()));
      // Test List values
      expect(toListT<int>([1, 2, 3]), [1, 2, 3]);
      expect(toListT<int>([]), []);
      expect(toListT<int>([1]), [1]);

      expect(() => toListT<String>([1]), throwsA(isA<FormatException>()));
      expect(() => toListT<int>([1.0]), throwsA(isA<FormatException>()));

      // Test other values
      expect(() => toListT<int>({}), throwsA(isA<FormatException>()));
      expect(() => toListT<int>(1), throwsA(isA<FormatException>()));
      expect(() => toListT<int>("test"), throwsA(isA<FormatException>()));
      expect(() => toListT<int>(true), throwsA(isA<FormatException>()));
    });

    // test toListOrFromJson
    test('Test toListFromJson with error', () {
      // Test null
      expect(() => toListFromJson(null, (json) => json),
          throwsA(isA<FormatException>()));
      // Test List values
      expect(toListFromJson([1, 2, 3], (json) => json), [1, 2, 3]);

      expect(toListFromJson(['1.0', '4.5'], (value) => double.parse(value)),
          [1.0, 4.5]);

      expect(toListFromJson([], (json) => json), []);

      expect(toListFromJson([1], (json) => json), [1]);

      expect(toListFromJson(['true', 'false'], (value) => bool.parse(value)),
          [true, false]);

      // Test other values
      expect(() => toListFromJson({}, (json) => json),
          throwsA(isA<FormatException>()));
      expect(() => toListFromJson(1, (json) => json),
          throwsA(isA<FormatException>()));
      expect(() => toListFromJson("test", (json) => json),
          throwsA(isA<FormatException>()));
      expect(() => toListFromJson(true, (json) => json),
          throwsA(isA<FormatException>()));
    });

    // test toTOr
    test('Test toT with error', () {
      // Test null
      expect(() => toT<int>(null, fromJson: (json) => json),
          throwsA(isA<FormatException>()));
      // Test List values
      expect(toT<int>(1, fromJson: (json) => json), 1);

      expect(toT<String>("test", fromJson: (json) => json), "test");

      expect(toT<double>(1.0, fromJson: (json) => json), 1.0);
      expect(toT<double>('1.0', fromJson: (value) => double.parse(value)), 1.0);

      expect(toT<bool>(true, fromJson: (json) => json), true);
      expect(toT<bool>('true', fromJson: (value) => bool.parse(value)), true);

      // Test other values
      expect(() => toT<int>({}, fromJson: (json) => json),
          throwsA(isA<FormatException>()));
      expect(() => toT<int>([], fromJson: (json) => json),
          throwsA(isA<FormatException>()));
      expect(toT<int>(1, fromJson: (json) => json), 1);
    });
  });
}
