import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('WebUtils on non-web platforms', () {
    test('web only helpers are safe no-ops', () {
      WebUtils.updateUrl(Uri.parse('https://example.com'));
      WebUtils.setBodyBackgroundColor('#ffffff');
      WebUtils.enterFullScreen();
      WebUtils.exitFullScreen();
      WebUtils.toggleFullScreen();
      WebUtils.reloadPage();
      WebUtils.openInNewTab('https://example.com');
      expect(WebUtils.isFullScreen(), isFalse);
      expect(calls, isEmpty);
    });

    test('setAppTitle does nothing when it is web only', () {
      WebUtils.setAppTitle(title: 'App');
      expect(calls, isEmpty);
    });

    test('setAppTitle sets the app switcher description otherwise', () {
      WebUtils.setAppTitle(
        title: 'My App',
        primaryColor: const Color(0xFF123456),
        webOnly: false,
      );
      final call = calls.single;
      expect(call.method, 'SystemChrome.setApplicationSwitcherDescription');
      expect(call.arguments, {'label': 'My App', 'primaryColor': 0xFF123456});
    });
  });
}
