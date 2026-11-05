@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:web/web.dart' as web;

const databaseName = 'playx_secure_storage';

/// In-memory `flutter_secure_storage`, standing in for data saved by v1 on web.
class FakeFlutterSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async => data[key] = value;

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => data[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => data.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => data.remove(key);

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(data);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      data.clear();
}

Future<T> _complete<T extends JSAny?>(web.IDBRequest request) {
  final completer = Completer<T>();
  request.onsuccess = ((web.Event _) => completer.complete(
    request.result as T,
  )).toJS;
  request.onerror = ((web.Event _) => completer.completeError(
    StateError('IndexedDB request failed'),
  )).toJS;
  return completer.future;
}

Future<void> deleteDatabase() =>
    _complete<JSAny?>(web.window.indexedDB.deleteDatabase(databaseName));

/// Reads the stored CryptoKey directly, bypassing playx.
Future<web.CryptoKey> readStoredKey() async {
  final database = await _complete<web.IDBDatabase>(
    web.window.indexedDB.open(databaseName, 1),
  );
  try {
    final store = database
        .transaction('keys'.toJS, 'readonly')
        .objectStore('keys');
    return _complete<web.CryptoKey>(store.get('primary'.toJS));
  } finally {
    database.close();
  }
}

void main() {
  late FakeFlutterSecureStorage fss;
  late SharedPreferencesAsync prefs;

  Future<void> start(PlayxSecureStorageType type) async {
    await PlayxSecurePrefs.dispose();
    await PlayxSecurePrefs.create(
      securePrefsSettings: PlayxSecurePrefsSettings(
        storageType: type,
        clearOnReinstall: false,
      ),
    );
  }

  setUpAll(() => PlayxLogger.initLogger(name: 'PLAYX CORE'));

  setUp(() async {
    await deleteDatabase();
    fss = FakeFlutterSecureStorage();
    FlutterSecureStoragePlatform.instance = fss;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = SharedPreferencesAsync();
  });

  tearDown(() => PlayxSecurePrefs.dispose());

  for (final type in [
    PlayxSecureStorageType.flutterSecureStorage,
    PlayxSecureStorageType.simpleSecureStorage,
    PlayxSecureStorageType.encryptedPrefs,
    PlayxSecureStorageType.auto,
  ]) {
    test('${type.name} uses WebCrypto encrypted prefs', () async {
      await start(type);
      expect(
        PlayxSecurePrefs.storageType,
        PlayxSecureStorageType.encryptedPrefs,
      );

      await PlayxSecurePrefs.setString('token', 'super-secret');
      final raw = await prefs.getString('playx_secure_token');
      expect(raw, startsWith('p:'));
      expect(raw, isNot(contains('super-secret')));
      expect(fss.data, isEmpty);

      await start(type);
      expect(await PlayxSecurePrefs.getString('token'), 'super-secret');
    });
  }

  test('memory stays in memory', () async {
    await start(PlayxSecureStorageType.memory);
    expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
  });

  test('the key is non-extractable', () async {
    await start(PlayxSecureStorageType.auto);
    await PlayxSecurePrefs.setString('token', 'abc');

    final key = await readStoredKey();
    expect(key.extractable, isFalse);
    expect(key.algorithm.toString(), isNotEmpty);
    await expectLater(
      web.window.crypto.subtle.exportKey('raw', key).toDart,
      throwsA(anything),
    );
  });

  test('no secret is kept in preferences besides the fallback key', () async {
    await start(PlayxSecureStorageType.auto);
    await PlayxSecurePrefs.setString('token', 'abc');
    final keys = await prefs.getKeys();
    expect(
      keys,
      containsAll([
        'playx_secure_token',
        '_playx_secure_prefs_key_store_',
        '_playx_secure_prefs_fallback_key_',
      ]),
    );
    expect(
      await prefs.getString('_playx_secure_prefs_key_store_'),
      'webCrypto',
    );
  });

  test('migrates flutter_secure_storage data from v1 once', () async {
    fss.data.addAll({'token': 'abc', 'user': 'jane'});
    await start(PlayxSecureStorageType.flutterSecureStorage);

    expect(await PlayxSecurePrefs.getString('token'), 'abc');
    expect(await PlayxSecurePrefs.getString('user'), 'jane');
    expect(fss.data, isEmpty);

    // Not repeated on later starts.
    fss.data['late'] = 'x';
    await start(PlayxSecureStorageType.flutterSecureStorage);
    expect(await PlayxSecurePrefs.maybeGetString('late'), isNull);
  });
}
