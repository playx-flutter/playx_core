import 'package:sprintf/sprintf.dart';

///Extension function on  string.
extension StringExtensions on String {
  ///Extension function to capitalize first character of a string.
  String get capitalizeFirstChar {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  ///Extension function to capitalize first character of each word of string.
  String get capitalizeFirstCharForEachWord {
    if (isEmpty) return this;
    return split(' ')
        .map((s) => s.isEmpty ? '' : s.capitalizeFirstChar)
        .join(' ');
  }

  /// Formats the string with the given [arguments].
  /// Example:
  /// ```dart
  /// final string = "Hello %s".format(["World"]);
  /// print(string); // prints Hello World
  /// ```
  String format(List arguments) => sprintf(this, arguments);

  /// Converts the string to boolean.
  bool toBoolean() {
    return toLowerCase() == "true" || toLowerCase() == "1";
  }

  /// Checks if string is Palindrome.
  bool get isPalindrome => reversed == this;

  /// Reverse a string
  String get reversed => split('').reversed.join();

  /// return string lines count
  int get linesCount => split('\n').length;

  ///  Replaces part of string after the first occurrence of given delimiter with the [replacement] string.
  ///  If the string does not contain the delimiter, returns [defaultValue] which defaults to the original string.
  String replaceAfter(
    String delimiter,
    String replacement, [
    String? defaultValue,
  ]) {
    final index = indexOf(delimiter);
    return (index == -1)
        ? defaultValue ?? this
        : replaceRange(index + 1, length, replacement);
  }

  /// Replaces part of string before the first occurrence of given delimiter with the [replacement] string.
  ///  If the string does not contain the delimiter, returns [missingDelimiterValue!] which defaults to the original string.
  String replaceBefore(
    String delimiter,
    String replacement, [
    String? defaultValue,
  ]) {
    final index = indexOf(delimiter);
    return (index == -1)
        ? defaultValue ?? this
        : replaceRange(0, index, replacement);
  }

  ///Returns `true` if at least one element matches the given [predicate].
  /// the [predicate] should have only one character
  // ignore: use_function_type_syntax_for_parameters
  bool anyChar(bool predicate(String element)) =>
      split('').any((s) => predicate(s));

  /// Returns last symbol of string or empty string if it's empty
  String get lastOrEmpty => lastOrNull ?? '';

  /// Returns first symbol of string or null string if it's empty
  String? get lastOrNull => isEmpty ? null : this[length - 1];

  /// Returns first symbol of string or null string if it's empty
  String? get firstOrNull => isEmpty ? null : this[0];
}
