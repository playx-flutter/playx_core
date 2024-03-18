import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/date_time_extensions.dart';

void main() {
  group('DateTime Extensions', () {
    group('isAm', () {
      test('isAm returns true if the time is AM', () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isAm, true);
      });

      test('isAm returns false if the time is PM', () {
        final dateTime = DateTime(2021, 10, 10, 22, 10, 10);
        expect(dateTime.isAm, false);
      });
    });

    test('nextDay returns the next day date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.nextDay, DateTime(2021, 10, 11, 10, 10, 10));
    });

    test('previousDay returns the previous day date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.previousDay, DateTime(2021, 10, 9, 10, 10, 10));
    });

    test('sameDayNextWeek returns the next week date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.sameDayNextWeek, DateTime(2021, 10, 17, 10, 10, 10));
    });

    test('sameDayPreviousWeek returns the previous week date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.sameDayPreviousWeek, DateTime(2021, 10, 3, 10, 10, 10));
    });

    test('nextMonth returns the next month date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.nextMonth, DateTime(2021, 11, 9, 10, 10, 10));
    });

    test('previousMonth returns the previous month date', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.previousMonth, DateTime(2021, 9, 10, 10, 10, 10));
    });

    test(
        'copyWith returns new instance of DateTime with the same date but overrides the values of the given parameters',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(
          dateTime.copyWith(
            year: 2022,
            month: 11,
            day: 11,
          ),
          DateTime(
            2022,
            11,
            11,
            10,
            10,
            10,
          ));
    });

    group('isToday', () {
      test('isToday returns true if the date is today', () {
        final dateTime = DateTime.now();
        expect(dateTime.isToday, true);
      });

      test('isToday returns false if the date is not today', () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isToday, false);
      });
    });

    group('isTomorrow', () {
      test('isTomorrow returns true if the date is tomorrow', () {
        final dateTime = DateTime.now().nextDay;
        expect(dateTime.isTomorrow, true);
      });

      test('isTomorrow returns false if the date is not tomorrow', () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isTomorrow, false);
      });
    });

    group('isYesterday', () {
      test('isYesterday returns true if the date is yesterday', () {
        final dateTime = DateTime.now().previousDay;
        expect(dateTime.isYesterday, true);
      });

      test('isYesterday returns false if the date is not yesterday', () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isYesterday, false);
      });
    });

    group('isSameDay', () {
      test(
          'isSameDay returns true if the date is in the same day as the given date',
          () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isSameDay(DateTime(2021, 10, 10, 10, 10, 10)), true);
      });

      test(
          'isSameDay returns false if the date is not in the same day as the given date',
          () {
        final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
        expect(dateTime.isSameDay(DateTime(2021, 10, 11, 10, 10, 10)), false);
      });
    });
  });

  group('isSameWeek', () {
    test(
        'isSameWeek returns true if the date is in the same week as the given date',
        () {
      final dateTime = DateTime(
        2021,
        10,
        11,
      );

      expect(
          dateTime.isSameWeek(
              date: DateTime(
                2021,
                10,
                12,
              ),
              firstDay: Weekday.monday),
          true);
    });

    test(
        'isSameWeek returns false if the date is not in the same week as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(
          dateTime.isSameWeek(date: DateTime(2021, 10, 20, 10, 10, 10)), false);
    });
  });

  group('isSameMonth', () {
    test(
        'isSameMonth returns true if the date is in the same month as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isSameMonth(DateTime(2021, 10, 20, 10, 10, 10)), true);
    });

    test(
        'isSameMonth returns false if the date is not in the same month as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isSameMonth(DateTime(2021, 11, 20, 10, 10, 10)), false);
    });
  });

  group('isSameYear', () {
    test(
        'isSameYear returns true if the date is in the same year as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isSameYear(DateTime(2021, 11, 20, 10, 10, 10)), true);
    });

    test(
        'isSameYear returns false if the date is not in the same year as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isSameYear(DateTime(2022, 11, 20, 10, 10, 10)), false);
    });
  });

  group('isInThisWeek', () {
    test(
        'isInThisWeek returns false if the date is not in the same week as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isInThisWeek(), false);
    });
  });

  group('isInThisMonth', () {
    test(
        'isInThisMonth returns false if the date is not in the same month as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isInThisMonth, false);
    });
  });

  group('isInThisYear', () {
    test(
        'isInThisYear returns false if the date is not in the same year as the given date',
        () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.isInThisYear, false);
    });
  });

  group('isInTheFuture', () {
    test('isInTheFuture returns true if the date is in the future', () {
      final dateTime = DateTime.now().add(const Duration(days: 1));
      expect(dateTime.isInTheFuture, true);
    });

    test('isInTheFuture returns false if the date is not in the future', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 1));
      expect(dateTime.isInTheFuture, false);
    });
  });

  group('isInThePast', () {
    test('isInThePast returns true if the date is in the past', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 1));
      expect(dateTime.isInThePast, true);
    });

    test('isInThePast returns false if the date is not in the past', () {
      final dateTime = DateTime.now().add(const Duration(days: 1));
      expect(dateTime.isInThePast, false);
    });
  });

  group('dayOfTheWeek', () {
    test('dayOfTheWeek returns the day of the week', () {
      final dateTime = DateTime(2021, 10, 10, 10, 10, 10);
      expect(dateTime.dayOfTheWeek(), Weekday.sunday);
    });

    test(
        'dayOfTheWeekIndex returns the index of the day of the week with firstDay value',
        () {
      //monday
      final dateTime = DateTime(
        2024,
        3,
        11,
      );
      expect(dateTime.dayOfTheWeekIndex(firstDay: Weekday.monday), 0);
    });

    test(
        'dayOfTheWeekIndex returns the index of the day of the week with firstDay value',
        () {
      final dateTime = DateTime(
        2024,
        3,
        11,
      );
      expect(dateTime.dayOfTheWeekIndex(firstDay: Weekday.saturday), 2);
    });
  });

  group('monthOfTheYear', () {
    test('monthOfTheYear returns the month of the year', () {
      final dateTime = DateTime(
        2021,
        10,
        10,
      );
      expect(dateTime.monthOfTheYear(), Month.october);
    });

    test('monthOfTheYear returns the month of the year', () {
      final dateTime = DateTime(
        2021,
        1,
        10,
      );
      expect(dateTime.monthOfTheYear(), Month.january);
    });
  });

  test('withoutTime returns new DateTime without the time part', () {
    final dateTime = DateTime(2020, 1, 1, 12, 51, 42, 50);
    expect(dateTime.withoutTime(), DateTime(2020, 1, 1, 0, 0, 0, 0));
  });

  group('isLeapYear', () {
    test('isLeapYear returns true if the year is leap year', () {
      final dateTime = DateTime(
        2020,
        1,
        1,
        12,
      );
      expect(dateTime.isLeapYear, true);
    });

    test('isLeapYear returns false if the year is not leap year', () {
      final dateTime = DateTime(
        2021,
        1,
        1,
        12,
      );
      expect(dateTime.isLeapYear, false);
    });
  });
}
