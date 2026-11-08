import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/future_extensions.dart';

void main() {
  group('Future Extensions Test', () {
    test('map returns a new value', () async {
      final future = Future.value(10);
      final result = await future.map((value) => value * 2);
      expect(result, 20);
    });
  });
}
