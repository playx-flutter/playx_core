import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await PlayxPrefsWithCache.create();
  });

  tearDown(PlayxPrefsWithCache.dispose);

  test('throws before create() and after dispose()', () async {
    await PlayxPrefsWithCache.dispose();
    expect(() => PlayxPrefsWithCache.sharedPrefs, throwsException);

    await PlayxPrefsWithCache.create();
    expect(PlayxPrefsWithCache.sharedPrefs, isA<SharedPreferencesWithCache>());
  });

  test('strings', () async {
    expect(PlayxPrefsWithCache.maybeGetString('s'), isNull);
    expect(PlayxPrefsWithCache.getString('s'), '');
    expect(PlayxPrefsWithCache.getString('s', fallback: 'x'), 'x');

    await PlayxPrefsWithCache.setString('s', 'hello');
    expect(PlayxPrefsWithCache.maybeGetString('s'), 'hello');
    expect(PlayxPrefsWithCache.getString('s', fallback: 'x'), 'hello');
  });

  test('ints', () async {
    expect(PlayxPrefsWithCache.maybeGetInt('i'), isNull);
    expect(PlayxPrefsWithCache.getInt('i'), -1);
    expect(PlayxPrefsWithCache.getInt('i', fallback: 7), 7);

    await PlayxPrefsWithCache.setInt('i', 42);
    expect(PlayxPrefsWithCache.maybeGetInt('i'), 42);
    expect(PlayxPrefsWithCache.getInt('i'), 42);
  });

  test('doubles', () async {
    expect(PlayxPrefsWithCache.maybeGetDouble('d'), isNull);
    expect(PlayxPrefsWithCache.getDouble('d'), -1);
    expect(PlayxPrefsWithCache.getDouble('d', fallback: 0.5), 0.5);

    await PlayxPrefsWithCache.setDouble('d', 1.5);
    expect(PlayxPrefsWithCache.maybeGetDouble('d'), 1.5);
    expect(PlayxPrefsWithCache.getDouble('d'), 1.5);
  });

  test('bools', () async {
    expect(PlayxPrefsWithCache.maybeGetBool('b'), isNull);
    expect(PlayxPrefsWithCache.getBool('b'), isFalse);
    expect(PlayxPrefsWithCache.getBool('b', fallback: true), isTrue);

    await PlayxPrefsWithCache.setBool('b', true);
    expect(PlayxPrefsWithCache.maybeGetBool('b'), isTrue);
    await PlayxPrefsWithCache.setBool('b', false);
    expect(PlayxPrefsWithCache.getBool('b', fallback: true), isFalse);
  });

  test('a value of another type reads as null or the fallback', () async {
    await PlayxPrefsWithCache.setString('s', 'text');
    expect(PlayxPrefsWithCache.maybeGetInt('s'), isNull);
    expect(PlayxPrefsWithCache.getInt('s', fallback: 3), 3);
    expect(PlayxPrefsWithCache.maybeGetDouble('s'), isNull);
    expect(PlayxPrefsWithCache.maybeGetBool('s'), isNull);
  });

  test('find, remove, clear and reloadCache', () async {
    expect(PlayxPrefsWithCache.find('k'), isNull);

    await PlayxPrefsWithCache.setInt('k', 5);
    await PlayxPrefsWithCache.setString('other', 'x');
    expect(PlayxPrefsWithCache.find('k'), 5);

    await PlayxPrefsWithCache.reloadCache();
    expect(PlayxPrefsWithCache.find('k'), 5);

    await PlayxPrefsWithCache.remove('k');
    expect(PlayxPrefsWithCache.find('k'), isNull);
    expect(PlayxPrefsWithCache.maybeGetString('other'), 'x');

    await PlayxPrefsWithCache.clear();
    expect(PlayxPrefsWithCache.maybeGetString('other'), isNull);
  });

  test('create accepts an allow list', () async {
    await PlayxPrefsWithCache.create(
      options: const SharedPreferencesWithCacheOptions(allowList: {'only'}),
    );
    await PlayxPrefsWithCache.setString('only', 'ok');
    expect(PlayxPrefsWithCache.maybeGetString('only'), 'ok');
    expect(
      () => PlayxPrefsWithCache.setString('other', 'no'),
      throwsA(anything),
    );
  });
}
