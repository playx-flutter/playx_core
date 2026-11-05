import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/string_extensions.dart';

void main() {
  group('String Extensions Test', () {
    test(
        'capitalizeFirstChar returns the string with the first character capitalized',
        () {
      final string = "hello".capitalizeFirstChar;
      expect(string, "Hello");
    });

    test(
        'capitalizeFirstCharForEachWord returns the string with the first character of each word capitalized',
        () {
      final string = "hello world".capitalizeFirstCharForEachWord;
      expect(string, "Hello World");
    });

    test('format returns the formatted string', () {
      final string = "Hello %s".format(["World"]);
      expect(string, "Hello World");
    });

    test('toBoolean returns the boolean value of the string', () {
      const string = "true";
      expect(string.toBoolean(), true);
    });

    test('isPalindrome returns true if the string is a palindrome', () {
      const string = "madam";
      expect(string.isPalindrome, true);
    });

    test('reversed returns the reversed string', () {
      const string = "hello";
      expect(string.reversed, "olleh");
    });

    test('linesCount returns the number of lines in the string', () {
      const string = "hello\nworld";
      expect(string.linesCount, 2);
    });

    test(
        'anyChar returns true if at least one character satisfies the predicate',
        () {
      const string = "hello";
      expect(string.anyChar((s) => s == "h"), true);
    });

    test('lastOrEmpty returns the last character of the string', () {
      const string = "hello";
      expect(string.lastOrEmpty, "o");
    });

    test('lastOrNull returns the last character of the string', () {
      const string = "hello";
      expect(string.lastOrNull, "o");
    });

    test('firstOrNull returns the first character of the string', () {
      const string = "hello";
      expect(string.firstOrNull, "h");
    });

    test(
        'replaceAfter returns the string after replacing the part of the string after the first occurrence of the delimiter with the replacement string',
        () {
      const string = "hello-world";
      expect(string.replaceAfter("-", "test"), "hello-test");
    });

    test(
        'replaceBefore returns the string after replacing the part of the string before the first occurrence of the delimiter with the replacement string',
        () {
      const string = "hello world";
      expect(string.replaceBefore(" ", "test"), "test world");
    });
  });

  group('parsing and checks', () {
    test('firstOrNull and lastOrNull', () {
      expect('abc'.firstOrNull, 'a');
      expect('abc'.lastOrNull, 'c');
      expect(''.firstOrNull, isNull);
      expect(''.lastOrNull, isNull);
      expect(''.lastOrEmpty, '');
      expect('abc'.lastOrEmpty, 'c');
    });

    test('toIntOrNull and toDoubleOrNull', () {
      expect('42'.toIntOrNull(), 42);
      expect('4.2'.toIntOrNull(), isNull);
      expect('4.2'.toDoubleOrNull(), 4.2);
      expect('abc'.toDoubleOrNull(), isNull);
    });

    test('isNumeric', () {
      expect('42'.isNumeric, isTrue);
      expect('-4.2'.isNumeric, isTrue);
      expect('4a'.isNumeric, isFalse);
      expect(''.isNumeric, isFalse);
    });

    test('containsIgnoreCase and equalsIgnoreCase', () {
      expect('Hello World'.containsIgnoreCase('WORLD'), isTrue);
      expect('Hello'.containsIgnoreCase('xyz'), isFalse);
      expect('Hello'.equalsIgnoreCase('hELLO'), isTrue);
      expect('Hello'.equalsIgnoreCase('Hell'), isFalse);
    });

    test('removeWhitespace and removeHtmlTags', () {
      expect(' a \t b\nc '.removeWhitespace(), 'abc');
      expect('<p>Hello <b>you</b></p>'.removeHtmlTags(), 'Hello you');
    });

    test('toSlug', () {
      expect('Hello, World! 2024'.toSlug(), 'hello-world-2024');
      expect('--A  B--'.toSlug(), 'a-b');
    });

    test('isValidEmail and isValidUrl', () {
      expect('jane.doe@example.com'.isValidEmail, isTrue);
      expect('not-an-email'.isValidEmail, isFalse);
      expect('https://example.com/path?q=1'.isValidUrl, isTrue);
      expect('example.com'.isValidUrl, isTrue);
      expect('not a url'.isValidUrl, isFalse);
    });

    test('limit truncates with a suffix', () {
      expect('Hello World'.limit(5), 'Hello...');
      expect('Hello World'.limit(5, suffix: '…'), 'Hello…');
      expect('Hello'.limit(5), 'Hello');
      expect('Hi'.limit(5), 'Hi');
    });
  });

  group('NullableStringExtensions', () {
    test('isNullOrEmpty and isNotNullOrEmpty', () {
      String? value;
      expect(value.isNullOrEmpty, isTrue);
      expect(value.isNotNullOrEmpty, isFalse);
      value = '';
      expect(value.isNullOrEmpty, isTrue);
      value = 'x';
      expect(value.isNullOrEmpty, isFalse);
      expect(value.isNotNullOrEmpty, isTrue);
    });

    test('ifNullOrEmpty returns the fallback when empty', () {
      String? value;
      expect(value.ifNullOrEmpty('fallback'), 'fallback');
      expect(''.ifNullOrEmpty('fallback'), 'fallback');
      expect('x'.ifNullOrEmpty('fallback'), 'x');
    });
  });

  group('capitalizedInitialChar', () {
    test('returns the first character uppercased', () {
      expect('jane doe'.capitalizedInitialChar, 'J');
      expect('  élodie'.capitalizedInitialChar, 'É');
      expect('محمد'.capitalizedInitialChar, 'م');
    });

    test('keeps emojis and combined characters whole', () {
      expect('👩‍💻 dev'.capitalizedInitialChar, '👩‍💻');
      expect('étienne'.capitalizedInitialChar, 'É');
    });

    test('is empty for empty or blank strings', () {
      expect(''.capitalizedInitialChar, '');
      expect('   '.capitalizedInitialChar, '');
    });
  });

  group('toPrettyJson', () {
    test('indents valid JSON', () {
      expect(
        '{"a":1,"b":[true]}'.toPrettyJson(),
        '{\n  "a": 1,\n  "b": [\n    true\n  ]\n}',
      );
      expect('{"a":1}'.toPrettyJson(indent: '    '), '{\n    "a": 1\n}');
    });

    test('returns invalid JSON unchanged', () {
      expect('not json'.toPrettyJson(), 'not json');
    });
  });
}
