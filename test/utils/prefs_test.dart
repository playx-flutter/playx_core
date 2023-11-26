import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  late final SharedPreferences prefs;
  setUpAll(
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      PlayxPrefs.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    },
  );

  setUp(
    () async {
      await PlayxCore.bootCore();
    },
  );
  tearDown(
    () async {
      await PlayxCore.dispose();
    },
  );

  group(
    'getString',
    () {
      test(
        'it return null if key does not exist',
        () {
          expect(
            PlayxPrefs.maybeGetString('some_key'),
            null,
          );
        },
      );
      test(
        'it return the string value exist',
        () async {
          await prefs.setString('key', 'value');
          expect(
            PlayxPrefs.maybeGetString('key'),
            'value',
          );
        },
      );
    },
  );
}
