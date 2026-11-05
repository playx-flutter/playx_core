import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  String? clipboardText;

  setUp(() {
    calls.clear();
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'Clipboard.setData':
              clipboardText = (call.arguments as Map)['text'] as String?;
              return null;
            case 'Clipboard.getData':
              return clipboardText == null ? null : {'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  List<dynamic> lockedOrientations() => calls
      .lastWhere((c) => c.method == 'SystemChrome.setPreferredOrientations')
      .arguments;

  group('setOrientation', () {
    test('portrait only by default', () {
      setOrientation();
      expect(lockedOrientations(), ['DeviceOrientation.portraitUp']);
    });

    test('portrait with rotation allows upside down', () {
      setOrientation(allowRotation: true);
      expect(lockedOrientations(), [
        'DeviceOrientation.portraitUp',
        'DeviceOrientation.portraitDown',
      ]);
    });

    test('landscape only', () {
      setOrientation(isPortrait: false);
      expect(lockedOrientations(), ['DeviceOrientation.landscapeLeft']);
    });

    test('landscape with rotation allows both directions', () {
      setOrientation(isPortrait: false, allowRotation: true);
      expect(lockedOrientations(), [
        'DeviceOrientation.landscapeLeft',
        'DeviceOrientation.landscapeRight',
      ]);
    });
  });

  group('clipboard', () {
    test('copies, reads and clears text', () async {
      expect(await getClipboardText(), isNull);

      await copyToClipboard('hello');
      expect(clipboardText, 'hello');
      expect(await getClipboardText(), 'hello');

      await clearClipboard();
      expect(await getClipboardText(), '');
    });
  });
}
