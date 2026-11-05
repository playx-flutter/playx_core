@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/env/secure/secure_env_codec.dart';
import 'package:playx_core/src/env/secure/secure_env_loader.dart';

void main() {
  test('decrypts generated secure env values on web', () async {
    final key = generateSecureEnvKey();
    final mask = generateSecureEnvKey();
    final settings = PlayxEnvSettings(
      useSecureDefines: false,
      secureEnv: PlayxSecureEnvData(
        key: PlayxEnvKey.parts(mask, [
          for (var i = 0; i < key.length; i++) key[i] ^ mask[i],
        ]),
        data: await encryptSecureEnv({'STRIPE_KEY': 'pk_9'}, key),
      ),
    );
    expect(await SecureEnvLoader.load(settings), {'STRIPE_KEY': 'pk_9'});

    final define = encodeSecureDefine(
      await encryptSecureEnv({'STRIPE_KEY': 'define'}, key),
    );
    expect(
      await SecureEnvLoader.load(
        PlayxEnvSettings(
          secureEnv: PlayxSecureEnvData(
            key: PlayxEnvKey.base64(base64Encode(key)),
          ),
        ),
        secureDefines: define,
      ),
      {'STRIPE_KEY': 'define'},
    );
  });
}
