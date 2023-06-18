String twoDigits(int n) => n.toString().padLeft(2, "0");

/// Extension functions to convert duration to formatted hours, minutes, seconds and milliseconds.
extension DurationExtensions on Duration {
  /// Extension function to convert duration to formatted hours.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:8);
  ///   print(duration.toHours()); // prints 08
  ///``
  String toHours() {
    return twoDigits(inHours);
  }

  /// Extension function to convert duration to formatted minutes.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(minutes:8);
  ///   print(duration.toMinutes()); // prints 08
  ///``
  String toMinutes() {
    return twoDigits(inMinutes);
  }

  /// Extension function to convert duration to formatted seconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(seconds:8);
  ///   print(duration.toSeconds()); // prints 08
  ///``
  String toSeconds() {
    return twoDigits(inSeconds);
  }

  /// Extension function to convert duration to formatted millieSeconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(millieSeconds:8);
  ///   print(duration.toMilliSeconds()); // prints 08
  ///``
  String toMilliSeconds() {
    return twoDigits(inMilliseconds);
  }

  /// Extension function to that returns the reminder of duration in hours.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(days :6, hours:8);
  ///   print(duration.toHours()); // prints 08
  ///``
  String toRemainingHours() {
    return twoDigits(inHours.remainder(24));
  }

  /// Extension function to that returns the reminder of duration in minutes.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:9, minutes:8);
  ///   print(duration.toMinutes()); // prints 08
  ///``
  String toRemainingMinutes() {
    return twoDigits(inMinutes.remainder(60));
  }

  /// Extension function to that returns the reminder of duration in seconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:9, seconds:8);
  ///   print(duration.toSeconds()); // prints 08
  ///``
  String toRemainingSeconds() {
    return twoDigits(inSeconds.remainder(60));
  }

  String toFormattedDuration(
      {String days = "days",
      String hours = "h",
      String minutes = "m",
      String seconds = "s"}) {
    final days = inDays;
    final remainingHours = inHours.remainder(24);

    final daysText = days == 0 ? '' : "${twoDigits(days)} $days : ";
    final hoursText = days == 0 && remainingHours == 0
        ? ''
        : "${twoDigits(remainingHours)} $hours : ";

    return "$daysText$hoursText"
        "${toRemainingMinutes()} $minutes "
        ": ${toRemainingSeconds()} $seconds";
  }
}
