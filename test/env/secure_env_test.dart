import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/env/secure/secure_env_codec.dart';
import 'package:playx_core/src/env/secure/secure_env_loader.dart';

void mockAssets(Map<String, String> files) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        final content = files[Uri.decodeFull(key)];
        if (content == null) return null;
        return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final key = generateSecureEnvKey();
  final keyBase64 = base64Encode(key);

  Future<PlayxSecureEnvData> secureEnv(
    Map<String, String> values, {
    String? environment,
    bool embedKey = true,
  }) async => PlayxSecureEnvData(
    environment: environment,
    key: embedKey ? PlayxEnvKey.base64(keyBase64) : null,
    data: await encryptSecureEnv(values, key),
  );

  setUp(() async {
    await PlayxEnv.dispose();
    mockAssets({});
  });

  group('codec', () {
    test('round-trips and uses a new nonce each time', () async {
      final values = {'A': '1', 'B': 'with spaces = and "quotes"'};
      final first = await encryptSecureEnv(values, key);
      final second = await encryptSecureEnv(values, key);
      expect(first, isNot(second));
      expect(await decryptSecureEnv(first, key), values);
    });

    test('rejects tampered data and wrong keys', () async {
      final data = await encryptSecureEnv({'A': '1'}, key);
      final tampered = Uint8List.fromList(data)..[data.length - 1] ^= 1;
      await expectLater(decryptSecureEnv(tampered, key), throwsA(anything));
      await expectLater(
        decryptSecureEnv(data, generateSecureEnvKey()),
        throwsA(anything),
      );
    });

    test('encodes defines and keys', () async {
      final data = await encryptSecureEnv({'A': '1'}, key);
      expect(decodeSecureDefine(encodeSecureDefine(data)), data);
      expect(() => decodeSecureDefine('garbage'), throwsFormatException);
      expect(decodeSecureEnvKey(keyBase64), key);
      expect(() => decodeSecureEnvKey('c2hvcnQ='), throwsFormatException);
    });

    test('PlayxEnvKey.parts XORs its parts', () {
      final mask = generateSecureEnvKey();
      final masked = [for (var i = 0; i < key.length; i++) key[i] ^ mask[i]];
      expect(PlayxEnvKey.parts(mask, masked).bytes, key);
      expect(PlayxEnvKey.base64(keyBase64).bytes, key);
      expect(
        () => const PlayxEnvKey.parts([1], [1, 2]).bytes,
        throwsFormatException,
      );
    });
  });

  group('PlayxEnv', () {
    test('serves secure values alongside .env values', () async {
      mockAssets({'.env': 'API_URL=https://api.example.com'});
      await PlayxEnv.load(
        PlayxEnvSettings(
          useSecureDefines: false,
          secureEnv: await secureEnv({'STRIPE_KEY': 'pk_9'}),
        ),
      );
      expect(PlayxEnv.getString('API_URL'), 'https://api.example.com');
      expect(PlayxEnv.getString('STRIPE_KEY'), 'pk_9');
      expect(PlayxEnv.isSecure('STRIPE_KEY'), isTrue);
      expect(PlayxEnv.isSecure('API_URL'), isFalse);
    });

    test('hides secure values from all', () async {
      mockAssets({'.env': 'API_URL=https://api.example.com'});
      await PlayxEnv.load(
        PlayxEnvSettings(
          useSecureDefines: false,
          secureEnv: await secureEnv({'STRIPE_KEY': 'pk_9'}),
        ),
      );
      expect(PlayxEnv.all, {'API_URL': 'https://api.example.com'});
      expect(PlayxEnv.values.all.containsKey('STRIPE_KEY'), isFalse);
      expect(PlayxEnv.containsKey('STRIPE_KEY'), isTrue);
    });

    test('secure values override files; defines override them', () async {
      mockAssets({'.env': 'A=file\nB=file\nC=file'});
      await PlayxEnv.load(
        PlayxEnvSettings(
          useSecureDefines: false,
          secureEnv: await secureEnv({'B': 'secure', 'C': 'secure'}),
          dartDefines: const {'C': 'define'},
        ),
      );
      expect(PlayxEnv.getString('A'), 'file');
      expect(PlayxEnv.getString('B'), 'secure');
      expect(PlayxEnv.getString('C'), 'define');
    });

    test('works with requiredKeys and typed getters', () async {
      await PlayxEnv.load(
        PlayxEnvSettings(
          useSecureDefines: false,
          secureEnv: await secureEnv({'RETRIES': '3'}),
          requiredKeys: const ['RETRIES'],
        ),
      );
      expect(PlayxEnv.getInt('RETRIES'), 3);
    });

    test('throws when the data cannot be decrypted', () async {
      final data = PlayxSecureEnvData(
        key: PlayxEnvKey.base64(base64Encode(generateSecureEnvKey())),
        data: await encryptSecureEnv({'A': '1'}, key),
      );
      await expectLater(
        PlayxEnv.load(
          PlayxEnvSettings(useSecureDefines: false, secureEnv: data),
        ),
        throwsA(isA<PlayxEnvException>()),
      );
    });

    test('loads normally without secure values', () async {
      mockAssets({'.env': 'A=1'});
      await PlayxEnv.load(
        const PlayxEnvSettings(
          useSecureDefines: false,
          secureEnv: PlayxSecureEnvData(),
        ),
      );
      expect(PlayxEnv.getInt('A'), 1);
    });
  });

  group('SecureEnvLoader', () {
    test('uses the PLAYX_ENV_KEY define when no key is embedded', () async {
      final settings = PlayxEnvSettings(
        secureEnv: await secureEnv({'A': '1'}, embedKey: false),
      );
      expect(
        await SecureEnvLoader.load(
          settings,
          secureDefines: '',
          keyDefine: keyBase64,
        ),
        {'A': '1'},
      );
    });

    test('prefers the embedded key over the define', () async {
      final settings = PlayxEnvSettings(secureEnv: await secureEnv({'A': '1'}));
      final otherKey = base64Encode(generateSecureEnvKey());
      expect(
        await SecureEnvLoader.load(
          settings,
          secureDefines: '',
          keyDefine: otherKey,
        ),
        {'A': '1'},
      );
    });

    test('throws without a key', () async {
      final settings = PlayxEnvSettings(
        secureEnv: await secureEnv({'A': '1'}, embedKey: false),
      );
      await expectLater(
        SecureEnvLoader.load(settings, secureDefines: '', keyDefine: ''),
        throwsA(isA<PlayxEnvException>()),
      );
    });

    test('PLAYX_SECURE_DEFINES overrides generated values', () async {
      final settings = PlayxEnvSettings(
        secureEnv: await secureEnv({'A': 'file', 'B': 'file'}),
      );
      final define = encodeSecureDefine(
        await encryptSecureEnv({'B': 'define'}, key),
      );
      expect(await SecureEnvLoader.load(settings, secureDefines: define), {
        'A': 'file',
        'B': 'define',
      });

      final disabled = PlayxEnvSettings(
        secureEnv: settings.secureEnv,
        useSecureDefines: false,
      );
      expect(await SecureEnvLoader.load(disabled, secureDefines: define), {
        'A': 'file',
        'B': 'file',
      });
    });

    test('decrypts a define with only a key-only generated file', () async {
      final settings = PlayxEnvSettings(
        secureEnv: PlayxSecureEnvData(key: PlayxEnvKey.base64(keyBase64)),
      );
      final define = encodeSecureDefine(
        await encryptSecureEnv({'A': '1'}, key),
      );
      expect(await SecureEnvLoader.load(settings, secureDefines: define), {
        'A': '1',
      });
    });

    test('loads values generated for another environment', () async {
      final settings = PlayxEnvSettings(
        secureEnv: await secureEnv({'A': '1'}, environment: 'prod'),
      );
      expect(
        await SecureEnvLoader.load(
          settings,
          secureDefines: '',
          environment: 'dev',
        ),
        {'A': '1'},
      );
    });
  });

  group('build defines', () {
    const keyDefine = String.fromEnvironment('PLAYX_ENV_KEY');
    const secureDefines = String.fromEnvironment('PLAYX_SECURE_DEFINES');

    test(
      'reads PLAYX_ENV_KEY and PLAYX_SECURE_DEFINES',
      () async {
        // Run with --dart-define=PLAYX_ENV_KEY=<key>
        // --dart-define=PLAYX_SECURE_DEFINES=<value of `secure_env define`>
        // where the define contains PD_SECRET=define.
        await PlayxEnv.load(
          const PlayxEnvSettings(secureEnv: PlayxSecureEnvData()),
        );
        expect(PlayxEnv.getString('PD_SECRET'), 'define');
        expect(PlayxEnv.isSecure('PD_SECRET'), isTrue);
      },
      skip: keyDefine.isEmpty || secureDefines.isEmpty
          ? 'Run with PLAYX_ENV_KEY and PLAYX_SECURE_DEFINES defines'
          : false,
    );
  });

  group('malformed keys', () {
    test('an invalid embedded key throws a PlayxEnvException', () async {
      final settings = PlayxEnvSettings(
        secureEnv: PlayxSecureEnvData(
          key: const PlayxEnvKey.base64('%%% not base64'),
          data: await encryptSecureEnv({'A': '1'}, key),
        ),
      );
      await expectLater(
        SecureEnvLoader.load(settings, secureDefines: ''),
        throwsA(
          isA<PlayxEnvException>().having(
            (e) => e.message,
            'message',
            contains('malformed'),
          ),
        ),
      );
    });

    test('a key of the wrong length throws a PlayxEnvException', () async {
      final settings = PlayxEnvSettings(
        secureEnv: PlayxSecureEnvData(
          key: PlayxEnvKey.base64(base64Encode(Uint8List(16))),
          data: await encryptSecureEnv({'A': '1'}, key),
        ),
      );
      // The embedded key is accepted as raw bytes by the cipher, which then
      // rejects the length: still reported as a failure to decrypt.
      await expectLater(
        SecureEnvLoader.load(settings, secureDefines: ''),
        throwsA(isA<PlayxEnvException>()),
      );
    });

    test(
      'an invalid PLAYX_ENV_KEY define throws a PlayxEnvException',
      () async {
        final settings = PlayxEnvSettings(
          secureEnv: await secureEnv({'A': '1'}, embedKey: false),
        );
        await expectLater(
          SecureEnvLoader.load(settings, keyDefine: '%%%', secureDefines: ''),
          throwsA(isA<PlayxEnvException>()),
        );
        await expectLater(
          SecureEnvLoader.load(
            settings,
            keyDefine: base64Encode(Uint8List(8)),
            secureDefines: '',
          ),
          throwsA(isA<PlayxEnvException>()),
        );
      },
    );

    test('a corrupted define throws without leaking details', () async {
      final settings = PlayxEnvSettings(secureEnv: await secureEnv({'A': '1'}));
      await expectLater(
        SecureEnvLoader.load(settings, secureDefines: 'v1:not-base64!'),
        throwsA(
          isA<PlayxEnvException>().having(
            (e) => e.toString(),
            'toString',
            isNot(contains('not-base64')),
          ),
        ),
      );
    });
  });
}
