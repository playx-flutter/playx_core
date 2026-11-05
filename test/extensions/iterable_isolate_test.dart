import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

int double_(int value) => value * 2;

int failing(int value) => throw StateError('boom $value');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => PlayxLogger.initLogger(name: 'PLAYX CORE'));

  group('asyncMapInIsolate', () {
    test('maps every element in isolates', () async {
      final result = await [
        1,
        2,
        3,
      ].asyncMapInIsolate(mapper: double_, useWorkManager: false);
      expect(result, [2, 4, 6]);
    });

    test('rethrows errors and logs them when printError is set', () async {
      await expectLater(
        [1, 2].asyncMapInIsolate(
          mapper: failing,
          useWorkManager: false,
          printError: true,
          printEachItemError: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rethrows quietly when printError is off', () async {
      await expectLater(
        [1].asyncMapInIsolate(
          mapper: failing,
          useWorkManager: false,
          printError: false,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
