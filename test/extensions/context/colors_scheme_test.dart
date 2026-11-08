import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  // Every role has a distinct color so a mix-up between getters is caught.
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF010101),
    onPrimary: Color(0xFF020202),
    primaryContainer: Color(0xFF030303),
    onPrimaryContainer: Color(0xFF040404),
    secondary: Color(0xFF050505),
    onSecondary: Color(0xFF060606),
    secondaryContainer: Color(0xFF070707),
    onSecondaryContainer: Color(0xFF080808),
    tertiary: Color(0xFF090909),
    onTertiary: Color(0xFF0A0A0A),
    tertiaryContainer: Color(0xFF0B0B0B),
    onTertiaryContainer: Color(0xFF0C0C0C),
    error: Color(0xFF0D0D0D),
    onError: Color(0xFF0E0E0E),
    errorContainer: Color(0xFF0F0F0F),
    onErrorContainer: Color(0xFF101010),
    surface: Color(0xFF111111),
    onSurface: Color(0xFF121212),
    outline: Color(0xFF131313),
    outlineVariant: Color(0xFF141414),
    shadow: Color(0xFF151515),
    scrim: Color(0xFF161616),
    inverseSurface: Color(0xFF171717),
    onInverseSurface: Color(0xFF181818),
    inversePrimary: Color(0xFF191919),
  );

  testWidgets('maps the Material 3 color scheme roles', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(context.colorScheme, scheme);
    expect(context.primary, scheme.primary);
    expect(context.onPrimary, scheme.onPrimary);
    expect(context.primaryContainer, scheme.primaryContainer);
    expect(context.onPrimaryContainer, scheme.onPrimaryContainer);
    expect(context.secondary, scheme.secondary);
    expect(context.onSecondary, scheme.onSecondary);
    expect(context.secondaryContainer, scheme.secondaryContainer);
    expect(context.onSecondaryContainer, scheme.onSecondaryContainer);
    expect(context.tertiary, scheme.tertiary);
    expect(context.onTertiary, scheme.onTertiary);
    expect(context.tertiaryContainer, scheme.tertiaryContainer);
    expect(context.onTertiaryContainer, scheme.onTertiaryContainer);
    expect(context.error, scheme.error);
    expect(context.onError, scheme.onError);
    expect(context.errorContainer, scheme.errorContainer);
    expect(context.onErrorContainer, scheme.onErrorContainer);
    expect(context.surface, scheme.surface);
    expect(context.onSurface, scheme.onSurface);
    expect(context.outline, scheme.outline);
    expect(context.outlineVariant, scheme.outlineVariant);
    expect(context.shadow, scheme.shadow);
    expect(context.scrim, scheme.scrim);
    expect(context.inverseSurface, scheme.inverseSurface);
    expect(context.onInverseSurface, scheme.onInverseSurface);
    expect(context.inversePrimary, scheme.inversePrimary);
    expect(context.buttonPrimaryColor, scheme.primary);
    expect(context.backgroundColor, scheme.surface);
  });

  testWidgets('maps the theme colors', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFAA0000),
          cardColor: const Color(0xFF00AA00),
          dividerColor: const Color(0xFF0000AA),
          disabledColor: const Color(0xFFAAAA00),
          focusColor: const Color(0xFF00AAAA),
          bottomAppBarTheme: const BottomAppBarThemeData(
            color: Color(0xFFAA00AA),
          ),
        ),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(context.scaffoldBackgroundColor, const Color(0xFFAA0000));
    expect(context.cardColor, const Color(0xFF00AA00));
    expect(context.dividerColor, const Color(0xFF0000AA));
    expect(context.disabledColor, const Color(0xFFAAAA00));
    expect(context.focusColor, const Color(0xFF00AAAA));
    expect(context.bottomAppBarColor, const Color(0xFFAA00AA));
    expect(context.primaryColorLight, isA<Color>());
  });
}
