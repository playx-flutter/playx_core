import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  group('Scope Functions Test', () {
    test('let returns the result of the lambda function', () {
      final result = 5.let((it) => it * 2);
      expect(result, 10);
    });

    test('also returns the object itself after executing the lambda function',
        () {
      final result = 5.also((it) {
        // Do something with it
      });
      expect(result, 5);
    });

    group('takeIf ', () {
      test('takeIf returns the object itself if the predicate is true', () {
        final result = 5.takeIf((it) => it > 3);
        expect(result, 5);
      });

      test('takeIf returns null if the predicate is false', () {
        final result = 5.takeIf((it) => it > 10);
        expect(result, null);
      });
    });

    group('takeUnless', () {
      test('takeUnless returns the object itself if the predicate is false',
          () {
        final result = 5.takeUnless((it) => it < 3);
        expect(result, 5);
      });

      test('takeUnless returns null if the predicate is true', () {
        final result = 5.takeUnless((it) => it < 10);
        expect(result, null);
      });
    });

    test('run returns the result of the lambda function', () {
      final result = 5.run(() => 10);
      expect(result, 10);
    });
  });
}
