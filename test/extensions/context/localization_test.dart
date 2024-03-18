import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/extensions/context/localization.dart';

void main() {
  group('Context Localization Extensions Test', () {
    testWidgets('directionality returns the directionality of the context',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            locale: const Locale('en', 'US'),
            builder: (context, _) {
              expect(context.directionality, TextDirection.ltr);
              return const Placeholder();
            }),
      );
    });

    testWidgets('isRtl returns true if the directionality is rtl',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            locale: const Locale('en', 'US'),
            builder: (context, _) {
              expect(context.isRtl, false);
              return const Placeholder();
            }),
      );
    });

    testWidgets('isLtr returns true if the directionality is ltr',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            locale: const Locale('en', 'US'),
            builder: (context, _) {
              expect(context.isLtr, true);
              return const Placeholder();
            }),
      );
    });

    testWidgets('locale returns the locale of the context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            locale: const Locale('en', 'US'),
            builder: (context, _) {
              expect(context.locale, const Locale('en', 'US'));
              return const Placeholder();
            }),
      );
    });
  });
}
