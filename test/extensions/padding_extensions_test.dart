import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/padding_extensions.dart';

void main() {
  group('Padding Extensions', () {
    group('PlayxNumPaddingExtensions', () {
      group('p', () {
        test('returns EdgeInsets.all with toDouble value for int', () {
          expect(16.p, EdgeInsets.all(16));
        });

        test('returns EdgeInsets.all with toDouble value for double', () {
          expect(2.5.p, EdgeInsets.all(2.5));
        });

        test('returns EdgeInsets.all zero for zero', () {
          expect(0.p, EdgeInsets.zero);
        });
      });

      group('px', () {
        test('returns EdgeInsets.symmetric horizontal with toDouble value', () {
          expect(8.px, EdgeInsets.symmetric(horizontal: 8));
        });

        test('returns EdgeInsets.symmetric horizontal for double', () {
          expect(1.5.px, EdgeInsets.symmetric(horizontal: 1.5));
        });
      });

      group('py', () {
        test('returns EdgeInsets.symmetric vertical with toDouble value', () {
          expect(4.py, EdgeInsets.symmetric(vertical: 4));
        });

        test('returns EdgeInsets.symmetric vertical for double', () {
          expect(0.5.py, EdgeInsets.symmetric(vertical: 0.5));
        });
      });

      group('pAll', () {
        test('returns EdgeInsets.all with toDouble value', () {
          expect(12.pAll, EdgeInsets.all(12));
        });

        test('is equivalent to p', () {
          expect(12.pAll, 12.p);
        });
      });

      group('pLR', () {
        test('returns EdgeInsets.symmetric horizontal with toDouble value', () {
          expect(10.pLR, EdgeInsets.symmetric(horizontal: 10));
        });

        test('is equivalent to px', () {
          expect(10.pLR, 10.px);
        });
      });

      group('pTB', () {
        test('returns EdgeInsets.symmetric vertical with toDouble value', () {
          expect(6.pTB, EdgeInsets.symmetric(vertical: 6));
        });

        test('is equivalent to py', () {
          expect(6.pTB, 6.py);
        });
      });

      group('pZero', () {
        test('returns EdgeInsets.zero ignoring receiver', () {
          expect(16.pZero, EdgeInsets.zero);
        });

        test('returns EdgeInsets.zero for zero receiver', () {
          expect(0.pZero, EdgeInsets.zero);
        });
      });
    });

    group('PlayxWidgetPaddingExtensions', () {
      group('pAll()', () {
        testWidgets('wraps widget in Padding with EdgeInsets.all', (
          tester,
        ) async {
          const child = SizedBox();
          final widget = child.pAll(8);

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(padding.padding, EdgeInsets.all(8));
          expect(padding.child, isA<SizedBox>());
        });
      });

      group('pSymmetric()', () {
        testWidgets('wraps widget with given symmetric padding', (
          tester,
        ) async {
          const child = SizedBox();
          final widget = child.pSymmetric(horizontal: 12, vertical: 6);

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(
            padding.padding,
            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        });

        testWidgets('defaults to EdgeInsets.zero', (tester) async {
          const child = SizedBox();
          final widget = child.pSymmetric();

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(padding.padding, EdgeInsets.zero);
        });
      });

      group('pOnly()', () {
        testWidgets('wraps widget with given per-side padding', (tester) async {
          const child = SizedBox();
          final widget = child.pOnly(left: 10, top: 4, right: 2, bottom: 1);

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(
            padding.padding,
            EdgeInsets.only(left: 10, top: 4, right: 2, bottom: 1),
          );
        });

        testWidgets('defaults to EdgeInsets.zero', (tester) async {
          const child = SizedBox();
          final widget = child.pOnly();

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(padding.padding, EdgeInsets.zero);
        });
      });

      group('pZero()', () {
        testWidgets('wraps widget with EdgeInsets.zero', (tester) async {
          const child = SizedBox();
          final widget = child.pZero();

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

          final padding = tester.widget<Padding>(find.byType(Padding));
          expect(padding.padding, EdgeInsets.zero);
          expect(padding.child, isA<SizedBox>());
        });
      });
    });
  });

  group('single sides and directional padding', () {
    test('single-side getters', () {
      expect(12.pt, const EdgeInsets.only(top: 12));
      expect(12.pb, const EdgeInsets.only(bottom: 12));
      expect(12.pl, const EdgeInsets.only(left: 12));
      expect(12.pr, const EdgeInsets.only(right: 12));
      expect(12.ps, const EdgeInsetsDirectional.only(start: 12));
      expect(12.pe, const EdgeInsetsDirectional.only(end: 12));
    });

    test('directional padding resolves with the text direction', () {
      expect(12.ps.resolve(TextDirection.ltr), const EdgeInsets.only(left: 12));
      expect(
        12.ps.resolve(TextDirection.rtl),
        const EdgeInsets.only(right: 12),
      );
    });

    test('withPadding and pDirectional wrap in Padding', () {
      const child = SizedBox();
      expect(child.withPadding(16.px).padding, 16.px);
      expect(
        child.pDirectional(start: 4, end: 8).padding,
        const EdgeInsetsDirectional.only(start: 4, end: 8),
      );
      expect(child.pAll(4), isA<Padding>());
    });
  });
}
