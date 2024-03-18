import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextColorsExtensions', () {
    testWidgets('primaryColor returns the primary color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: const Color(0xFF00FF00)),
          home: Builder(
            builder: (context) {
              expect(context.primaryColor, const Color(0xFF00FF00));
              return Container(
                color: context.primaryColor,
              );
            },
          ),
        ),
      );
    });

    testWidgets('primaryColorDark returns the primary color dark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColorDark: const Color(0xFF00FF00)),
          home: Builder(
            builder: (context) {
              expect(context.primaryColorDark, const Color(0xFF00FF00));
              return Container(
                color: context.primaryColorDark,
              );
            },
          ),
        ),
      );
    });
  });

  group('ContextColorsExtensions', () {
    testWidgets('primaryColorLight returns the primary color light',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColorLight: const Color(0xFF00FF00)),
          home: Builder(
            builder: (context) {
              expect(context.primaryColorLight, const Color(0xFF00FF00));
              return Container(
                color: context.primaryColorLight,
              );
            },
          ),
        ),
      );
    });

    testWidgets('backgroundColor returns the background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              background: Color(0xFF00FF00),
            ),
          ),
          home: Builder(
            builder: (context) {
              expect(context.backgroundColor, const Color(0xFF00FF00));
              return Container();
            },
          ),
        ),
      );
    });
  });

  testWidgets('scaffoldBackgroundColor returns the scaffold background color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.scaffoldBackgroundColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('bottomAppBarColor returns the bottom app bar color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF00FF00)),
        ),
        home: Builder(
          builder: (context) {
            expect(context.bottomAppBarColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('cardColor returns the card color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(cardColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.cardColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('dividerColor returns the divider color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(dividerColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.dividerColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('disabledColor returns the disabled color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(disabledColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.disabledColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('focusColor returns the focus color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(focusColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.focusColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('hoverColor returns the hover color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(hoverColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.hoverColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('highlightColor returns the highlight color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(highlightColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.highlightColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('splashColor returns the splash color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.splashColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('unselectedWidgetColor returns the unselected widget color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(unselectedWidgetColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.unselectedWidgetColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('secondaryHeaderColor returns the secondary header color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(secondaryHeaderColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.secondaryHeaderColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('hintColor returns the hint color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(hintColor: const Color(0xFF00FF00)),
        home: Builder(
          builder: (context) {
            expect(context.hintColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('errorColor returns the error color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            error: Color(0xFF00FF00),
          ),
        ),
        home: Builder(
          builder: (context) {
            expect(context.errorColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('colorScheme returns the color scheme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00FF00),
            secondary: Color(0xFF00FF00),
            background: Color(0xFF00FF00),
            surface: Color(0xFF00FF00),
            onBackground: Color(0xFF00FF00),
            onSurface: Color(0xFF00FF00),
            onError: Color(0xFF00FF00),
            onPrimary: Color(0xFF00FF00),
            onSecondary: Color(0xFF00FF00),
            error: Color(0xFF00FF00),
          ),
        ),
        home: Builder(
          builder: (context) {
            expect(
                context.colorScheme,
                const ColorScheme.light(
                  primary: Color(0xFF00FF00),
                  secondary: Color(0xFF00FF00),
                  background: Color(0xFF00FF00),
                  surface: Color(0xFF00FF00),
                  onBackground: Color(0xFF00FF00),
                  onSurface: Color(0xFF00FF00),
                  onError: Color(0xFF00FF00),
                  onPrimary: Color(0xFF00FF00),
                  onSecondary: Color(0xFF00FF00),
                  error: Color(0xFF00FF00),
                ));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('secondary returns the secondary color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            secondary: Color(0xFF00FF00),
          ),
        ),
        home: Builder(
          builder: (context) {
            expect(context.secondary, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });

  testWidgets('buttonPrimaryColor returns the primary color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00FF00),
          ),
        ),
        home: Builder(
          builder: (context) {
            expect(context.buttonPrimaryColor, const Color(0xFF00FF00));
            return Container();
          },
        ),
      ),
    );
  });
}

extension ContextColorsExtensions on BuildContext {
  /// shortcut for `Theme.of(context).primaryColor`
  Color get primaryColor => Theme.of(this).primaryColor;

  /// shortcut for `Theme.of(context).primaryColorDark`
  Color get primaryColorDark => Theme.of(this).primaryColorDark;

  /// shortcut for `Theme.of(context).primaryColorLight`
  Color get primaryColorLight => Theme.of(this).primaryColorLight;

  /// shortcut for `Theme.of(context).colorScheme.backgroundColor`
  Color get backgroundColor => Theme.of(this).colorScheme.background;

  /// shortcut for `Theme.of(context).scaffoldBackgroundColor`
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// shortcut for `Theme.of(this).bottomAppBarTheme.color`
  Color? get bottomAppBarColor => Theme.of(this).bottomAppBarTheme.color;

  /// shortcut for `Theme.of(context).cardColor`
  Color get cardColor => Theme.of(this).cardColor;

  /// shortcut for `Theme.of(context).dividerColor`
  Color get dividerColor => Theme.of(this).dividerColor;

  /// shortcut for `Theme.of(context).disabledColor`
  Color get disabledColor => Theme.of(this).disabledColor;

  /// shortcut for `Theme.of(context).focusColor`
  Color get focusColor => Theme.of(this).focusColor;

  /// shortcut for `Theme.of(context).hoverColor`
  Color get hoverColor => Theme.of(this).hoverColor;

  /// shortcut for `Theme.of(context).highlightColor`
  Color get highlightColor => Theme.of(this).highlightColor;

  /// shortcut for `Theme.of(context).splashColor`
  Color get splashColor => Theme.of(this).splashColor;

  /// shortcut for `Theme.of(context).unselectedWidgetColor`
  Color get unselectedWidgetColor => Theme.of(this).unselectedWidgetColor;

  /// shortcut for `Theme.of(context).secondaryHeaderColor`
  Color get secondaryHeaderColor => Theme.of(this).secondaryHeaderColor;

  /// shortcut for `Theme.of(context).hintColor`

  Color get hintColor => Theme.of(this).hintColor;

  /// shortcut for `Theme.of(context).colorScheme.error`
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// shortcut for `Theme.of(context).colorScheme`
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// shortcut for `Theme.of(context).colorScheme.secondary`
  Color get secondary => colorScheme.secondary;

  /// shortcut for `Theme.of(context).colorScheme.primary`
  Color get buttonPrimaryColor => colorScheme.primary;
}
