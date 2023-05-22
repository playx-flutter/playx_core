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
}
