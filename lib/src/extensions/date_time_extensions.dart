enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static Weekday fromDate(DateTime date) {
    return Weekday.values[date.weekday - 1];
  }
}

enum Month {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december;

  static Month fromDate(DateTime date) {
    return Month.values[date.month - 1];
  }
}

/// Extensions for [DateTime]
extension DateTimeExtensions on DateTime {
  /// Check if the time is AM
  bool get isAm => hour < 12;

  /// Return new instance of [DateTime] with the next day date
  DateTime get nextDay => add(const Duration(days: 1));

  /// Return new instance of [DateTime] with the previous day date
  DateTime get previousDay => subtract(const Duration(days: 1));

  /// Return new instance of [DateTime] with the next week date
  DateTime get sameDayNextWeek => add(const Duration(days: 7));

  /// Return new instance of [DateTime] with the previous week date
  DateTime get sameDayPreviousWeek => subtract(const Duration(days: 7));

  /// Return new instance of [DateTime] with the next month date
  DateTime get nextMonth => add(const Duration(days: 30));

  /// Return new instance of [DateTime] with the previous month date
  DateTime get previousMonth => subtract(const Duration(days: 30));

  /// Checks whether the date is today
  bool get isToday => isSameDay(DateTime.now());

  /// Checks whether the date is tomorrow
  bool get isTomorrow => isSameDay(DateTime.now().nextDay);

  /// Checks whether the date is yesterday
  bool get isYesterday => isSameDay(DateTime.now().previousDay);

  /// Checks whether the date is in the same day as the given [date]
  bool isSameDay(
    DateTime date,
  ) =>
      date.year == year && date.month == month && date.day == day;

  /// Returns the index of the day of the week
  /// With the given [firstDay] as the first day of the week
  int dayOfTheWeekIndex({Weekday firstDay = Weekday.monday}) {
    final firstDayIndex = firstDay.index;
    final index = weekday - 1;
    return (index - firstDayIndex + 7) % 7;
  }

  /// Checks whether the date is in the same week as the given [date]
  bool isSameWeek({
    required DateTime date,
    Weekday firstDay = Weekday.monday,
  }) {
    // Get the day of the week for both dates (from 0 to 6 where 0 is Monday and 6 is Sunday)
    final int dayOfWeek = date.dayOfTheWeekIndex(firstDay: firstDay);
    final int otherDayOfWeek = dayOfTheWeekIndex(firstDay: firstDay);

    // Calculate the start of the week for both dates
    final DateTime startOfWeek = date.subtract(Duration(days: dayOfWeek));
    final DateTime otherStartOfWeek = subtract(Duration(days: otherDayOfWeek));

    // Compare the start of the week for both dates
    return startOfWeek.year == otherStartOfWeek.year &&
        startOfWeek.month == otherStartOfWeek.month &&
        startOfWeek.day == otherStartOfWeek.day;
  }

  /// Checks whether the date is in the same month as the given [date]
  bool isSameMonth(DateTime date) {
    return date.year == year && date.month == month;
  }

  /// Checks whether the date is in the same year as the given [date]
  bool isSameYear(DateTime date) {
    return date.year == year;
  }

  /// Checks whether the date is in the same week as the given [date]
  bool isInThisWeek({Weekday firstDay = Weekday.monday}) =>
      isSameWeek(date: DateTime.now(), firstDay: firstDay);

  /// Checks whether the date is in the same month as the given [date]
  bool get isInThisMonth => isSameMonth(DateTime.now());

  /// Checks whether the date is in the same year as the given [date]
  bool get isInThisYear => isSameYear(DateTime.now());

  /// Checks whether the date is in the future
  bool get isInTheFuture => isAfter(DateTime.now());

  /// Checks whether the date is in the past
  bool get isInThePast => isBefore(DateTime.now());

  /// Returns the day of the week
  Weekday dayOfTheWeek() {
    return Weekday.fromDate(this);
  }

  /// Returns the month of the given date.
  Month monthOfTheYear() {
    return Month.fromDate(this);
  }

  /// returns true if date year is leap year
  bool get isLeapYear {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  /// Returns new [DateTime] without the time part
  /// for example =>  `2020-01-01T12:51:42.325`
  /// to =>  `2020-01-01T00:00:00.000`
  DateTime withoutTime() => DateTime(year, month, day);

  /// Creates new instance of [DateTime] with the same date
  /// But overrides the values of the given parameters
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
      );
}
