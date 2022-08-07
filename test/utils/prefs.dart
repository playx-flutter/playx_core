import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  setUpAll(
    () {
      TestWidgetsFlutterBinding.ensureInitialized();
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
}
