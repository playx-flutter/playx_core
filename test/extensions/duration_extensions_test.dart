import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/duration_extensions.dart';

void main() {
  group('Duration Extensions Test', () {
    test('toDays() returns the formatted days', () {
      const duration = Duration(days: 8);
      expect(duration.toDays(), '08');
    });

    test('toHours() returns the formatted hours', () {
      const duration = Duration(hours: 8);
      expect(duration.toHours(), '08');
    });

    test('toHours() with leading zero false return hours without zero', () {
      const duration = Duration(hours: 8);
      expect(duration.toHours(leadingZero: false), '8');
    });

    test('toMinutes() returns the formatted minutes', () {
      const duration = Duration(minutes: 8);
      expect(duration.toMinutes(), '08');
    });

    test('toSeconds() returns the formatted seconds', () {
      const duration = Duration(seconds: 8);
      expect(duration.toSeconds(), '08');
    });

    test('toMilliSeconds() returns the formatted millieSeconds', () {
      const duration = Duration(milliseconds: 8);
      expect(duration.toMilliSeconds(), '08');
    });

    test('toRemainingHours() returns the reminder of duration in hours', () {
      const duration = Duration(days: 6, hours: 8);
      expect(duration.toRemainingHours(), '08');
    });

    test('toRemainingMinutes() returns the reminder of duration in minutes',
        () {
      const duration = Duration(hours: 9, minutes: 8);
      expect(duration.toRemainingMinutes(), '08');
    });

    test('toRemainingSeconds() returns the reminder of duration in seconds',
        () {
      const duration = Duration(minutes: 9, seconds: 8);
      expect(duration.toRemainingSeconds(), '08');
    });

    test(
        'toFormattedDuration() returns the formatted duration in days, hours, minutes and seconds ',
        () {
      const duration = Duration(days: 6, hours: 8, minutes: 9, seconds: 8);
      expect(
          duration.toFormattedDuration(
            days: 'd',
            hours: 'h',
            minutes: 'm',
            seconds: 's',
            spacer: ' : ',
          ),
          '06 d : 08 h : 09 m : 08 s');
    });
  });
}
