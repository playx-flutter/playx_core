import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  Future<BuildContext> contextWithWidth(
    WidgetTester tester,
    double width,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets('crossAxisCount uses the default breakpoints', (tester) async {
    expect((await contextWithWidth(tester, 400)).crossAxisCount(), 1);
    expect((await contextWithWidth(tester, 840)).crossAxisCount(), 2);
    expect((await contextWithWidth(tester, 1400)).crossAxisCount(), 3);
  });

  testWidgets('crossAxisCount accepts custom breakpoints and counts', (
    tester,
  ) async {
    final context = await contextWithWidth(tester, 700);
    expect(
      context.crossAxisCount(mediumBreakpoint: 600, medium: 4, wide: 6),
      4,
    );
    expect(context.crossAxisCount(compact: 2), 2);
  });

  testWidgets('exposes the media query values', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(top: 24),
          alwaysUse24HourFormat: true,
        ),
        child: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    // `context.size` is BuildContext's own render size; see the getter docs.
    expect(ContextMediaQueryExtensions(context).size, const Size(400, 800));
    expect(context.width, 400);
    expect(context.height, 800);
    expect(context.aspectRatio, 0.5);
    expect(context.mediaQueryPadding, const EdgeInsets.only(top: 24));
    expect(context.orientation, Orientation.portrait);
    expect(context.isPortrait, isTrue);
    expect(context.isLandscape, isFalse);
    expect(context.alwaysUse24HourFormat, isTrue);
    expect(context.mediaQuery.size, const Size(400, 800));
  });

  testWidgets('detects landscape', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 400)),
        child: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(context.isLandscape, isTrue);
    expect(context.isPortrait, isFalse);
  });
}
