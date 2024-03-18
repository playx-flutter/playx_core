import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/locale_extensions.dart';

void main() {
  group('Locale Extensions Test', () {
    group('isRtl', () {
      test('isRTL returns true if the language is RTL', () {
        const locale = Locale('ar');
        expect(locale.isRTL, true);
      });

      test('isRTL returns false if the language is not RTL', () {
        const locale = Locale('en');
        expect(locale.isRTL, false);
      });
    });

    group('direction', () {
      test('direction returns TextDirection.rtl if the language is RTL', () {
        const locale = Locale('ar');
        expect(locale.direction, TextDirection.rtl);
      });

      test('direction returns TextDirection.ltr if the language is not RTL',
          () {
        const locale = Locale('en');
        expect(locale.direction, TextDirection.ltr);
      });
    });

    group('isArabic', () {
      test('isArabic returns true if the language is Arabic', () {
        const locale = Locale('ar');
        expect(locale.isArabic, true);
      });

      test('isArabic returns false if the language is not Arabic', () {
        const locale = Locale('en');
        expect(locale.isArabic, false);
      });
    });

    group('isEnglish', () {
      test('isEnglish returns true if the language is English', () {
        const locale = Locale('en');
        expect(locale.isEnglish, true);
      });

      test('isEnglish returns false if the language is not English', () {
        const locale = Locale('ar');
        expect(locale.isEnglish, false);
      });
    });
  });
}
