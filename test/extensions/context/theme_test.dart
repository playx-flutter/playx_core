import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  Future<BuildContext> pump(WidgetTester tester, ThemeData theme) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets('shortcuts for a light theme', (tester) async {
    final theme = ThemeData(brightness: Brightness.light);
    final context = await pump(tester, theme);

    expect(context.theme, Theme.of(context));
    expect(context.textTheme, Theme.of(context).textTheme);
    expect(context.theme.brightness, theme.brightness);
    expect(context.brightness, Brightness.light);
    expect(context.isLight, isTrue);
    expect(context.isDark, isFalse);
  });

  testWidgets('shortcuts for a dark theme', (tester) async {
    final context = await pump(tester, ThemeData(brightness: Brightness.dark));

    expect(context.brightness, Brightness.dark);
    expect(context.isDark, isTrue);
    expect(context.isLight, isFalse);
  });
}
