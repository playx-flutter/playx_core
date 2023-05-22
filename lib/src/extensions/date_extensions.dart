import 'package:intl/intl.dart';

/// Extension functions to help operations on DateTime.
extension DateExtensions on DateTime {
  String toFormattedDate(
      {String format = 'dd-MM-yyyy hh:mm a', String? locale}) {
    final df = DateFormat(format, locale);
    return df.format(this);
  }
}
