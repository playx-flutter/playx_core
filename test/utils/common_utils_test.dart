import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/utils/common_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Status bar', () {
    testWidgets('setStatusBarColor does not throw', (tester) async {
      await tester.pumpWidget(const SizedBox());
      expect(
            () => setStatusBarColor(color: Colors.red, isDark: true),
        returnsNormally,
      );
      await tester.pumpAndSettle();

      expect(
        SystemChrome.latestStyle?.statusBarColor,
        Colors.red,
      );
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        Brightness.dark,
      );

      expect(
        SystemChrome.latestStyle?.statusBarBrightness,
        Brightness.light,
      );

    });
  });

  group('Navigation bar', () {
    testWidgets('setNavigationBarColor does not throw', (tester) async {
      await tester.pumpWidget(const SizedBox());
      expect(
            () => setNavigationBarColor(color: Colors.green, isDark: false),
        returnsNormally,
      );
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.systemNavigationBarColor,
        Colors.green,
      );
      expect(
        SystemChrome.latestStyle?.systemNavigationBarIconBrightness,
        Brightness.light,
      );
    });
  });

  group('Orientation', () {
    testWidgets('setOrientation portrait does not throw', (tester) async {
      await tester.pumpWidget(const SizedBox());
      expect(() => setOrientation(), returnsNormally);
    });

    testWidgets('setOrientation landscape with rotation does not throw', (tester) async {
      await tester.pumpWidget(const SizedBox());
      expect(() => setOrientation(isPortrait: false, allowRotation: true), returnsNormally);
    });
  });

  group('Keyboard', () {
    testWidgets('hideKeyboard does not throw', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FocusScope.of(tester.element(find.byType(TextField))).requestFocus();
      expect(() => hideKeyboard(), returnsNormally);
    });

    testWidgets('showKeyboard does not throw', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FocusScope.of(tester.element(find.byType(TextField))).requestFocus();
      expect(() => showKeyboard(), returnsNormally);
    });
  });

  group('Full screen', () {
    testWidgets('enterFullScreen and exitFullScreen do not throw', (tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(() => enterFullScreen(), returnsNormally);
      expect(() => exitFullScreen(), returnsNormally);
    });
  });

  group('Clipboard', () {
    testWidgets('copyToClipboard and getClipboardText', (tester) async {
      const testText = 'hello';
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(() => copyToClipboard(testText), returnsNormally);
    });
  });
}