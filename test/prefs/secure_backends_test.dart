import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/prefs/secure/backends/memory_secure_storage_backend.dart';
import 'package:playx_core/src/prefs/secure/crypto/web_crypto_key_store_stub.dart';

void main() {
  group('MemorySecureStorageBackend', () {
    test('reads, writes, deletes, lists and clears values', () async {
      final backend = MemorySecureStorageBackend();
      expect(backend.type, PlayxSecureStorageType.memory);
      expect(await backend.read('a'), isNull);

      await backend.write('a', '1');
      await backend.write('b', '2');
      expect(await backend.read('a'), '1');
      expect(await backend.readAll(), {'a': '1', 'b': '2'});

      await backend.delete('a');
      expect(await backend.readAll(), {'b': '2'});

      await backend.clear();
      expect(await backend.readAll(), isEmpty);
    });

    test('readAll returns a copy', () async {
      final backend = MemorySecureStorageBackend();
      await backend.write('a', '1');
      (await backend.readAll())['a'] = 'changed';
      expect(await backend.read('a'), '1');
    });

    test('instances do not share values', () async {
      final first = MemorySecureStorageBackend();
      final second = MemorySecureStorageBackend();
      await first.write('a', '1');
      expect(await second.read('a'), isNull);
    });
  });

  group('WebCrypto key store on non-web platforms', () {
    test('is unsupported', () {
      expect(readWebCryptoKey, throwsUnsupportedError);
      expect(createWebCryptoKey, throwsUnsupportedError);
    });
  });
}
