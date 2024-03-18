String twoDigits(int n) => n.toString().padLeft(2, "0");

/// Extension functions to convert duration to formatted hours, minutes, seconds and milliseconds.
extension DurationExtensions on Duration {
  /// Extension function to convert duration to formatted days.
  /// for example :
  /// ``dart
  /// final duration =  Duration(days:8);
  /// print(duration.toDays()); // prints 08
  /// ``
  String toDays({bool leadingZero = true}) {
    return leadingZero ? twoDigits(inDays) : inDays.toString();
  }

  /// Extension function to convert duration to formatted hours.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:8);
  ///   print(duration.toHours()); // prints 08
  ///``
  String toHours({bool leadingZero = true}) {
    return leadingZero ? twoDigits(inHours) : inHours.toString();
  }

  /// Extension function to convert duration to formatted minutes.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(minutes:8);
  ///   print(duration.toMinutes()); // prints 08
  ///``
  String toMinutes({bool leadingZero = true}) {
    return leadingZero ? twoDigits(inMinutes) : inMinutes.toString();
  }

  /// Extension function to convert duration to formatted seconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(seconds:8);
  ///   print(duration.toSeconds()); // prints 08
  ///``
  String toSeconds({bool leadingZero = true}) {
    return leadingZero ? twoDigits(inSeconds) : inSeconds.toString();
  }

  /// Extension function to convert duration to formatted millieSeconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(millieSeconds:8);
  ///   print(duration.toMilliSeconds()); // prints 08
  ///``
  String toMilliSeconds({bool leadingZero = true}) {
    return leadingZero ? twoDigits(inMilliseconds) : inMilliseconds.toString();
  }

  /// Extension function to that returns the reminder of duration in hours.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(days :6, hours:8);
  ///   print(duration.toHours()); // prints 08
  ///``
  String toRemainingHours({bool leadingZero = true}) {
    final remainingHours = inHours.remainder(24);
    return leadingZero ? twoDigits(remainingHours) : remainingHours.toString();
  }

  /// Extension function to that returns the reminder of duration in minutes.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:9, minutes:8);
  ///   print(duration.toMinutes()); // prints 08
  ///``
  String toRemainingMinutes({bool leadingZero = true}) {
    final remainingMinutes = inMinutes.remainder(60);
    return leadingZero
        ? twoDigits(remainingMinutes)
        : remainingMinutes.toString();
  }

  /// Extension function to that returns the reminder of duration in seconds.
  /// for example :
  /// ``dart
  ///  final duration =  Duration(hours:9, seconds:8);
  ///   print(duration.toSeconds()); // prints 08
  ///``
  String toRemainingSeconds({bool leadingZero = true}) {
    final remainingSeconds = inSeconds.remainder(60);
    return leadingZero
        ? twoDigits(remainingSeconds)
        : remainingSeconds.toString();
  }

  /// Extension function to that returns the formatted duration in days, hours, minutes and seconds.
  /// To customize the output, you can pass the optional parameters [days], [hours], [minutes] and [seconds].
  String toFormattedDuration({
    String? days,
    String? hours,
    String? minutes,
    String? seconds,
    String? spacer,
    bool leadingZero = true,
    bool leaveSpaceBetweenTimeAndText = true,
  }) {
    final remainingDays = toDays(leadingZero: leadingZero);
    final remainingHours = toRemainingHours(leadingZero: leadingZero);
    final remainingMinutes = toRemainingMinutes(leadingZero: leadingZero);
    final remainingSeconds = toRemainingSeconds(leadingZero: leadingZero);

    final space = leaveSpaceBetweenTimeAndText ? ' ' : '';
    final StringBuffer buffer = StringBuffer();
    if (days != null) {
      buffer.write('$remainingDays$space$days');
    }
    if (hours != null) {
      if (buffer.length > 0 && spacer != null) {
        buffer.write(spacer);
      }
      buffer.write('$remainingHours$space$hours');
    }
    if (minutes != null) {
      if (buffer.length > 0 && spacer != null) {
        buffer.write(spacer);
      }
      buffer.write('$remainingMinutes$space$minutes');
    }
    if (seconds != null) {
      if (buffer.length > 0 && spacer != null) {
        buffer.write(spacer);
      }
      buffer.write('$remainingSeconds$space$seconds');
    }
    return buffer.toString();
  }
}
