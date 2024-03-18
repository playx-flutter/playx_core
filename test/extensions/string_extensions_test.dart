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
}
