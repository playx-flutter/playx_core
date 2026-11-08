import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../crypto/secure_cipher.dart';
import '../secure_log.dart';
import '../settings/secure_storage_type.dart';
import 'secure_storage_backend.dart';
import 'secure_storage_journal.dart';

/// Returns a healthy backend of [type], or `null` if it is unavailable.
typedef SecureBackendProvider =
    Future<PlayxSecureStorageBackend?> Function(PlayxSecureStorageType type);

/// Wraps the backend selected by [PlayxSecureStorageType.auto] and keeps the
/// [SecureStorageJournal] up to date.
class AutoSecureStorageBackend implements PlayxSecureStorageBackend {
  /// The backend in use this session.
  final PlayxSecureStorageBackend active;

  /// The preferred backend (first of the auto order).
  final PlayxSecureStorageType preferred;

  /// `null` when preferences are unavailable: the journal is then disabled.
  final SharedPreferencesAsync? _prefs;

  /// `null` when the journal couldn't be loaded; moving data is then skipped
  /// for this session so a valid journal is never overwritten.
  SecureStorageJournal? _journal;

  /// Whether the journal is saved encrypted, to hide the key names it holds.
  final bool _encryptJournal;

  Future<void> _queue = Future.value();

  static const journalKey = '_playx_secure_storage_journal_';
  static const _journalKeyName = '_playx_secure_storage_journal_key_';

  AutoSecureStorageBackend._(
    this.active,
    this.preferred,
    this._prefs,
    this._encryptJournal,
  );

  /// Creates the backend and moves pending fallback data into [active].
  static Future<AutoSecureStorageBackend> create({
    required PlayxSecureStorageBackend active,
    required PlayxSecureStorageType preferred,
    required SecureBackendProvider backendProvider,
    SharedPreferencesAsync? prefs,
    bool encryptJournal = false,
  }) async {
    final backend = AutoSecureStorageBackend._(
      active,
      preferred,
      prefs,
      encryptJournal,
    );
    await backend._recover(backendProvider);
    return backend;
  }

  String get _activeName => active.type.name;

  bool get _isFallback => active.type != preferred;

  bool get _isTracking =>
      _journal != null && (_isFallback || !_journal!.isEmpty);

  Future<void> _recover(SecureBackendProvider backendProvider) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final SecureStorageJournal journal;
    try {
      journal = await _loadJournal(prefs);
    } catch (e, s) {
      secureLogError('Secure storage journal unavailable', e, s);
      return;
    }
    _journal = journal;

    // Memory holds nothing to recover into.
    if (active.type != PlayxSecureStorageType.memory) {
      try {
        await _applyPendingChanges(journal, backendProvider);
      } catch (e, s) {
        secureLogError('Failed to move data from fallback storage', e, s);
      }
    }

