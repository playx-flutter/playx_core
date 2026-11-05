import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await PlayxAsyncPrefs.create();
  });

  tearDown(PlayxAsyncPrefs.dispose);

  test('throws before create() and after dispose()', () async {
    await PlayxAsyncPrefs.dispose();
    expect(() => PlayxAsyncPrefs.sharedPrefs, throwsException);
    expect(await PlayxAsyncPrefs.maybeGetString('a'), isNull);
    expect(await PlayxAsyncPrefs.getInt('a', fallback: 4), 4);

    await PlayxAsyncPrefs.create();
    expect(PlayxAsyncPrefs.sharedPrefs, isA<SharedPreferencesAsync>());
  });

  test('strings', () async {
    expect(await PlayxAsyncPrefs.maybeGetString('s'), isNull);
    expect(await PlayxAsyncPrefs.getString('s'), '');
    expect(await PlayxAsyncPrefs.getString('s', fallback: 'x'), 'x');

    await PlayxAsyncPrefs.setString('s', 'hello');
    expect(await PlayxAsyncPrefs.maybeGetString('s'), 'hello');
    expect(await PlayxAsyncPrefs.getString('s', fallback: 'x'), 'hello');
  });

  test('ints', () async {
    expect(await PlayxAsyncPrefs.maybeGetInt('i'), isNull);
    expect(await PlayxAsyncPrefs.getInt('i'), -1);
    expect(await PlayxAsyncPrefs.getInt('i', fallback: 7), 7);

    await PlayxAsyncPrefs.setInt('i', 42);
    expect(await PlayxAsyncPrefs.maybeGetInt('i'), 42);
    expect(await PlayxAsyncPrefs.getInt('i'), 42);
  });

  test('doubles', () async {
    expect(await PlayxAsyncPrefs.maybeGetDouble('d'), isNull);
    expect(await PlayxAsyncPrefs.getDouble('d'), -1);
    expect(await PlayxAsyncPrefs.getDouble('d', fallback: 0.5), 0.5);

    await PlayxAsyncPrefs.setDouble('d', 1.5);
    expect(await PlayxAsyncPrefs.maybeGetDouble('d'), 1.5);
    expect(await PlayxAsyncPrefs.getDouble('d'), 1.5);
  });

  test('bools', () async {
    expect(await PlayxAsyncPrefs.maybeGetBool('b'), isNull);
    expect(await PlayxAsyncPrefs.getBool('b'), isFalse);
    expect(await PlayxAsyncPrefs.getBool('b', fallback: true), isTrue);

    await PlayxAsyncPrefs.setBool('b', true);
    expect(await PlayxAsyncPrefs.maybeGetBool('b'), isTrue);
    await PlayxAsyncPrefs.setBool('b', false);
    expect(await PlayxAsyncPrefs.getBool('b', fallback: true), isFalse);
  });

  test('a value of another type reads as null or the fallback', () async {
    await PlayxAsyncPrefs.setString('s', 'text');
    expect(await PlayxAsyncPrefs.maybeGetInt('s'), isNull);
    expect(await PlayxAsyncPrefs.getInt('s', fallback: 3), 3);
    expect(await PlayxAsyncPrefs.maybeGetDouble('s'), isNull);
    expect(await PlayxAsyncPrefs.maybeGetBool('s'), isNull);
  });

  test('find, remove and clear', () async {
    expect(await PlayxAsyncPrefs.find('k'), isNull);

    await PlayxAsyncPrefs.setInt('k', 5);
    await PlayxAsyncPrefs.setString('other', 'x');
    expect(await PlayxAsyncPrefs.find('k'), 5);

    await PlayxAsyncPrefs.remove('k');
    expect(await PlayxAsyncPrefs.find('k'), isNull);
    expect(await PlayxAsyncPrefs.maybeGetString('other'), 'x');

    await PlayxAsyncPrefs.clear();
    expect(await PlayxAsyncPrefs.maybeGetString('other'), isNull);
  });

  test('setMockInitialValues is available for tests', () {
    // ignore: invalid_use_of_protected_member
    PlayxAsyncPrefs.setMockInitialValues({'a': 'b'});
  });
}
