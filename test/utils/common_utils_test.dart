import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/common_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('setStatusBarColor sets status bar color correctly',
      (WidgetTester tester) async {
    // Test case 1: Red color with light icons
    setStatusBarColor(color: Colors.red, isDark: false);
    await tester.pumpAndSettle();

    expect(
      SystemChrome.latestStyle?.statusBarColor,
      Colors.red,
    );
  });

  testWidgets(
      'setStatusBarColor sets status bar icon color correctly when isDark is true',
      (WidgetTester tester) async {
    // Test case 1: Red color with light icons
    setStatusBarColor(color: Colors.red, isDark: false);
    await tester.pumpAndSettle();

    expect(
      SystemChrome.latestStyle?.statusBarIconBrightness,
      Brightness.light,
    );
  });

  testWidgets(
      'setStatusBarColor sets status bar icon color correctly when isDark is false',
      (WidgetTester tester) async {
    // Test case 1: Red color with light icons
    setStatusBarColor(color: Colors.red, isDark: true);
    await tester.pumpAndSettle();

    expect(
      SystemChrome.latestStyle?.statusBarIconBrightness,
      Brightness.dark,
    );
  });
}
