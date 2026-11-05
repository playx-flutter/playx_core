import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void mockAssets(Map<String, String> files) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        final content = files[Uri.decodeFull(key)];
        if (content == null) return null;
        return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
      });
}

const memorySecurePrefs = PlayxSecurePrefsSettings(
  storageType: PlayxSecureStorageType.memory,
  clearOnReinstall: false,
);

const noWorkers = WorkManagerSettings(initWorkerManager: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PlayxPrefs.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    mockAssets({});
  });

  tearDown(PlayxCore.dispose);

  test('getIt throws until bootCore has run', () {
    expect(() => PlayxCore.getIt, throwsException);
    expect(() => getIt, throwsException);
  });

  test('bootCore enables GetIt and the logger', () async {
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      workerManagerSettings: noWorkers,
    );

    getIt.registerSingleton<String>('service');
    expect(PlayxCore.getIt<String>(), 'service');
    expect(PlayxCore.logger, isNotNull);
    expect(PlayxLogger.hasLogger('PLAYX CORE'), isTrue);
  });

  test('bootCore creates the prefs selected by the settings', () async {
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      workerManagerSettings: noWorkers,
    );
    expect(PlayxPrefs.sharedPrefs, isA<SharedPreferences>());
    expect(PlayxAsyncPrefs.sharedPrefs, isA<SharedPreferencesAsync>());
    expect(() => PlayxPrefsWithCache.sharedPrefs, throwsException);
    expect(PlayxSecurePrefs.isInitialized, isTrue);
    expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.memory);
  });

  test('bootCore can create the cached prefs and skip the others', () async {
    await PlayxCore.bootCore(
      securePrefsSettings: const PlayxSecurePrefsSettings(
        createSecurePrefs: false,
      ),
      prefsSettings: const PlayxPrefsSettings(
        createPlayxPrefs: false,
        createPlayxAsyncPrefs: false,
        createPlayxPrefsWithCache: true,
      ),
      workerManagerSettings: noWorkers,
    );
    expect(() => PlayxPrefs.sharedPrefs, throwsException);
    expect(() => PlayxAsyncPrefs.sharedPrefs, throwsException);
    expect(PlayxPrefsWithCache.sharedPrefs, isA<SharedPreferencesWithCache>());
    expect(PlayxSecurePrefs.isInitialized, isFalse);
  });

  test('bootCore loads the env when settings are given', () async {
    mockAssets({'.env': 'API_URL=https://api.example.com\nRETRIES=3'});
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      envSettings: const PlayxEnvSettings(requiredKeys: ['API_URL']),
      workerManagerSettings: noWorkers,
    );
    expect(PlayxEnv.isLoaded, isTrue);
    expect(PlayxEnv.getString('API_URL'), 'https://api.example.com');
    expect(PlayxEnv.getInt('RETRIES'), 3);
  });

  test('bootCore does not load the env without settings', () async {
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      workerManagerSettings: noWorkers,
    );
    expect(PlayxEnv.isLoaded, isFalse);
  });

  test('bootCore fails when required env keys are missing', () async {
    mockAssets({'.env': 'A=1'});
    await expectLater(
      PlayxCore.bootCore(
        securePrefsSettings: memorySecurePrefs,
        envSettings: const PlayxEnvSettings(requiredKeys: ['MISSING']),
        workerManagerSettings: noWorkers,
      ),
      throwsA(isA<PlayxEnvException>()),
    );
  });

  test('bootCore initializes the worker manager by default', () async {
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      workerManagerSettings: const WorkManagerSettings(isolatesCount: 1),
    );
    expect(PlayxCore.getIt, isA<GetIt>());
  });

  test('dispose resets everything', () async {
    mockAssets({'.env': 'A=1'});
    await PlayxCore.bootCore(
      securePrefsSettings: memorySecurePrefs,
      prefsSettings: const PlayxPrefsSettings(createPlayxPrefsWithCache: true),
      envSettings: const PlayxEnvSettings(),
      workerManagerSettings: noWorkers,
    );
    getIt.registerSingleton<int>(1);

    await PlayxCore.dispose();

    expect(() => PlayxCore.getIt, throwsException);
    expect(() => PlayxPrefs.sharedPrefs, throwsException);
    expect(() => PlayxAsyncPrefs.sharedPrefs, throwsException);
    expect(() => PlayxPrefsWithCache.sharedPrefs, throwsException);
    expect(PlayxSecurePrefs.isInitialized, isFalse);
    expect(PlayxEnv.isLoaded, isFalse);
  });
}
