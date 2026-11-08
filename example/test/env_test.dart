import 'package:example/env_page.dart';
import 'package:example/generated/playx_secure_env.g.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(PlayxEnv.dispose);

  test('loads .env and the encrypted .env.secrets', () async {
    await PlayxEnv.load(envSettings);

    expect(PlayxEnv.loadedFiles, ['.env']);
    expect(PlayxEnv.getString('API_URL'), 'https://dev.example.com/api');
    expect(PlayxEnv.getBool('ENABLE_LOGS'), isTrue);
    expect(
      PlayxEnv.getEnum(
        'THEME_MODE',
        ThemeMode.values,
        fallback: ThemeMode.system,
      ),
      ThemeMode.light,
    );

    expect(PlayxEnv.getString('STRIPE_KEY'), 'pk_test_demo_51HxExample');
    expect(PlayxEnv.isSecure('STRIPE_KEY'), isTrue);
    expect(PlayxEnv.all.containsKey('STRIPE_KEY'), isFalse);
  });

  test('prod overrides the base values', () async {
    await PlayxEnv.load(
      const PlayxEnvSettings(environment: 'prod', secureEnv: playxSecureEnv),
    );

    expect(PlayxEnv.loadedFiles, ['.env', '.env.prod']);
    expect(PlayxEnv.getString('API_URL'), 'https://api.example.com/api');
    expect(
      PlayxEnv.getDuration('TIMEOUT', fallback: Duration.zero),
      const Duration(seconds: 10),
    );
    final features = PlayxEnv.getObject(
      'FEATURES',
      fromJson: FeatureFlags.fromJson,
      fallback: const FeatureFlags(),
    );
    expect(features.newCheckout, isTrue);
    expect(features.maxUploads, 10);
  });

  test('dev switches to the dark theme', () async {
    await PlayxEnv.load(
      const PlayxEnvSettings(environment: 'dev', secureEnv: playxSecureEnv),
    );
    expect(PlayxEnv.getString('APP_NAME'), 'Playx Core (dev)');
    expect(
      PlayxEnv.getEnum(
        'THEME_MODE',
        ThemeMode.values,
        fallback: ThemeMode.system,
      ),
      ThemeMode.dark,
    );
  });
}
