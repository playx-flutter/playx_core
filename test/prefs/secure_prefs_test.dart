import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart'
    show DarwinInitializationOptions;
import 'package:simple_secure_storage_platform_interface/simple_secure_storage_platform_interface.dart';

const encryptionKeyName = '_playx_secure_prefs_encryption_key_';
const fallbackKeyName = '_playx_secure_prefs_fallback_key_';
const keyStoreMarker = '_playx_secure_prefs_key_store_';
const journalKey = '_playx_secure_storage_journal_';
const missingKeyCount = '_playx_secure_prefs_missing_key_count_';

/// In-memory `simple_secure_storage` that can be configured to misbehave.
class FakeSimpleSecureStorage extends SimpleSecureStoragePlatform {
  final Map<String, String> data = {};

  /// `initialize` throws.
  bool failInitialize = false;

  /// Every read returns garbage (the health check fails).
  bool corruptReads = false;

  /// These keys look missing even though they are stored.
  final Set<String> hiddenKeys = {};

  /// The options of the last `initialize` call.
  InitializationOptions? lastOptions;

  @override
  Future<void> initialize(InitializationOptions options) async {
    lastOptions = options;
    if (failInitialize) throw Exception('Keystore unavailable');
  }

  @override
  Future<bool> has(String key) async =>
      !hiddenKeys.contains(key) && data.containsKey(key);

  @override
  Future<String?> read(String key) async {
    if (corruptReads) return 'corrupted';
    return hiddenKeys.contains(key) ? null : data[key];
  }

  @override
  Future<Map<String, String>> list() async => Map.of(data);

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);

  @override
  Future<void> clear() async => data.clear();
}

