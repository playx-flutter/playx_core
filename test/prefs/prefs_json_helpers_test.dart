import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class User {
  final String name;
  final int age;

  const User(this.name, this.age);

  factory User.fromJson(dynamic json) =>
      User(asString(json, 'name'), asInt(json, 'age'));

  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  @override
  bool operator ==(Object other) =>
      other is User && other.name == name && other.age == age;

  @override
  int get hashCode => Object.hash(name, age);
}

/// The JSON helpers of one prefs class, all made asynchronous.
typedef JsonPrefs = ({
  Future<void> Function() setUp,
  Future<void> Function(String key, String value) setString,
  Future<void> Function(String key, Map<String, dynamic> value) setMap,
  Future<Map<String, dynamic>?> Function(String key) maybeGetMap,
  Future<Map<String, dynamic>> Function(
    String key,
    Map<String, dynamic> fallback,
  )
  getMap,
  Future<void> Function(String key, List<int> value) setInts,
  Future<List<int>?> Function(String key) maybeGetInts,
  Future<List<int>> Function(String key, List<int> fallback) getInts,
  Future<void> Function(String key, List<User> value) setUsers,
  Future<List<User>?> Function(String key) maybeGetUsers,
  Future<void> Function(String key, User value) setUser,
  Future<User?> Function(String key) maybeGetUser,
  Future<User> Function(String key, User fallback) getUser,
});

