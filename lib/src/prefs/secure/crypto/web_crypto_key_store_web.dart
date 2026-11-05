import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../../crypto/secure_cipher.dart';

const _databaseName = 'playx_secure_storage';
const _storeName = 'keys';
const _keyId = 'primary';
const _hashKeyId = 'names';

/// Reads the non-extractable AES-GCM key from IndexedDB.
///
/// Returns `null` if no key has been created yet. Throws if IndexedDB is
/// unavailable (e.g. blocked by the browser).
Future<SecureCipher?> readWebCryptoKey() async {
  final key = await _readKey(_keyId);
  if (key == null) return null;
  // The hashing key is generated with the encryption key; create it if a
  // database predates it.
  final hashKey = await _readKey(_hashKeyId) ?? await _createHashKey();
  return _WebCryptoSecureCipher(key, hashKey);
}

Future<web.CryptoKey?> _readKey(String id) async {
  final database = await _openDatabase();
  try {
    final transaction = database.transaction(_storeName.toJS, 'readonly');
    final result = await _complete(
      transaction.objectStore(_storeName).get(id.toJS),
    );
    if (result == null || result.isUndefinedOrNull) return null;
    return result as web.CryptoKey;
  } finally {
    database.close();
  }
}

Future<void> _storeKey(String id, web.CryptoKey key) async {
  final database = await _openDatabase();
  try {
    final transaction = database.transaction(_storeName.toJS, 'readwrite');
    await _complete(transaction.objectStore(_storeName).put(key, id.toJS));
  } finally {
    database.close();
  }
}

/// Generates a non-extractable HMAC-SHA256 key used to hide key names.
Future<web.CryptoKey> _createHashKey() async {
  final algorithm = JSObject()
    ..setProperty('name'.toJS, 'HMAC'.toJS)
    ..setProperty('hash'.toJS, 'SHA-256'.toJS)
    ..setProperty('length'.toJS, 256.toJS);
  final key =
      await web.window.crypto.subtle
              .generateKey(algorithm, false, ['sign'.toJS].toJS)
              .toDart
          as web.CryptoKey;
  await _storeKey(_hashKeyId, key);
  return key;
}

/// Generates a **non-extractable** AES-GCM key and stores it in IndexedDB.
///
/// The browser keeps the key material: JavaScript (including this app, devtools
/// or injected scripts) can use the key while the page runs, but can never read
/// or export its bytes.
Future<SecureCipher> createWebCryptoKey() async {
  final algorithm = JSObject()
    ..setProperty('name'.toJS, 'AES-GCM'.toJS)
    ..setProperty('length'.toJS, 256.toJS);
  final key =
      await web.window.crypto.subtle
              .generateKey(
                algorithm,
                false,
                ['encrypt'.toJS, 'decrypt'.toJS].toJS,
              )
              .toDart
          as web.CryptoKey;

  await _storeKey(_keyId, key);
  final hashKey = await _createHashKey();
  return _WebCryptoSecureCipher(key, hashKey);
}

Future<web.IDBDatabase> _openDatabase() {
  final completer = Completer<web.IDBDatabase>();
  final request = web.window.indexedDB.open(_databaseName, 1);
  request.onupgradeneeded = ((web.Event _) {
    (request.result as web.IDBDatabase).createObjectStore(_storeName);
  }).toJS;
  request.onsuccess = ((web.Event _) {
    completer.complete(request.result as web.IDBDatabase);
  }).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      StateError('Failed to open IndexedDB: ${request.error?.message}'),
    );
  }).toJS;
  request.onblocked = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(StateError('IndexedDB open is blocked.'));
    }
  }).toJS;
  return completer.future;
}

Future<JSAny?> _complete(web.IDBRequest request) {
  final completer = Completer<JSAny?>();
  request.onsuccess = ((web.Event _) => completer.complete(
    request.result,
  )).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      StateError('IndexedDB request failed: ${request.error?.message}'),
    );
  }).toJS;
  return completer.future;
}

class _WebCryptoSecureCipher implements SecureCipher {
  final web.CryptoKey _key;
  final web.CryptoKey _hashKey;

  _WebCryptoSecureCipher(this._key, this._hashKey);

  @override
  Future<Uint8List> keyedHash(Uint8List data) async {
    final result = await web.window.crypto.subtle
        .sign('HMAC'.toJS, _hashKey, data.toJS)
        .toDart;
    return (result as JSArrayBuffer).toDart.asUint8List();
  }

  JSObject _algorithm(Uint8List nonce) => JSObject()
    ..setProperty('name'.toJS, 'AES-GCM'.toJS)
    ..setProperty('iv'.toJS, nonce.toJS)
    ..setProperty('tagLength'.toJS, 128.toJS);

  @override
  Future<Uint8List> encrypt(Uint8List nonce, Uint8List plainText) async {
    final result = await web.window.crypto.subtle
        .encrypt(_algorithm(nonce), _key, plainText.toJS)
        .toDart;
    return (result as JSArrayBuffer).toDart.asUint8List();
  }

  @override
  Future<Uint8List> decrypt(Uint8List nonce, Uint8List cipherText) async {
    final result = await web.window.crypto.subtle
        .decrypt(_algorithm(nonce), _key, cipherText.toJS)
        .toDart;
    return (result as JSArrayBuffer).toDart.asUint8List();
  }
}
