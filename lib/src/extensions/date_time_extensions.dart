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

  /// Checks whether the date is in the same week as the given [date]
  bool isSameWeek(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 7));
    return isAfter(firstDayOfWeek) && isBefore(lastDayOfWeek);
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
  bool get isInThisWeek => isSameWeek(DateTime.now());

  /// Checks whether the date is in the same month as the given [date]
  bool get isInThisMonth => isSameMonth(DateTime.now());

  /// Checks whether the date is in the same year as the given [date]
  bool get isInThisYear => isSameYear(DateTime.now());

  /// Checks whether the date is in the future
  bool get isInTheFuture => isAfter(DateTime.now());

  /// Checks whether the date is in the past
  bool get isInThePast => isBefore(DateTime.now());

  /// Checks whether the date is in January
  bool get isInJanuary => month == 1;

  /// Checks whether the date is in February
  bool get isInFebruary => month == 2;

  /// Checks whether the date is in March
  bool get isInMarch => month == 3;

  /// Checks whether the date is in April
  bool get isInApril => month == 4;

  /// Checks whether the date is in May
  bool get isInMay => month == 5;

  /// Checks whether the date is in June
  bool get isInJune => month == 6;

  /// Checks whether the date is in July
  bool get isInJuly => month == 7;

  /// Checks whether the date is in August
  bool get isInAugust => month == 8;

  /// Checks whether the date is in September
  bool get isInSeptember => month == 9;

  /// Checks whether the date is in October
  bool get isInOctober => month == 10;

  /// Checks whether the date is in November
  bool get isInNovember => month == 11;

  /// Checks whether the date is in December
  bool get isInDecember => month == 12;

  /// Checks whether the date is Monday
  bool get isMonday => weekday == DateTime.monday;

  /// Checks whether the date is Tuesday
  bool get isTuesday => weekday == DateTime.tuesday;

  /// Checks whether the date is Wednesday
  bool get isWednesday => weekday == DateTime.wednesday;

  /// Checks whether the date is Thursday
  bool get isThursday => weekday == DateTime.thursday;

  /// Checks whether the date is Friday
  bool get isFriday => weekday == DateTime.friday;

  /// Checks whether the date is Saturday
  bool get isSaturday => weekday == DateTime.saturday;

  /// Checks whether the date is Sunday
  bool get isSunday => weekday == DateTime.sunday;

  /// Returns new [DateTime] without the time part
  /// for example =>  `2020-01-01T12:51:42.325`
  /// to =>  `2020-01-01T00:00:00.000`
  DateTime withoutTime() => DateTime(year, month, day);

  /// returns true if date year is leap year
  bool get isLeapYear {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }
}
