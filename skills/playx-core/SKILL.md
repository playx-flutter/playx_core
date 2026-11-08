---
name: playx-core
description: Use when a Flutter app uses or should use the playx_core package: booting it, preferences (PlayxPrefs), secure storage (PlayxSecurePrefs), environment config (PlayxEnv, .env files, secure env), logging (PlayxLogger), or its extensions and utilities. Gives the correct API and avoids 1.x patterns.
---

# playx_core

One import: `import 'package:playx_core/playx_core.dart';`. Requires Dart 3.12 and Flutter 3.44. Full docs: https://playx-flutter.github.io/playx_core/llms-full.txt (index: `llms.txt`). If the docs and this file disagree, the docs win.

## Boot (once, before `runApp`)

```dart
WidgetsFlutterBinding.ensureInitialized();
await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(requiredKeys: ['API_URL']), // omit to skip env
);
```

Settings objects: `prefsSettings`, `securePrefsSettings`, `envSettings`, `workerManagerSettings`, `loggerSettings`. A store that was not created throws when used. `bootCore` throws on a bad env (missing `requiredKeys`). `getIt` is GetIt after boot. `PlayxCore.dispose()` in `tearDown`.

## Preferences

- `PlayxPrefs`: synchronous reads, `await` writes. `PlayxAsyncPrefs`: async reads. `PlayxPrefsWithCache`: cached.
- `PlayxPrefs.getInt('age', fallback: 18)`, `await PlayxPrefs.setString('name', 'Jane')`.
- Objects: `setObject(key, v, toJson: ...)`, `maybeGetObject(key, fromJson: ...)`.
- Tests: `PlayxPrefs.setMockInitialValues({})`.

## Secure storage

`PlayxSecurePrefs` is **always async**: `await PlayxSecurePrefs.getString('token')`. Backend: `PlayxSecurePrefsSettings(storageType: PlayxSecureStorageType.auto, encryptKeys: true)`. Use it for tokens and credentials, not `PlayxPrefs`.

## Environment (`PlayxEnv`, synchronous)

- Getters are **sync** (2.0): `PlayxEnv.getString('K')`, `getBool`, `getInt`, `getUri('API_URL', fallback: Uri())`, `getDuration('TIMEOUT', fallback: ...)`, `getEnum('MODE', Mode.values, fallback: ...)`. Never `await` them.
- Files are assets (list them in `pubspec.yaml`): `.env`, then `.env.<env>`. Pick with `--dart-define=PLAYX_ENV=prod`; override with `--dart-define=PLAYX_DEFINES="A=1,B=2"`.
- Secrets: put them in a gitignored `.env.secrets`, run `dart run playx_core:secure_env --env prod`, then `PlayxEnvSettings(secureEnv: playxSecureEnv)`. Read with the same getters. Never commit `.env.secrets*`, `.playx_secure_env.key` or the generated file (it holds the key). An app can't fully hide a secret from a determined attacker: truly critical ones belong on a server.

## Logging

`PlayxLogger.i/w/e/d/v/log(message, tag:)`; `PlayxCore.logger` is the `PLAYX CORE` logger. Configure with `PlayxLoggerSettings`: `useColors`, `printDateTime`, `printLevel`, `printLoggerName`, `level`, `formatter: const DefaultColoredLoggerFormatter()` (single lines), `target` (`debugPrint`, `stdout`, `developerLog`), `output`. Colors drop automatically where unsupported; `--dart-define=PLAYX_LOG_COLORS=false` forces them off (Android Studio Run panel).

## Extensions and utilities

Padding and borders: `16.p`, `12.borderRadius`. Context: `context.colorScheme`, `context.textTheme`, `context.crossAxisCount()`. Also String, Iterable (`chunked`), DateTime, Duration, Future, Color, Locale. Safe JSON: `asIntOr(json, 'user.age', fallback: 0)`. Also `MapUtils.mapAsync` and `*InIsolate` helpers, `ColorUtils`, `PlayxPlatform`, `WebUtils`.

## Pitfalls

- 1.x code: `await PlayxEnv.getString(...)`, named args to `PlayxEnv.load`, `PlayxEnv.instance`. All removed. See `doc/migration-2.0.md`.
- An unrecognized bool in env reads as `null`, so `getBool` returns its fallback.
- Check names against the docs before inventing an API.
