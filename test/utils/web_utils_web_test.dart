@TestOn('browser')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:web/web.dart' as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('setAppTitle takes the same arguments as on other platforms', () {
    WebUtils.setAppTitle(title: 'Playx Test', webOnly: false);
    expect(web.document.title, 'Playx Test');

    WebUtils.setAppTitle(
      title: 'Second',
      primaryColor: const Color(0xFF112233),
    );
    expect(web.document.title, 'Second');
  });

  test('setBodyBackgroundColor sets the inline background color', () {
    WebUtils.setBodyBackgroundColor('#123456');
    expect(web.document.body!.style.backgroundColor, isNotEmpty);
  });

  test('updateUrl and updateQueryParameters replace the URL in place', () {
    final base = Uri.parse(web.window.location.href);

    WebUtils.updateUrl(base.replace(queryParameters: {'a': '1'}));
    expect(Uri.parse(web.window.location.href).queryParameters, {'a': '1'});

    WebUtils.updateQueryParameters({'b': '2', 'c': '3'});
    expect(Uri.parse(web.window.location.href).queryParameters, {
      'b': '2',
      'c': '3',
    });
  });

  test('isFullScreen is false by default', () {
    expect(WebUtils.isFullScreen(), isFalse);
  });
}