/// In-memory `flutter_secure_storage` that can be configured to fail.
class FakeFlutterSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> data = {};
  bool fail = false;

  void _check() {
    if (fail) throw Exception('flutter_secure_storage failed');
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _check();
    data[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    _check();
    return data[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    _check();
    return data.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _check();
    data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    _check();
    return Map.of(data);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _check();
    data.clear();
  }
}

/// Preferences that always throw.
final class FailingSharedPreferencesAsync
    extends SharedPreferencesAsyncPlatform {
  Never _fail() => throw Exception('Preferences unavailable');

  @override
  Future<void> setString(String k, String v, SharedPreferencesOptions o) =>
      _fail();
  @override
  Future<void> setBool(String k, bool v, SharedPreferencesOptions o) => _fail();
  @override
  Future<void> setDouble(String k, double v, SharedPreferencesOptions o) =>
      _fail();
  @override
  Future<void> setInt(String k, int v, SharedPreferencesOptions o) => _fail();
  @override
  Future<void> setStringList(
    String k,
    List<String> v,
    SharedPreferencesOptions o,
  ) => _fail();
  @override
  Future<String?> getString(String k, SharedPreferencesOptions o) => _fail();
  @override
  Future<bool?> getBool(String k, SharedPreferencesOptions o) => _fail();
  @override
  Future<double?> getDouble(String k, SharedPreferencesOptions o) => _fail();
  @override
  Future<int?> getInt(String k, SharedPreferencesOptions o) => _fail();
  @override
  Future<List<String>?> getStringList(String k, SharedPreferencesOptions o) =>
      _fail();
  @override
  Future<void> clear(
    ClearPreferencesParameters p,
    SharedPreferencesOptions o,
  ) => _fail();
  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters p,
    SharedPreferencesOptions o,
  ) => _fail();
  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters p,
    SharedPreferencesOptions o,
  ) => _fail();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSimpleSecureStorage simple;
  late FakeFlutterSecureStorage fss;
  late SharedPreferencesAsyncPlatform prefsPlatform;
  late SharedPreferencesAsync prefs;

  /// Simulates an app start.
  Future<void> start(
    PlayxSecureStorageType type, {
    List<PlayxSecureStorageType>? autoOrder,
    PlayxEncryptedPrefsOptions encryptedPrefsOptions =
        const PlayxEncryptedPrefsOptions(),
    bool throwOnError = true,
    bool clearOnReinstall = false,
    bool encryptKeys = false,
  }) async {
    await PlayxSecurePrefs.dispose();
    await PlayxSecurePrefs.create(
      securePrefsSettings: PlayxSecurePrefsSettings(
        storageType: type,
        autoOrder: autoOrder ?? const PlayxSecurePrefsSettings().autoOrder,
        encryptedPrefsOptions: encryptedPrefsOptions,
        throwOnError: throwOnError,
        clearOnReinstall: clearOnReinstall,
        encryptKeys: encryptKeys,
      ),
    );
  }

  void breakPrefs() =>
      SharedPreferencesAsyncPlatform.instance = FailingSharedPreferencesAsync();

  void restorePrefs() =>
      SharedPreferencesAsyncPlatform.instance = prefsPlatform;

  setUp(() {
    simple = FakeSimpleSecureStorage();
    SimpleSecureStoragePlatform.instance = simple;
    fss = FakeFlutterSecureStorage();
    FlutterSecureStoragePlatform.instance = fss;
    prefsPlatform = InMemorySharedPreferencesAsync.empty();
    SharedPreferencesAsyncPlatform.instance = prefsPlatform;
    prefs = SharedPreferencesAsync();
  });

  tearDown(() => PlayxSecurePrefs.dispose());

  group('general', () {
    test('throws before create() is called', () {
      expect(() => PlayxSecurePrefs.storageType, throwsException);
      expect(() => PlayxSecurePrefs.maybeGetString('a'), throwsException);
      expect(PlayxSecurePrefs.isInitialized, isFalse);
    });

    test('defaults to flutter_secure_storage without health check', () async {
      fss.fail = true;
      await PlayxSecurePrefs.create(
        securePrefsSettings: const PlayxSecurePrefsSettings(
          clearOnReinstall: false,
        ),
      );
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.flutterSecureStorage,
      );
      expect(PlayxSecurePrefs.securePrefs, isA<FlutterSecureStorage>());
    });

    test('flutter_secure_storage reads and writes', () async {
      await start(PlayxSecureStorageType.flutterSecureStorage);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(fss.data['token'], 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
      await PlayxSecurePrefs.clear();
      expect(fss.data, isEmpty);
    });

    test('works when no preferences implementation is registered', () async {
      SharedPreferencesAsyncPlatform.instance = null;
      await start(PlayxSecureStorageType.flutterSecureStorage);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);

      simple.failInitialize = true;
      fss.fail = true;
      await start(PlayxSecureStorageType.auto);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
    });

    test('memory keeps values for the session only', () async {
      await start(PlayxSecureStorageType.memory);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');

      await start(PlayxSecureStorageType.memory);
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
    });
  });

  group('throwOnError', () {
    test('true rethrows storage errors', () async {
      await start(PlayxSecureStorageType.flutterSecureStorage);
      fss.fail = true;
      await expectLater(PlayxSecurePrefs.setString('a', '1'), throwsException);
      await expectLater(PlayxSecurePrefs.maybeGetString('a'), throwsException);
    });

    test('false logs errors and returns fallbacks', () async {
      await start(
        PlayxSecureStorageType.flutterSecureStorage,
        throwOnError: false,
      );
      fss.fail = true;
      await PlayxSecurePrefs.setString('a', '1');
      await PlayxSecurePrefs.remove('a');
      await PlayxSecurePrefs.clear();
      expect(await PlayxSecurePrefs.maybeGetString('a'), isNull);
      expect(await PlayxSecurePrefs.getInt('a', fallback: 7), 7);
    });

    test('false uses memory when the backend cannot be created', () async {
      simple.failInitialize = true;
      await start(
        PlayxSecureStorageType.simpleSecureStorage,
        throwOnError: false,
      );
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
    });
  });

  group('simpleSecureStorage', () {
    test('reads, writes, removes and clears values', () async {
      await start(PlayxSecureStorageType.simpleSecureStorage);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.simpleSecureStorage,
      );

      await PlayxSecurePrefs.setString('token', 'abc');
      await PlayxSecurePrefs.setInt('count', 3);
      await PlayxSecurePrefs.setBool('flag', true);
      await PlayxSecurePrefs.setDouble('ratio', 1.5);

      expect(simple.data['token'], 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
      expect(await PlayxSecurePrefs.getInt('count'), 3);
      expect(await PlayxSecurePrefs.getBool('flag'), isTrue);
      expect(await PlayxSecurePrefs.getDouble('ratio'), 1.5);
      expect(await PlayxSecurePrefs.maybeGetString('missing'), isNull);

      await PlayxSecurePrefs.remove('token');
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);

      await PlayxSecurePrefs.clear();
      expect(simple.data, isEmpty);
    });

    test('rethrows initialization errors', () async {
      simple.failInitialize = true;
      await expectLater(
        start(PlayxSecureStorageType.simpleSecureStorage),
        throwsException,
      );
    });
  });

  group('encryptedPrefs', () {
    test('stores encrypted, prefixed values', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'super-secret');

      final raw = await prefs.getString('playx_secure_token');
      expect(raw, startsWith('p:'));
      expect(raw, isNot(contains('super-secret')));
      expect(await prefs.getString('token'), isNull);
      expect(await PlayxSecurePrefs.getString('token'), 'super-secret');
    });

    test('uses a random nonce for every write', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('a', 'same');
      await PlayxSecurePrefs.setString('b', 'same');

      expect(
        await prefs.getString('playx_secure_a'),
        isNot(await prefs.getString('playx_secure_b')),
      );
    });

    test('keeps the key in simple_secure_storage', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');

      expect(simple.data[encryptionKeyName], isNotNull);
      expect(await prefs.getString(keyStoreMarker), 'simpleSecureStorage');

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('keeps the key in flutter_secure_storage if simple fails', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');

      expect(fss.data[encryptionKeyName], isNotNull);
      expect(await prefs.getString(keyStoreMarker), 'flutterSecureStorage');
      expect(await prefs.getString('playx_secure_token'), startsWith('p:'));

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('does not trust a key store that fails its health check', () async {
      simple.corruptReads = true;
      fss.fail = true;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');

      expect(simple.data[encryptionKeyName], isNull);
      expect(await prefs.getString(keyStoreMarker), isNull);
      expect(await prefs.getString('playx_secure_token'), startsWith('f:'));
    });

    test('fallback values stay readable once a key store works', () async {
      simple.failInitialize = true;
      fss.fail = true;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('old', '1');
      expect(await prefs.getString(fallbackKeyName), isNotNull);

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('new', '2');

      expect(await prefs.getString(keyStoreMarker), 'simpleSecureStorage');
      expect(await prefs.getString('playx_secure_new'), startsWith('p:'));
      expect(await PlayxSecurePrefs.getString('old'), '1');
      expect(await PlayxSecurePrefs.getString('new'), '2');
    });

    test('never overwrites a key that reads back missing', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('a', '1');
      final storedKey = simple.data[encryptionKeyName];

      // The key store is healthy but the key looks missing this session.
      simple.hiddenKeys.add(encryptionKeyName);
      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(simple.data[encryptionKeyName], storedKey);
      expect(await PlayxSecurePrefs.maybeGetString('a'), isNull);
      await PlayxSecurePrefs.setString('b', '2');

      simple.hiddenKeys.clear();
      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(simple.data[encryptionKeyName], storedKey);
      expect(await PlayxSecurePrefs.getString('a'), '1');
      expect(await PlayxSecurePrefs.getString('b'), '2');
    });

    test('never overwrites a key when its store is unavailable', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('a', '1');
      final storedKey = simple.data[encryptionKeyName];

      simple.failInitialize = true;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('b', '2');
      expect(fss.data[encryptionKeyName], isNull);

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(simple.data[encryptionKeyName], storedKey);
      expect(await PlayxSecurePrefs.getString('a'), '1');
      expect(await PlayxSecurePrefs.getString('b'), '2');
    });

    test('creates a new key at once if none of the data needs it', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      final storedKey = simple.data[encryptionKeyName];

      simple.data.remove(encryptionKeyName);
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');

      expect(simple.data[encryptionKeyName], isNot(storedKey));
      expect(await prefs.getString('playx_secure_token'), startsWith('p:'));
    });

    test('recreates a key missing for several starts in a row', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('lost', '1');

      // E.g. the Android Keystore was reset: the key is gone for good.
      simple.data.remove(encryptionKeyName);
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('kept', '2');
      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(simple.data[encryptionKeyName], isNull);
      expect(await prefs.getInt(missingKeyCount), 2);

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(simple.data[encryptionKeyName], isNotNull);
      expect(await prefs.getInt(missingKeyCount), isNull);
      expect(await prefs.getString('playx_secure_lost'), isNull);
      expect(await PlayxSecurePrefs.getString('kept'), '2');
      await PlayxSecurePrefs.setString('new', '3');
      expect(await prefs.getString('playx_secure_new'), startsWith('p:'));
    });

    test('reads the key from a store removed from keyStores', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(fss.data[encryptionKeyName], isNotNull);

      simple.failInitialize = false;
      await start(
        PlayxSecureStorageType.encryptedPrefs,
        encryptedPrefsOptions: const PlayxEncryptedPrefsOptions(
          keyStores: [PlayxSecureStorageType.simpleSecureStorage],
        ),
      );
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
      expect(simple.data[encryptionKeyName], isNull);
    });

    test('returns null for tampered values', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');
      final raw = (await prefs.getString('playx_secure_token'))!;
      final parts = raw.split(':');
      final tampered = '${parts[0]}:${parts[1]}:A${parts[2].substring(1)}';
      await prefs.setString('playx_secure_token', tampered);
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);

      await prefs.setString('playx_secure_bad', 'not-a-payload');
      expect(await PlayxSecurePrefs.maybeGetString('bad'), isNull);
    });

    test('clear() only removes secure values', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await prefs.setString('unrelated', 'keep me');
      await PlayxSecurePrefs.setString('token', 'abc');

      await PlayxSecurePrefs.clear();

      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
      expect(await prefs.getString('unrelated'), 'keep me');
      expect(await prefs.getString(fallbackKeyName), isNotNull);
      expect(await prefs.getString(keyStoreMarker), isNotNull);
      expect(simple.data[encryptionKeyName], isNotNull);
    });

    test('uses memory when preferences are unavailable', () async {
      breakPrefs();
      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });
  });

  group('encryptKeys', () {
    Future<void> startHidden([
      PlayxSecureStorageType type = PlayxSecureStorageType.encryptedPrefs,
    ]) => start(type, encryptKeys: true);

    Future<List<String>> secureKeys() async => (await prefs.getKeys())
        .where((k) => k.startsWith('playx_secure_'))
        .toList();

    test('hides key names', () async {
      await startHidden();
      await PlayxSecurePrefs.setString('access_token', 'abc');

      final keys = await secureKeys();
      expect(keys, hasLength(1));
      expect(keys.single, isNot(contains('access_token')));
      expect(await prefs.getString(keys.single), startsWith('P:'));
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');

      await startHidden();
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
      expect(await secureKeys(), keys);
    });

    test('overwrites, removes and clears', () async {
      await startHidden();
      await PlayxSecurePrefs.setString('a', '1');
      await PlayxSecurePrefs.setString('a', '2');
      expect(await secureKeys(), hasLength(1));
      expect(await PlayxSecurePrefs.getString('a'), '2');

      await PlayxSecurePrefs.remove('a');
      expect(await secureKeys(), isEmpty);
      expect(await PlayxSecurePrefs.maybeGetString('a'), isNull);

      await PlayxSecurePrefs.setString('b', '1');
      await PlayxSecurePrefs.clear();
      expect(await secureKeys(), isEmpty);
    });

    test('the newest value wins after a fallback session', () async {
      await startHidden();
      await PlayxSecurePrefs.setString('token', 'A');

      simple.hiddenKeys.add(encryptionKeyName);
      await startHidden();
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
      await PlayxSecurePrefs.setString('token', 'B');

      simple.hiddenKeys.clear();
      await startHidden();
      expect(await PlayxSecurePrefs.getString('token'), 'B');
      final keys = await secureKeys();
      expect(keys, hasLength(1));
      expect(await prefs.getString(keys.single), startsWith('P:'));
    });

    test('a removal during a fallback session wins', () async {
      await startHidden();
      await PlayxSecurePrefs.setString('token', 'A');

      simple.hiddenKeys.add(encryptionKeyName);
      await startHidden();
      await PlayxSecurePrefs.remove('token');

      simple.hiddenKeys.clear();
      await startHidden();
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
      expect(await secureKeys(), isEmpty);
    });

    test('removals leave nothing behind without hidden entries', () async {
      simple.failInitialize = true;
      fss.fail = true;
      await startHidden();
      await PlayxSecurePrefs.setString('a', '1');
      await PlayxSecurePrefs.remove('a');
      expect(await secureKeys(), isEmpty);
    });

    test('turning it on converts existing values', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('access_token', 'abc');
      expect(await secureKeys(), ['playx_secure_access_token']);

      await startHidden();
      final keys = await secureKeys();
      expect(keys, hasLength(1));
      expect(keys.single, isNot(contains('access_token')));
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
    });

    test('turning it off converts values back', () async {
      await startHidden();
      await PlayxSecurePrefs.setString('access_token', 'abc');

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(await secureKeys(), ['playx_secure_access_token']);
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');

      // And on again.
      await PlayxSecurePrefs.setString('access_token', 'newer');
      await startHidden();
      expect(await PlayxSecurePrefs.getString('access_token'), 'newer');
      expect(await secureKeys(), hasLength(1));
    });

    test('auto hides names in its journal and still moves data', () async {
      simple.failInitialize = true;
      fss.fail = true;
      await startHidden(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.encryptedPrefs,
      );
      await PlayxSecurePrefs.setString('access_token', 'B');

      final journal = await prefs.getString(journalKey);
      expect(journal, isNotNull);
      expect(journal, isNot(contains('access_token')));
      for (final key in await prefs.getKeys()) {
        expect(key, isNot(contains('access_token')));
      }

      simple.failInitialize = false;
      await startHidden(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.simpleSecureStorage,
      );
      expect(await PlayxSecurePrefs.getString('access_token'), 'B');
      expect(await secureKeys(), isEmpty);
      expect(await prefs.getString(journalKey), isNull);
    });
  });

  group('encryptKeys with flutter_secure_storage', () {
    const hashKey = '_playx_secure_key_names_key_';

    Future<void> startFss({bool encryptKeys = true}) => start(
      PlayxSecureStorageType.flutterSecureStorage,
      encryptKeys: encryptKeys,
    );

    Iterable<String> storedNames() => fss.data.keys.where((k) => k != hashKey);

    test('hides key names on Android', () async {
      await startFss();
      await PlayxSecurePrefs.setString('access_token', 'abc');

      expect(fss.data[hashKey], isNotNull);
      expect(storedNames(), hasLength(1));
      expect(storedNames().single, isNot(contains('access_token')));
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');

      await startFss();
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
      await PlayxSecurePrefs.remove('access_token');
      expect(storedNames(), isEmpty);
    });

    test('does not touch storage until first used', () async {
      fss.data['access_token'] = 'abc';
      await startFss();
      expect(fss.data, {'access_token': 'abc'});

      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
      expect(fss.data.containsKey('access_token'), isFalse);
    });

    test('keeps names on other platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await startFss();
      await PlayxSecurePrefs.setString('access_token', 'abc');
      expect(fss.data, {'access_token': 'abc'});
    });

    test('turning it off restores plain names', () async {
      await startFss();
      await PlayxSecurePrefs.setString('access_token', 'abc');

      await startFss(encryptKeys: false);
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
      expect(fss.data, {'access_token': 'abc'});
    });

    test('recovers if the hashing key is lost', () async {
      await startFss();
      await PlayxSecurePrefs.setString('access_token', 'abc');
      final before = storedNames().single;

      fss.data.remove(hashKey);
      await startFss();
      expect(await PlayxSecurePrefs.getString('access_token'), 'abc');
      expect(storedNames(), hasLength(1));
      expect(storedNames().single, isNot(before));
    });

    test('clear() resets the hashing key', () async {
      await startFss();
      await PlayxSecurePrefs.setString('a', '1');
      await PlayxSecurePrefs.clear();
      expect(fss.data, isEmpty);

      await PlayxSecurePrefs.setString('b', '2');
      expect(await PlayxSecurePrefs.getString('b'), '2');
    });

    test('keeps the encrypted prefs key under its own name', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.encryptedPrefs, encryptKeys: true);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(fss.data[encryptionKeyName], isNotNull);

      await start(PlayxSecureStorageType.encryptedPrefs, encryptKeys: true);
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('auto moves hidden flutter_secure_storage values back', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.auto, encryptKeys: true);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.flutterSecureStorage,
      );
      await PlayxSecurePrefs.setString('access_token', 'B');
      expect(fss.data.keys, isNot(contains('access_token')));

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.auto, encryptKeys: true);
      expect(await PlayxSecurePrefs.getString('access_token'), 'B');
      expect(storedNames(), isEmpty);
    });

    test('migrateFromFlutterSecureStorage reads hidden names', () async {
      await startFss();
      await PlayxSecurePrefs.setString('user', 'jane');

      await start(PlayxSecureStorageType.simpleSecureStorage);
      expect(await PlayxSecurePrefs.migrateFromFlutterSecureStorage(), 1);
      expect(await PlayxSecurePrefs.getString('user'), 'jane');
      expect(storedNames(), isEmpty);
    });
  });

  group('migrateFromFlutterSecureStorage', () {
    test('copies values and keeps newer ones', () async {
      fss.data.addAll({'token': 'old', 'user': 'jane', encryptionKeyName: 'k'});
      await start(PlayxSecureStorageType.simpleSecureStorage);
      await PlayxSecurePrefs.setString('token', 'new');

      expect(await PlayxSecurePrefs.migrateFromFlutterSecureStorage(), 1);
      expect(await PlayxSecurePrefs.getString('token'), 'new');
      expect(await PlayxSecurePrefs.getString('user'), 'jane');
      expect(simple.data.containsKey(encryptionKeyName), isFalse);
      // Internal keys are left in place.
      expect(fss.data, {encryptionKeyName: 'k'});

      expect(await PlayxSecurePrefs.migrateFromFlutterSecureStorage(), 0);
    });

    test('can keep the source values', () async {
      fss.data['user'] = 'jane';
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.migrateFromFlutterSecureStorage(
        deleteFromSource: false,
      );
      expect(await PlayxSecurePrefs.getString('user'), 'jane');
      expect(fss.data['user'], 'jane');
    });

    test('does nothing when already using flutter_secure_storage', () async {
      fss.data['user'] = 'jane';
      await start(PlayxSecureStorageType.flutterSecureStorage);
      expect(await PlayxSecurePrefs.migrateFromFlutterSecureStorage(), 0);
      expect(fss.data['user'], 'jane');
    });

    test('respects throwOnError', () async {
      await start(PlayxSecureStorageType.simpleSecureStorage);
      fss.fail = true;
      await expectLater(
        PlayxSecurePrefs.migrateFromFlutterSecureStorage(),
        throwsException,
      );

      await start(
        PlayxSecureStorageType.simpleSecureStorage,
        throwOnError: false,
      );
      expect(await PlayxSecurePrefs.migrateFromFlutterSecureStorage(), 0);
    });
  });

  group('clearOnReinstall', () {
    test('clears once, without PlayxPrefs being created', () async {
      SharedPreferences.setMockInitialValues({});
      simple.data['stale'] = 'from a previous install';

      await start(
        PlayxSecureStorageType.simpleSecureStorage,
        clearOnReinstall: true,
      );
      expect(simple.data, isEmpty);

      await PlayxSecurePrefs.setString('token', 'abc');
      await start(
        PlayxSecureStorageType.simpleSecureStorage,
        clearOnReinstall: true,
      );
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('keeps data for installs flagged by previous versions', () async {
      SharedPreferences.setMockInitialValues({'hasRunBefore': true});
      simple.data['token'] = 'abc';
      await start(
        PlayxSecureStorageType.simpleSecureStorage,
        clearOnReinstall: true,
      );
      expect(simple.data['token'], 'abc');
    });
  });

  group('auto', () {
    test('uses simple_secure_storage when healthy', () async {
      await start(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.simpleSecureStorage,
      );
      expect(simple.data, isEmpty);
      expect(await prefs.getString(journalKey), isNull);
    });

    test('falls back to flutter_secure_storage', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.flutterSecureStorage,
      );
    });

    test('falls back to encrypted prefs', () async {
      simple.corruptReads = true;
      fss.fail = true;
      await start(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.encryptedPrefs,
      );
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('falls back to memory when everything fails', () async {
      simple.failInitialize = true;
      fss.fail = true;
      breakPrefs();
      await start(PlayxSecureStorageType.auto);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
      await PlayxSecurePrefs.setString('token', 'abc');
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
    });

    test('follows a custom order', () async {
      await start(
        PlayxSecureStorageType.auto,
        autoOrder: const [
          PlayxSecureStorageType.encryptedPrefs,
          PlayxSecureStorageType.simpleSecureStorage,
        ],
      );
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.encryptedPrefs,
      );
    });

    test('rejects an invalid order', () async {
      await expectLater(
        start(
          PlayxSecureStorageType.auto,
          autoOrder: const [PlayxSecureStorageType.memory],
        ),
        throwsArgumentError,
      );
    });

    test('moves fallback values back to the preferred backend', () async {
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'A');
      await PlayxSecurePrefs.setString('removed', '1');

      simple.failInitialize = true;
      await start(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.flutterSecureStorage,
      );
      await PlayxSecurePrefs.setString('token', 'B');
      await PlayxSecurePrefs.setString('added', '2');
      await PlayxSecurePrefs.remove('removed');

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.auto);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.simpleSecureStorage,
      );
      expect(await PlayxSecurePrefs.getString('token'), 'B');
      expect(await PlayxSecurePrefs.getString('added'), '2');
      expect(await PlayxSecurePrefs.maybeGetString('removed'), isNull);
      expect(fss.data, isEmpty);
      expect(await prefs.getString(journalKey), isNull);
    });

    test('moves values from encrypted prefs', () async {
      simple.failInitialize = true;
      fss.fail = true;
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'B');

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.auto);
      expect(await PlayxSecurePrefs.getString('token'), 'B');
      expect(await prefs.getString('playx_secure_token'), isNull);
    });

    test('a clear() during a fallback session is applied later', () async {
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'A');

      simple.failInitialize = true;
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.clear();
      await PlayxSecurePrefs.setString('after', '1');

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.auto);
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
      expect(await PlayxSecurePrefs.getString('after'), '1');
    });

    test('stale fallback values are not moved over newer ones', () async {
      simple.failInitialize = true;
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'B');

      // Preferred works again but the fallback is unreachable.
      simple.failInitialize = false;
      fss.fail = true;
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'C');

      fss.fail = false;
      await start(PlayxSecureStorageType.auto);
      expect(await PlayxSecurePrefs.getString('token'), 'C');
      expect(fss.data, isEmpty);
      expect(await prefs.getString(journalKey), isNull);
    });

    test('a clear() during a memory session is applied later', () async {
      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'A');

      // Everything but plain preferences fails.
      simple.failInitialize = true;
      fss.fail = true;
      await prefs.setString(fallbackKeyName, 'invalid');
      await start(PlayxSecureStorageType.auto);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
      await PlayxSecurePrefs.clear();

      simple.failInitialize = false;
      await start(PlayxSecureStorageType.auto);
      expect(await PlayxSecurePrefs.maybeGetString('token'), isNull);
    });

    test('works without a journal when preferences are broken', () async {
      await start(PlayxSecureStorageType.auto);
      breakPrefs();
      await PlayxSecurePrefs.setString('token', 'A');
      expect(await PlayxSecurePrefs.getString('token'), 'A');
      restorePrefs();
    });

    test('clear() keeps the encrypted prefs key in the store', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('enc', '1');

      await start(PlayxSecureStorageType.auto);
      await PlayxSecurePrefs.setString('token', 'A');
      await PlayxSecurePrefs.clear();
      expect(simple.data.keys, [encryptionKeyName]);

      await start(PlayxSecureStorageType.encryptedPrefs);
      expect(await PlayxSecurePrefs.getString('enc'), '1');
    });
  });

  group('settings validation', () {
    test('keyStores only accepts key stores', () async {
      await expectLater(
        start(
          PlayxSecureStorageType.encryptedPrefs,
          encryptedPrefsOptions: const PlayxEncryptedPrefsOptions(
            keyStores: [PlayxSecureStorageType.memory],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('an empty auto order is rejected', () async {
      await expectLater(
        start(PlayxSecureStorageType.auto, autoOrder: const []),
        throwsArgumentError,
      );
    });

    test('keyPrefix cannot be empty', () {
      expect(
        () => PlayxEncryptedPrefsOptions(keyPrefix: ''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('securePrefs throws before create()', () {
      expect(() => PlayxSecurePrefs.securePrefs, throwsException);
    });
  });

  group('memory backend', () {
    test('removes and clears values', () async {
      await start(PlayxSecureStorageType.memory);
      await PlayxSecurePrefs.setString('a', '1');
      await PlayxSecurePrefs.setString('b', '2');

      await PlayxSecurePrefs.remove('a');
      expect(await PlayxSecurePrefs.maybeGetString('a'), isNull);
      expect(await PlayxSecurePrefs.getString('b'), '2');

      await PlayxSecurePrefs.clear();
      expect(await PlayxSecurePrefs.maybeGetString('b'), isNull);
    });
  });

  group('simple_secure_storage options', () {
    test('are passed to the plugin', () async {
      await PlayxSecurePrefs.dispose();
      await PlayxSecurePrefs.create(
        securePrefsSettings: const PlayxSecurePrefsSettings(
          storageType: PlayxSecureStorageType.simpleSecureStorage,
          clearOnReinstall: false,
          simpleSecureStorageOptions: PlayxSimpleSecureStorageOptions(
            appName: 'My App',
            namespace: 'com.example.app',
            prefix: 'app_',
          ),
        ),
      );
      final options = simple.lastOptions!;
      expect(options.appName, 'My App');
      expect(options.namespace, 'com.example.app');
      expect(options.prefix, 'app_');
      expect(options, isNot(isA<DarwinInitializationOptions>()));
    });

    test('use the Keychain accessibility on iOS and macOS', () async {
      for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        await PlayxSecurePrefs.dispose();
        await PlayxSecurePrefs.create(
          securePrefsSettings: const PlayxSecurePrefsSettings(
            storageType: PlayxSecureStorageType.simpleSecureStorage,
            clearOnReinstall: false,
            simpleSecureStorageOptions: PlayxSimpleSecureStorageOptions(
              darwinAccessibility: DarwinAccessibility.whenUnlocked,
            ),
          ),
        );
        final options = simple.lastOptions;
        expect(options, isA<DarwinInitializationOptions>());
        expect(
          (options! as DarwinInitializationOptions).accessibility,
          DarwinAccessibility.whenUnlocked,
        );
      }
    });

    test('default to accessible after the first unlock', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await start(PlayxSecureStorageType.simpleSecureStorage);
      expect(
        (simple.lastOptions! as DarwinInitializationOptions).accessibility,
        DarwinAccessibility.afterFirstUnlock,
      );
    });
  });

  group('logging', () {
    test('failures are logged and do not break the fallback', () async {
      PlayxLogger.initLogger(name: 'PLAYX CORE');
      simple.failInitialize = true;
      fss.fail = true;
      breakPrefs();

      await start(PlayxSecureStorageType.auto);
      expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
    });
  });

  group('encrypted prefs edge cases', () {
    test('an unknown key store marker uses the fallback key', () async {
      await prefs.setString(keyStoreMarker, 'bogus');
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('token', 'abc');

      expect(await prefs.getString('playx_secure_token'), startsWith('f:'));
      expect(await PlayxSecurePrefs.getString('token'), 'abc');
      expect(simple.data[encryptionKeyName], isNull);
    });

    test(
      'an invalid key in the first store is skipped, not replaced',
      () async {
        simple.data[encryptionKeyName] = 'garbage';
        await start(PlayxSecureStorageType.encryptedPrefs);
        await PlayxSecurePrefs.setString('token', 'abc');

        expect(simple.data[encryptionKeyName], 'garbage');
        expect(fss.data[encryptionKeyName], isNotNull);
        expect(await prefs.getString(keyStoreMarker), 'flutterSecureStorage');
        expect(await prefs.getString('playx_secure_token'), startsWith('p:'));
        expect(await PlayxSecurePrefs.getString('token'), 'abc');
      },
    );

    test('an invalid key in the marked store is left untouched', () async {
      await start(PlayxSecureStorageType.encryptedPrefs);
      await PlayxSecurePrefs.setString('a', '1');

      simple.data[encryptionKeyName] = 'garbage';
      await start(PlayxSecureStorageType.encryptedPrefs);

      expect(simple.data[encryptionKeyName], 'garbage');
      expect(await prefs.getInt(missingKeyCount), 1);
      expect(await PlayxSecurePrefs.maybeGetString('a'), isNull);
      // New values use the fallback key until the primary key is back.
      await PlayxSecurePrefs.setString('b', '2');
      expect(await prefs.getString('playx_secure_b'), startsWith('f:'));
    });

    test('unreadable entries are skipped when converting key names', () async {
      await prefs.setString('playx_secure_bad', 'garbage');
      await start(PlayxSecureStorageType.encryptedPrefs, encryptKeys: true);

      await PlayxSecurePrefs.setString('a', '1');
      expect(await PlayxSecurePrefs.getString('a'), '1');
      expect(await PlayxSecurePrefs.maybeGetString('bad'), isNull);
    });

    test(
      'a plain value written after enabling encryptKeys still wins',
      () async {
        await start(PlayxSecureStorageType.encryptedPrefs);
        await PlayxSecurePrefs.setString('a', 'plain');
        final plainPayload = (await prefs.getString('playx_secure_a'))!;

        await start(PlayxSecureStorageType.encryptedPrefs, encryptKeys: true);
        expect(await PlayxSecurePrefs.getString('a'), 'plain');
        await PlayxSecurePrefs.setString('a', 'hidden');

        // A plain entry reappears, e.g. written by an older app version.
        await prefs.setString('playx_secure_a', plainPayload);
        expect(await PlayxSecurePrefs.getString('a'), 'plain');
      },
    );
  });

  group('flutter_secure_storage name hashing edge cases', () {
    const hashKey = '_playx_secure_key_names_key_';

    Future<void> startFss() =>
        start(PlayxSecureStorageType.flutterSecureStorage, encryptKeys: true);

    test(
      'an invalid hashing key is replaced and entries are re-hashed',
      () async {
        await startFss();
        await PlayxSecurePrefs.setString('a', '1');

        fss.data[hashKey] = '%%% not a key';
        await startFss();
        expect(await PlayxSecurePrefs.getString('a'), '1');
        expect(fss.data[hashKey], isNot('%%% not a key'));
        expect(fss.data[hashKey], isNotNull);
      },
    );

    test('invalid hashed entries are ignored', () async {
      fss.data['_playx_k_broken'] = 'not json';
      await startFss();

      expect(await PlayxSecurePrefs.maybeGetString('anything'), isNull);
      await PlayxSecurePrefs.setString('a', '1');
      expect(await PlayxSecurePrefs.getString('a'), '1');
      expect(fss.data['_playx_k_broken'], 'not json');
    });

    test(
      'plain and hashed entries of the same name keep the hashed value',
      () async {
        await startFss();
        await PlayxSecurePrefs.setString('a', 'hashed');
        fss.data['a'] = 'plain';

        expect(await PlayxSecurePrefs.getString('a'), 'hashed');
      },
    );
  });

  group('auto journal edge cases', () {
    test('an unreadable journal is ignored and nothing is moved', () async {
      await prefs.setString(journalKey, 'not-a-journal:payload');
      await start(PlayxSecureStorageType.auto, encryptKeys: true);

      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.simpleSecureStorage,
      );
      await PlayxSecurePrefs.setString('a', '1');
      expect(await PlayxSecurePrefs.getString('a'), '1');
      // The unreadable journal is left alone rather than overwritten.
      expect(await prefs.getString(journalKey), 'not-a-journal:payload');
    });

    test(
      'turning off key hiding for flutter_secure_storage restores names',
      () async {
        await start(
          PlayxSecureStorageType.flutterSecureStorage,
          encryptKeys: true,
        );
        await PlayxSecurePrefs.setString('a', '1');
        await PlayxSecurePrefs.setString('b', '2');
        // A plain entry of the same name written directly is kept, not replaced.
        fss.data['a'] = 'plain';

        await start(PlayxSecureStorageType.flutterSecureStorage);
        expect(await PlayxSecurePrefs.getString('a'), 'plain');
        expect(await PlayxSecurePrefs.getString('b'), '2');
        expect(fss.data.keys.where((k) => k.startsWith('_playx_k_')), isEmpty);
        expect(fss.data.containsKey('_playx_secure_key_names_key_'), isFalse);
      },
    );
  });
}
