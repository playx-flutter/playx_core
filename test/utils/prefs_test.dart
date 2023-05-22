import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/playx_core.dart';

void main() {
  late final SharedPreferences prefs;
  setUpAll(
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      Prefs.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    },
  );

  setUp(
    () async {
      await PlayXCore.bootCore();
    },
  );
  tearDown(
    () async {
      await PlayXCore.dispose();
    },
  );

  group(
    'getString',
    () {
      test(
        'it return null if key does not exist',
        () {
          expect(
            Prefs.getString('some_key'),
            null,
          );
        },
      );
      test(
        'it return the string value exist',
        () async {
          await prefs.setString('key', 'value');
          expect(
            Prefs.getString('key'),
            'value',
          );
        },
      );
    },
  );
}
