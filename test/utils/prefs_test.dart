import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late final SharedPreferences prefs;
  setUpAll(
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
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
      await PlayXCore.disbose();
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