void runJsonHelperTests(String name, JsonPrefs prefs) {
  group('$name JSON helpers', () {
    setUp(prefs.setUp);

    test('stores and reads maps', () async {
      final value = {
        'id': 1,
        'name': 'Jane',
        'tags': ['a', 'b'],
        'nested': {'enabled': true, 'ratio': 1.5},
      };
      await prefs.setMap('map', value);
      expect(await prefs.maybeGetMap('map'), value);
      expect(await prefs.maybeGetMap('missing'), isNull);
      expect(await prefs.getMap('missing', {'x': 1}), {'x': 1});
    });

    test('stores and reads lists', () async {
      await prefs.setInts('ints', [1, 2, 3]);
      expect(await prefs.maybeGetInts('ints'), [1, 2, 3]);
      expect(await prefs.maybeGetInts('missing'), isNull);
      expect(await prefs.getInts('missing', [9]), [9]);

      const users = [User('Jane', 30), User('John', 25)];
      await prefs.setUsers('users', users);
      expect(await prefs.maybeGetUsers('users'), users);

      // Objects with a toJson() method are encoded without a converter.
      await prefs.setMap('withModel', {'user': const User('Jane', 30)});
      expect(await prefs.maybeGetMap('withModel'), {
        'user': {'name': 'Jane', 'age': 30},
      });
    });

    test('stores and reads objects', () async {
      await prefs.setUser('user', const User('Jane', 30));
      expect(await prefs.maybeGetUser('user'), const User('Jane', 30));
      expect(await prefs.maybeGetUser('missing'), isNull);
      expect(
        await prefs.getUser('missing', const User('Guest', 0)),
        const User('Guest', 0),
      );
    });

    test('returns null for invalid JSON', () async {
      await prefs.setString('bad', 'not json {');
      expect(await prefs.maybeGetMap('bad'), isNull);
      expect(await prefs.maybeGetInts('bad'), isNull);
      expect(await prefs.maybeGetUser('bad'), isNull);
    });

    test('returns null for values of another shape', () async {
      await prefs.setInts('ints', [1, 2]);
      expect(await prefs.maybeGetMap('ints'), isNull);
      expect(await prefs.maybeGetUser('ints'), isNull);

      await prefs.setMap('map', {'a': 1});
      expect(await prefs.maybeGetInts('map'), isNull);
      expect(await prefs.maybeGetUser('map'), isNull);

      await prefs.setString('strings', '["a", "b"]');
      expect(await prefs.maybeGetInts('strings'), isNull);
      expect(await prefs.getInts('strings', [0]), [0]);
    });

    test('throws for values that cannot be encoded', () async {
      expect(
        () => prefs.setMap('map', {'when': DateTime(2020)}),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> useInMemoryAsyncPrefs() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  }

  runJsonHelperTests('PlayxPrefs', (
    setUp: () async {
      PlayxPrefs.setMockInitialValues({});
      await PlayxPrefs.create();
    },
    setString: PlayxPrefs.setString,
    setMap: PlayxPrefs.setMap,
    maybeGetMap: (k) async => PlayxPrefs.maybeGetMap(k),
    getMap: (k, f) async => PlayxPrefs.getMap(k, fallback: f),
    setInts: PlayxPrefs.setList<int>,
    maybeGetInts: (k) async => PlayxPrefs.maybeGetList<int>(k),
    getInts: (k, f) async => PlayxPrefs.getList<int>(k, fallback: f),
    setUsers: (k, v) => PlayxPrefs.setList(k, v, toJson: (u) => u.toJson()),
    maybeGetUsers: (k) async =>
        PlayxPrefs.maybeGetList(k, fromJson: User.fromJson),
    setUser: (k, v) => PlayxPrefs.setObject(k, v, toJson: (u) => u.toJson()),
    maybeGetUser: (k) async =>
        PlayxPrefs.maybeGetObject(k, fromJson: User.fromJson),
    getUser: (k, f) async =>
        PlayxPrefs.getObject(k, fromJson: User.fromJson, fallback: f),
  ));

  runJsonHelperTests('PlayxAsyncPrefs', (
    setUp: () async {
      await useInMemoryAsyncPrefs();
      await PlayxAsyncPrefs.create();
    },
    setString: PlayxAsyncPrefs.setString,
    setMap: PlayxAsyncPrefs.setMap,
    maybeGetMap: PlayxAsyncPrefs.maybeGetMap,
    getMap: (k, f) => PlayxAsyncPrefs.getMap(k, fallback: f),
    setInts: PlayxAsyncPrefs.setList<int>,
    maybeGetInts: PlayxAsyncPrefs.maybeGetList<int>,
    getInts: (k, f) => PlayxAsyncPrefs.getList<int>(k, fallback: f),
    setUsers: (k, v) =>
        PlayxAsyncPrefs.setList(k, v, toJson: (u) => u.toJson()),
    maybeGetUsers: (k) =>
        PlayxAsyncPrefs.maybeGetList(k, fromJson: User.fromJson),
    setUser: (k, v) =>
        PlayxAsyncPrefs.setObject(k, v, toJson: (u) => u.toJson()),
    maybeGetUser: (k) =>
        PlayxAsyncPrefs.maybeGetObject(k, fromJson: User.fromJson),
    getUser: (k, f) =>
        PlayxAsyncPrefs.getObject(k, fromJson: User.fromJson, fallback: f),
  ));

  runJsonHelperTests('PlayxPrefsWithCache', (
    setUp: () async {
      await useInMemoryAsyncPrefs();
      await PlayxPrefsWithCache.create();
    },
    setString: PlayxPrefsWithCache.setString,
    setMap: PlayxPrefsWithCache.setMap,
    maybeGetMap: (k) async => PlayxPrefsWithCache.maybeGetMap(k),
    getMap: (k, f) async => PlayxPrefsWithCache.getMap(k, fallback: f),
    setInts: PlayxPrefsWithCache.setList<int>,
    maybeGetInts: (k) async => PlayxPrefsWithCache.maybeGetList<int>(k),
    getInts: (k, f) async => PlayxPrefsWithCache.getList<int>(k, fallback: f),
    setUsers: (k, v) =>
        PlayxPrefsWithCache.setList(k, v, toJson: (u) => u.toJson()),
    maybeGetUsers: (k) async =>
        PlayxPrefsWithCache.maybeGetList(k, fromJson: User.fromJson),
    setUser: (k, v) =>
        PlayxPrefsWithCache.setObject(k, v, toJson: (u) => u.toJson()),
    maybeGetUser: (k) async =>
        PlayxPrefsWithCache.maybeGetObject(k, fromJson: User.fromJson),
    getUser: (k, f) async =>
        PlayxPrefsWithCache.getObject(k, fromJson: User.fromJson, fallback: f),
  ));

  runJsonHelperTests('PlayxSecurePrefs', (
    setUp: () async {
      await PlayxSecurePrefs.dispose();
      await PlayxSecurePrefs.create(
        securePrefsSettings: const PlayxSecurePrefsSettings(
          storageType: PlayxSecureStorageType.memory,
          clearOnReinstall: false,
        ),
      );
    },
    setString: PlayxSecurePrefs.setString,
    setMap: PlayxSecurePrefs.setMap,
    maybeGetMap: PlayxSecurePrefs.maybeGetMap,
    getMap: (k, f) => PlayxSecurePrefs.getMap(k, fallback: f),
    setInts: PlayxSecurePrefs.setList<int>,
    maybeGetInts: PlayxSecurePrefs.maybeGetList<int>,
    getInts: (k, f) => PlayxSecurePrefs.getList<int>(k, fallback: f),
    setUsers: (k, v) =>
        PlayxSecurePrefs.setList(k, v, toJson: (u) => u.toJson()),
    maybeGetUsers: (k) =>
        PlayxSecurePrefs.maybeGetList(k, fromJson: User.fromJson),
    setUser: (k, v) =>
        PlayxSecurePrefs.setObject(k, v, toJson: (u) => u.toJson()),
    maybeGetUser: (k) =>
        PlayxSecurePrefs.maybeGetObject(k, fromJson: User.fromJson),
    getUser: (k, f) =>
        PlayxSecurePrefs.getObject(k, fromJson: User.fromJson, fallback: f),
  ));
}
