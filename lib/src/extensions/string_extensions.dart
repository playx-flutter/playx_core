import 'package:sprintf/sprintf.dart';

///Extension function on  string.
extension StringExtensions on String {
  ///Extension function to capitalize first character of a string.
  String capitalizeFirstChar() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  ///Extension function to capitalize first character of each word of string.
  String capitalizeFirstCharForEachWord() {
    return split(' ')
        .map((s) => s.isEmpty ? '' : s.capitalizeFirstChar())
        .join(' ');
  }

  String format(List arguments) => sprintf(this, arguments);
}
