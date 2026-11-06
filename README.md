# PlayX Core
[![pub package](https://img.shields.io/pub/v/playx_core.svg?color=1284C5)](https://pub.dev/packages/playx_core)  
[![Build](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml) <a href="https://codecov.io/gh/playx-flutter/playx_core"><img src="https://codecov.io/gh/playx-flutter/playx_core/branch/main/graph/badge.svg" alt="codecov"></a>  
<a href="https://github.com/playx-flutter/playx_core/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

The core of the [PlayX](https://pub.dev/packages/playx) ecosystem: one package for the building blocks most Flutter apps need, with a consistent, null-safe, easy-to-test API.

## Features

| | |
| --- | --- |
| **[Preferences](doc/preferences.md)** | `PlayxPrefs`, `PlayxAsyncPrefs` and `PlayxPrefsWithCache`: typed key-value storage, plus maps, lists and objects as JSON. |
| **[Secure preferences](doc/secure-prefs.md)** | `PlayxSecurePrefs`: encrypted storage with a choice of backends (`flutter_secure_storage`, `simple_secure_storage`, AES-encrypted preferences), an `auto` mode that falls back when a plugin fails, hidden key names, and WebCrypto on web. |
| **[Environment configuration](doc/env.md)** | `PlayxEnv`: `.env` files, per-environment and per-flavor files, `--dart-define` values, typed getters, required keys. |
| **[Secure env](doc/secure-env.md)** | Keep API keys and other sensitive values out of plain sight: a command encrypts them into your app, with CI/CD support. |
| **[Extensions](doc/extensions.md)** | Helpers for `String`, `Iterable`, `DateTime`, `Duration`, `Color`, `Locale`, `BuildContext`, padding, borders and radius. |
| **[Utilities](doc/utilities.md)** | Safe type conversion and JSON access, `MapUtils` (optionally in isolates), system UI, clipboard, platform checks, `WebUtils`. |
| **[Logging](doc/logging.md)** | `PlayxLogger`: named loggers, levels and pluggable backends. |
| **Dependency injection** | `GetIt` is re-exported and ready after `PlayxCore.bootCore`. |

## Installation

Requires Dart 3.12+ and Flutter 3.44+.

```yaml
dependencies:
  playx_core: ^2.0.0
```

```dart
import 'package:playx_core/playx_core.dart';
```

> Coming from 1.x? Read the [migration guide](doc/migration-2.0.md).

## Quick start

Boot the core once, before `runApp`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlayxCore.bootCore(
    // Optional: load configuration from .env files (see below).
    envSettings: const PlayxEnvSettings(requiredKeys: ['API_URL']),
  );

  runApp(const MyApp());
}
```

`bootCore` creates the stores you ask for through settings objects (`prefsSettings`, `securePrefsSettings`, `envSettings`, `workerManagerSettings`). See [Getting started](doc/getting-started.md).

### Preferences

```dart
await PlayxPrefs.setString('name', 'Jane');
final name = PlayxPrefs.getString('name');                       // synchronous read
final age = PlayxPrefs.getInt('age', fallback: 18);

await PlayxPrefs.setObject('user', user, toJson: (u) => u.toJson());
final saved = PlayxPrefs.maybeGetObject('user', fromJson: User.fromJson);
```

Three stores share one API: `PlayxPrefs` (synchronous reads), `PlayxAsyncPrefs` (always the latest platform value) and `PlayxPrefsWithCache`. [Learn more](doc/preferences.md).

### Secure preferences

```dart
await PlayxSecurePrefs.setString('access_token', token);
final token = await PlayxSecurePrefs.getString('access_token');
```

Choose where the data lives, and let `auto` fall back when a plugin fails on a device:

```dart
await PlayxCore.bootCore(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
    encryptKeys: true,          // also hide key names such as "access_token"
  ),
);
```

[Learn more](doc/secure-prefs.md), including [switching an existing app](doc/secure-prefs.md#switching-an-existing-app-from-flutter_secure_storage).

### Environment configuration

```
# .env                            # .env.prod
API_URL=https://api.example.com   API_URL=https://api.prod.example.com
TIMEOUT=30s
```

```yaml
# pubspec.yaml
flutter:
  assets: [.env, .env.prod]
```

```dart
final apiUrl = PlayxEnv.getUri('API_URL', fallback: Uri());
final timeout = PlayxEnv.getDuration('TIMEOUT', fallback: const Duration(seconds: 30));
final debug = PlayxEnv.getBool('DEBUG');
```

```sh
flutter run --dart-define=PLAYX_ENV=prod                      # loads .env, then .env.prod
flutter run --dart-define=PLAYX_DEFINES="DEBUG=true"          # overrides at build time
```

Values from the base file, the environment (or `--flavor`) file and build-time defines are merged, later sources winning. [Learn more](doc/env.md).

### Secure env

Put sensitive values in a gitignored `.env.secrets` and encrypt them into your app:

```sh
dart run playx:secure_env --env prod      # or: dart run playx_core:secure_env
```

```dart
import 'generated/playx_secure_env.g.dart';

await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(secureEnv: playxSecureEnv),
);
PlayxEnv.getString('STRIPE_KEY');         // decrypted in memory; hidden from PlayxEnv.all
```

Works in CI/CD too (Codemagic, GitHub Actions, Vercel). Anything an app can decrypt on its own can be extracted by a determined attacker, so [read what it does and doesn't protect](doc/secure-env.md#what-it-protects-and-what-it-doesnt).

### Extensions and utilities

```dart
'jane doe'.capitalizedInitialChar;                       // 'J'
[1, 2, 3, 4, 5].chunked(2);                              // [[1, 2], [3, 4], [5]]
DateTime.now().startOfWeek();
Container(padding: 16.p, decoration: BoxDecoration(borderRadius: 12.borderRadius));
GridView.count(crossAxisCount: context.crossAxisCount(), children: items);

final age = asIntOr(json, 'user.age', fallback: 0);      // safe nested JSON access
```

See [Extensions](doc/extensions.md) and [Utilities](doc/utilities.md).

## Documentation

Read it online at **[playx-flutter.github.io/playx_core](https://playx-flutter.github.io/playx_core/)**, with search and the API reference, or browse the guides here:

| Guide | |
| --- | --- |
| [Getting started](doc/getting-started.md) | Requirements, `bootCore`, GetIt, disposing |
| [Preferences](doc/preferences.md) | The three stores, typed getters, maps, lists and objects |
| [Secure preferences](doc/secure-prefs.md) | Backends, `auto`, key names, web, migration, failures |
| [Environment configuration](doc/env.md) | Files, environments, flavors, defines, getters |
| [Secure env](doc/secure-env.md) | The `secure_env` command, CI/CD, threat model |
| [Extensions](doc/extensions.md) | Every extension, by type |
| [Utilities](doc/utilities.md) | Conversion, JSON, `MapUtils`, system UI, `WebUtils` |
| [Logging](doc/logging.md) | `PlayxLogger` |
| [Testing](doc/testing.md) | Testing your code, and this package |
| [Migrating to 2.0](doc/migration-2.0.md) | Breaking changes, with before/after code |
| [CI/CD samples](doc/ci/) | Codemagic, GitHub Actions, Vercel |

The [API reference](https://pub.dev/documentation/playx_core/latest/) covers every class and member, and the [changelog](CHANGELOG.md) lists what changed in each version.

## Example

The [example app](example/) is a runnable project using preferences and environment configuration with environments, build-time defines and secure env.

## Support and contribution

For questions, issues, or feature requests, please visit the [GitHub repository](https://github.com/playx-flutter/playx_core). Contributions are welcome!

```sh
dart format .                # CI checks formatting with a pinned Flutter version
flutter analyze lib test
flutter test                 # unit tests
flutter test --coverage      # with coverage
```

## See also

- [Playx](https://pub.dev/packages/playx): The PlayX ecosystem for redundant features, reduced code, and improved productivity.
- [Playx_theme](https://pub.dev/packages/playx_theme): Multi-theme features for Flutter apps.
- [Playx_localization](https://pub.dev/packages/playx_localization): Localization and internationalization for Flutter apps.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/playx-flutter/playx_core/blob/main/LICENSE) file for details.