    if (_isFallback &&
        active.type != PlayxSecureStorageType.memory &&
        !journal.pendingStores.contains(_activeName)) {
      journal.pendingStores.add(_activeName);
    }
    if (journal.pendingStores.isEmpty && journal.pendingClear.isEmpty) {
      // All removals have been applied to the preferred backend.
      journal.lastWriter.clear();
    }
    await _saveJournal();
  }

  Future<void> _applyPendingChanges(
    SecureStorageJournal journal,
    SecureBackendProvider backendProvider,
  ) async {
    // 1. A clear() happened while this backend was unreachable.
    if (journal.pendingClear.remove(_activeName)) {
      await active.clear();
      await _saveJournal();
    }

    // 2. Removals (and values lost with a memory session) it missed.
    final memoryName = PlayxSecureStorageType.memory.name;
    for (final MapEntry(:key, :value) in journal.lastWriter.entries.toList()) {
      if (value == null || value == memoryName) await active.delete(key);
    }

    // 3. Move values from reachable fallback backends, oldest first.
    for (final storeName in journal.pendingStores.toList()) {
      if (storeName == _activeName) continue;
      final type = PlayxSecureStorageType.values.asNameMap()[storeName];
      final source = type == null ? null : await backendProvider(type);
      if (source == null) continue;

      var moved = 0;
      if (!journal.pendingClear.remove(storeName)) {
        for (final MapEntry(:key, :value) in (await source.readAll()).entries) {
          // Skip values overwritten or removed later in another backend.
          if (journal.lastWriter[key] != storeName) continue;
          await active.write(key, value);
          journal.lastWriter[key] = _activeName;
          moved++;
        }
      }
      await source.clear();
      journal.pendingStores.remove(storeName);
      await _saveJournal();
      secureLog('Moved $moved value(s) from $storeName to $_activeName.');
    }
  }

  Future<SecureStorageJournal> _loadJournal(
    SharedPreferencesAsync prefs,
  ) async {
    final stored = await prefs.getString(journalKey);
    if (stored == null) return SecureStorageJournal();
    final String json;
    if (stored.startsWith('{')) {
      json = stored;
    } else {
      final cipher = await _journalCipher(prefs, create: false);
      final parts = stored.split(':');
      if (cipher == null || parts.length != 2) {
        throw StateError('Encrypted journal cannot be read.');
      }
      json = utf8.decode(
        await cipher.decrypt(base64Decode(parts[0]), base64Decode(parts[1])),
      );
    }
    return SecureStorageJournal.fromJson(jsonDecode(json));
  }

  SecureCipher? _cachedJournalCipher;

  Future<SecureCipher?> _journalCipher(
    SharedPreferencesAsync prefs, {
    required bool create,
  }) async {
    if (_cachedJournalCipher != null) return _cachedJournalCipher;
    final stored = await prefs.getString(_journalKeyName);
    if (stored != null) {
      return _cachedJournalCipher = RawKeySecureCipher(base64Decode(stored));
    }
    if (!create) return null;
    final key = secureRandomBytes(secureKeyLength);
    await prefs.setString(_journalKeyName, base64Encode(key));
    return _cachedJournalCipher = RawKeySecureCipher(key);
  }

  Future<String> _encodeJournal(
    SharedPreferencesAsync prefs,
    SecureStorageJournal journal,
  ) async {
    final json = jsonEncode(journal.toJson());
    if (!_encryptJournal) return json;
    final cipher = (await _journalCipher(prefs, create: true))!;
    final nonce = secureRandomBytes(secureNonceLength);
    final cipherText = await cipher.encrypt(
      nonce,
      Uint8List.fromList(utf8.encode(json)),
    );
    return '${base64Encode(nonce)}:${base64Encode(cipherText)}';
  }

  Future<void> _saveJournal() async {
    final journal = _journal;
    final prefs = _prefs;
    if (journal == null || prefs == null) return;
    try {
      if (journal.isEmpty) {
        await prefs.remove(journalKey);
      } else {
        await prefs.setString(journalKey, await _encodeJournal(prefs, journal));
      }
    } catch (e, s) {
      secureLogError('Failed to save secure storage journal', e, s);
    }
  }

  /// Runs [operation] after the previous one so journal updates don't interleave.
  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  @override
  PlayxSecureStorageType get type => active.type;

  @override
  Future<String?> read(String key) => active.read(key);

  @override
  Future<Map<String, String>> readAll() => active.readAll();

  @override
  Future<void> write(String key, String value) => _serialized(() async {
    if (_isTracking) {
      _journal!.lastWriter[key] = _activeName;
      await _saveJournal();
    }
    await active.write(key, value);
  });

  @override
  Future<void> delete(String key) => _serialized(() async {
    if (_isTracking) {
      _journal!.lastWriter[key] = null;
      await _saveJournal();
    }
    await active.delete(key);
  });

  @override
  Future<void> clear() => _serialized(() async {
    final journal = _journal;
    if (_isTracking && journal != null) {
      journal.pendingClear
        ..clear()
        ..add(preferred.name)
        ..addAll(journal.pendingStores)
        ..remove(_activeName)
        ..remove(PlayxSecureStorageType.memory.name);
      journal.lastWriter.clear();
      await _saveJournal();
    }
    await active.clear();
  });
}
