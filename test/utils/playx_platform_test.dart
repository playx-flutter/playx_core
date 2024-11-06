import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  group('Test app platform', () {
    testWidgets('Test current platform is android or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isAndroid, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is iOS or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isIOS, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is macOS or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isMacOS, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is Windows or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isWindows, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is Linux or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isLinux, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is Fuchsia or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isFuchsia, true);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is web or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isWeb, false);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Test current platform is mobile or not', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isMobile, true);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(SizedBox());

      expect(PlayxPlatform.isMobile, true);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('Test current platform is desktop or not', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isDesktop, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isDesktop, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isDesktop, true);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Test current platform is cupertino or not', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isCupertino, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isCupertino, true);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Test current platform is material or not', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isMaterial, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isMaterial, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isMaterial, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isMaterial, true);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(SizedBox());

    expect(PlayxPlatform.isMaterial, false);

    debugDefaultTargetPlatformOverride = null;
  });
}
