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
      await PlayxPrefs.clear();
      await PlayxCore.dispose();
    },
  );

  group('PlayxPrefs test', () {
    test(
      'instance returns the shared preferences instance',
      () {
        expect(
          PlayxPrefs.instance,
          isA<SharedPreferences>(),
        );
      },
    );
    group(
      'String test',
      () {
        test(
          'maybeGetString() returns null when key does not exist',
          () {
            expect(
              PlayxPrefs.maybeGetString('some_key'),
              null,
            );
          },
        );
        test(
          'maybeGetString() return the string value if the the key exists',
          () async {
            await prefs.setString('key', 'value');
            expect(
              PlayxPrefs.maybeGetString('key'),
              'value',
            );
          },
        );
        test(
          'getString() returns empty String when key does not exist',
          () {
            expect(
              PlayxPrefs.getString('key'),
              '',
            );
          },
        );
        test(
          'getString() returns the value of the key',
          () async {
            await prefs.setString('key', 'value');
            expect(
              PlayxPrefs.getString('key'),
              'value',
            );
          },
        );

        test(
          'setString() sets the value of the key',
          () async {
            await PlayxPrefs.setString('key', 'value');
            expect(
              prefs.getString('key'),
              'value',
            );
          },
        );
      },
    );

    group('Int Test', () {
      test(
        'maybeGetInt() returns null when key does not exist',
        () {
          expect(
            PlayxPrefs.maybeGetInt('some_key'),
            null,
          );
        },
      );

      test(
        'maybeGetInt() return the int value if the the key exists',
        () async {
          await prefs.setInt('key', 1);
          expect(
            PlayxPrefs.maybeGetInt('key'),
            1,
          );
        },
      );

      test(
        'getInt() returns -1 when key does not exist',
        () {
          expect(
            PlayxPrefs.getInt('key'),
            -1,
          );
        },
      );

      test(
        'getInt() returns the value of the key',
        () async {
          await prefs.setInt('key', 1);
          expect(
            PlayxPrefs.getInt('key'),
            1,
          );
        },
      );

      test(
        'setInt() sets the value of the key',
        () async {
          await PlayxPrefs.setInt('key', 1);
          expect(
            prefs.getInt('key'),
            1,
          );
        },
      );
    });

    group('Double Test', () {
      test(
        'maybeGetDouble() returns null when key does not exist',
        () {
          expect(
            PlayxPrefs.maybeGetDouble('some_key'),
            null,
          );
        },
      );

      test(
        'maybeGetDouble() return the double value if the the key exists',
        () async {
          await prefs.setDouble('key', 1.0);
          expect(
            PlayxPrefs.maybeGetDouble('key'),
            1.0,
          );
        },
      );

      test(
        'getDouble() returns -1 when key does not exist',
        () {
          expect(
            PlayxPrefs.getDouble('key'),
            -1,
          );
        },
      );

      test(
        'getDouble() returns the value of the key',
        () async {
          await prefs.setDouble('key', 1.0);
          expect(
            PlayxPrefs.getDouble('key'),
            1.0,
          );
        },
      );

      test(
        'setDouble() sets the value of the key',
        () async {
          await PlayxPrefs.setDouble('key', 1.0);
          expect(
            prefs.getDouble('key'),
            1.0,
          );
        },
      );
    });

    group('Bool Test', () {
      test(
        'maybeGetBool() returns null when key does not exist',
        () {
          expect(
            PlayxPrefs.maybeGetBool('some_key'),
            null,
          );
        },
      );

      test(
        'maybeGetBool() return the bool value if the the key exists',
        () async {
          await prefs.setBool('key', true);
          expect(
            PlayxPrefs.maybeGetBool('key'),
            true,
          );
        },
      );

      test(
        'getBool() returns false when key does not exist',
        () {
          expect(
            PlayxPrefs.getBool('key'),
            false,
          );
        },
      );

      test(
        'getBool() returns the value of the key',
        () async {
          await prefs.setBool('key', true);
          expect(
            PlayxPrefs.getBool('key'),
            true,
          );
        },
      );

      test('setBool() sets the value of the key', () async {
        await PlayxPrefs.setBool('key', true);
        expect(
          prefs.getBool('key'),
          true,
        );
      });
    });

    test('find() returns the object if the key exists', () async {
      await prefs.setString('key', 'value');
      expect(
        PlayxPrefs.find('key'),
        'value',
      );
    });

    test('clear() deletes all prefs items', () {
      prefs.setString('key', 'value');
      PlayxPrefs.clear();
      expect(
        prefs.getKeys().length,
        0,
      );
    });
  });
}
