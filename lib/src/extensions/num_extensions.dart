import 'dart:math';

import 'package:intl/intl.dart';

/// Extension functions to help operations on numbers.
extension NumExtensions on num {
  ///Extension function to round number to certain number
  double roundToPrecision({int numbersToRoundTo = 2}) {
    final fac = pow(10, numbersToRoundTo).toInt();
    return (this * fac).round() / fac;
  }

  /// Extension function to format number to currency number
  /// ```
  /// 1000000 => will be converted to 1000,000.00
  /// ```
  String toFormattedCurrencyNumber(
      {String format = "#,##0.00", String locale = 'en'}) {
    final numberFormat = NumberFormat(format, locale);
    return numberFormat.format(this);
  }

  /// Extension function to format number to  String
  String toFormattedNumber({required String format, String locale = 'en'}) {
    final numberFormat = NumberFormat(format, locale);
    return numberFormat.format(this);
  }
}
