import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/secure_prefs_settings.dart';
import 'auto_storage_backend.dart';
import 'encrypted_prefs_backend.dart';
import 'secure_log.dart';
import 'secure_storage_backend.dart';

const _autoOrderTypes = {
  PlayxSecureStorageType.simpleSecureStorage,
  PlayxSecureStorageType.flutterSecureStorage,
  PlayxSecureStorageType.encryptedPrefs,
};

const _keyStoreTypes = {
  PlayxSecureStorageType.simpleSecureStorage,
  PlayxSecureStorageType.flutterSecureStorage,
};

/// Creates the backend described by [settings].
///
/// On web, every type except [PlayxSecureStorageType.memory] uses encrypted
/// prefs with a non-extractable WebCrypto key.
///
/// Throws if [PlayxSecureStorageType.simpleSecureStorage] fails to initialize.
/// [PlayxSecureStorageType.auto] and [PlayxSecureStorageType.encryptedPrefs]
/// never throw because of an unavailable storage: they end up using
/// [PlayxSecureStorageType.memory].
Future<PlayxSecureStorageBackend> createSecureStorageBackend(
  PlayxSecurePrefsSettings settings, {
  required FlutterSecureStorage flutterSecureStorage,
  SharedPreferencesAsync? prefs,
}) async {
  _validate(settings);
  final probe = _SecureStorageProbe(settings, flutterSecureStorage, prefs);

  if (kIsWeb && settings.storageType != PlayxSecureStorageType.memory) {
    final backend = await probe(PlayxSecureStorageType.encryptedPrefs);
    if (backend != null) return backend;
    secureLog('Encrypted prefs unavailable on web, using memory storage.');
    return MemorySecureStorageBackend();
  }

  switch (settings.storageType) {
    case PlayxSecureStorageType.flutterSecureStorage:
      // No health check, to keep the behavior of previous versions.
      return FlutterSecureStorageBackend(flutterSecureStorage);

    case PlayxSecureStorageType.simpleSecureStorage:
      await SimpleSecureStorageBackend.initialize(
        settings.simpleSecureStorageOptions,
      );
      return const SimpleSecureStorageBackend();

    case PlayxSecureStorageType.memory:
      return MemorySecureStorageBackend();

    case PlayxSecureStorageType.encryptedPrefs:
      final backend = await probe(PlayxSecureStorageType.encryptedPrefs);
      if (backend != null) return backend;
      secureLog('Encrypted prefs unavailable, using memory storage.');
      return MemorySecureStorageBackend();

    case PlayxSecureStorageType.auto:
      final order = settings.autoOrder.toSet().toList();
      PlayxSecureStorageBackend? active;
      for (final type in order) {
        active = await probe(type);
        if (active != null) break;
      }
      active ??= MemorySecureStorageBackend();
      secureLog('Auto secure storage: using ${active.type.name}.');
      return AutoSecureStorageBackend.create(
        active: active,
        preferred: order.first,
        backendProvider: probe.call,
        prefs: probe.prefs,
      );
  }
}

void _validate(PlayxSecurePrefsSettings settings) {
  if (settings.storageType == PlayxSecureStorageType.auto) {
    final order = settings.autoOrder;
    if (order.isEmpty || !order.every(_autoOrderTypes.contains)) {
      throw ArgumentError.value(
        order,
        'autoOrder',
        'Must be non-empty and only contain $_autoOrderTypes',
      );
    }
  }
  final keyStores = settings.encryptedPrefsOptions.keyStores;
  if (!keyStores.every(_keyStoreTypes.contains)) {
    throw ArgumentError.value(
      keyStores,
      'keyStores',
      'Must only contain $_keyStoreTypes',
    );
  }
}

/// Creates and health checks each backend at most once per `create()`.
class _SecureStorageProbe {
  final PlayxSecurePrefsSettings settings;
  final FlutterSecureStorage flutterSecureStorage;
  final SharedPreferencesAsync? _prefsOverride;
  SharedPreferencesAsync? _prefs;
  bool _prefsResolved = false;
  final _results =
      <PlayxSecureStorageType, Future<PlayxSecureStorageBackend?>>{};

  _SecureStorageProbe(
    this.settings,
    this.flutterSecureStorage,
    this._prefsOverride,
  );

  /// Created lazily: the constructor throws when no preferences
  /// implementation is registered. `null` if unavailable.
  SharedPreferencesAsync? get prefs {
    if (!_prefsResolved) {
      _prefsResolved = true;
      try {
        _prefs = _prefsOverride ?? SharedPreferencesAsync();
      } catch (e, s) {
        secureLogError('SharedPreferencesAsync is unavailable', e, s);
      }
    }
    return _prefs;
  }

  /// Keys stored by playx in the secure stores, preserved by `clear()`.
  Set<String> get _reservedKeys => {EncryptedPrefsBackend.encryptionKeyName};

  Future<PlayxSecureStorageBackend?> call(PlayxSecureStorageType type) =>
      _results.putIfAbsent(type, () => _create(type));

  Future<PlayxSecureStorageBackend?> _create(
    PlayxSecureStorageType type,
  ) async {
    try {
      switch (type) {
        case PlayxSecureStorageType.flutterSecureStorage:
          final backend = FlutterSecureStorageBackend(
            flutterSecureStorage,
            reservedKeys: _reservedKeys,
          );
          await backend.healthCheck();
          return backend;

        case PlayxSecureStorageType.simpleSecureStorage:
          await SimpleSecureStorageBackend.initialize(
            settings.simpleSecureStorageOptions,
          );
          final backend = SimpleSecureStorageBackend(
            reservedKeys: _reservedKeys,
          );
          await backend.healthCheck();
          return backend;

        case PlayxSecureStorageType.encryptedPrefs:
          final backend = await EncryptedPrefsBackend.create(
            settings.encryptedPrefsOptions,
            keyStoreProvider: call,
            prefs:
                prefs ??
                (throw StateError('SharedPreferencesAsync is unavailable')),
          );
          await backend.healthCheck();
          return backend;

        case PlayxSecureStorageType.memory:
          return MemorySecureStorageBackend();

        case PlayxSecureStorageType.auto:
          throw ArgumentError('auto is not a concrete backend');
      }
    } catch (e, s) {
      secureLogError('${type.name} is unavailable', e, s);
      return null;
    }
  }
}
