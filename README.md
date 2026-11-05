
# PlayX Core
[![pub package](https://img.shields.io/pub/v/playx_core.svg?color=1284C5)](https://pub.dev/packages/playx_core)  
[![Build](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml) <a href="https://codecov.io/gh/playx-flutter/playx_core"><img src="https://codecov.io/gh/playx-flutter/playx_core/branch/main/graph/badge.svg" alt="codecov"></a>  
<a href="https://github.com/playx-flutter/playx_core/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

Core package for the PlayX ecosystem containing shared classes and utilities.

## Features

- **Dependency Injection:** Manage your dependencies using `GetIt`.
- **PlayxPrefs:** Key-value storage powered by `SharedPreferences`.
- **PlayxSecurePrefs:** Encrypted key-value storage powered by `FlutterSecureStorage`, `SimpleSecureStorage`, or AES-encrypted preferences.
- **PlayxAsyncPrefs:** Asynchronous key-value storage for non-blocking operations.
- **PlayxPrefsWithCache:** Key-value storage with caching capabilities for improved performance.
- **PlayxEnv:** Typed app configuration from `.env` files, per-environment files and flavors, and `--dart-define`.
- **bootCore Function:** Set up and initialize essential components for the PlayX ecosystem.

## Installation

Add `playx_core` to your `pubspec.yaml` dependencies:

```yaml  
dependencies:  
  playx_core: ^2.0.0 
```  

## Usage

### Boot the Core

Initialize the PlayX core in your `main` function:

```dart  
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  
  // Boot the core  
  await PlayxCore.bootCore(  
    securePrefsSettings: PlayxSecurePrefsSettings(),  
    createPlayxPrefs: true,  
    createPlayxAsyncPrefs: true,  
    createPlayxPrefsWithCache: true,  
  );  
  
  // Run the app  
  runApp(const MyApp());  
}  
```  

### Accessing GetIt

To use dependency injection, access the `GetIt` instance:

```dart  
// Register services  
getIt.registerSingleton<MyService>(MyService());  
  
// Retrieve services  
MyService myService = getIt<MyService>();  
```  

### Using Preferences

#### PlayxPrefs

Store and retrieve data using `PlayxPrefs`:

```dart  
// Store data  
PlayxPrefs.setString('name','John Doe');  
PlayxPrefs.setInt('age', 25);  
PlayxPrefs.setDouble('height', 5.8);  
  
// Retrieve data  
String name = PlayxPrefs.getString('name');  
int age = PlayxPrefs.getInt('age');  
double? height = PlayxPrefs.maybeGetDouble('height');  
```  

#### PlayxSecurePrefs

Use `PlayxSecurePrefs` for encrypted storage:

```dart  
// Store data securely  
await PlayxSecurePrefs.setString('secureName','Jane Doe');  
  
// Retrieve data securely  
String secureName = await PlayxSecurePrefs.getString('secureName');  
```  

##### Choosing a secure storage backend

`PlayxSecurePrefs` keeps the same API whatever backend you choose. Pick it with `storageType`:

| `PlayxSecureStorageType` | Backend |
| --- | --- |
| `flutterSecureStorage` (default) | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage). |
| `simpleSecureStorage` | [`simple_secure_storage`](https://pub.dev/packages/simple_secure_storage). |
| `encryptedPrefs` | `SharedPreferencesAsync` with AES-GCM. The key is generated on-device and kept in the first healthy store of `keyStores` (`simple_secure_storage`, then `flutter_secure_storage`). Falls back to `memory` if preferences are unavailable. |
| `auto` | The first backend of `autoOrder` that passes a write/read health check, then `memory`. |
| `memory` | In-memory only. Nothing survives a restart. |

```dart
await PlayxCore.bootCore(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
    // Default order. Put backends known to crash on your devices last, or remove them.
    autoOrder: [
      PlayxSecureStorageType.simpleSecureStorage,
      PlayxSecureStorageType.flutterSecureStorage,
      PlayxSecureStorageType.encryptedPrefs,
    ],
  ),
);

// The backend actually in use, e.g. after an `auto` fallback.
final type = PlayxSecurePrefs.storageType;
```

Other settings: `throwOnError` (log errors instead of throwing), `clearOnReinstall`, `flutterSecureStorageOptions`, `simpleSecureStorageOptions` and `encryptedPrefsOptions`.

##### Hiding key names

Some stores keep key names (e.g. `access_token`) readable in files, even though values are encrypted. Enable `encryptKeys` to store each value under a keyed hash of its name instead:

```dart
const PlayxSecurePrefsSettings(
  storageType: PlayxSecureStorageType.auto,
  encryptKeys: true,
);
```

| Storage | Names with `encryptKeys: true` |
| --- | --- |
| `encryptedPrefs` (all platforms, so all of web) | Hidden; only `keyPrefix` stays visible |
| `flutterSecureStorage` on Android | Hidden (otherwise plain text in a private preferences file) |
| `simpleSecureStorage` on Android | Already encrypted by the plugin |
| iOS and macOS Keychain | Kept by the OS, out of app files |
| Windows and Linux credential stores | Not hidden |

- The hash key is kept in secure storage (the keystore, or a non-extractable WebCrypto key on web), so names can't be guessed from the files alone.
- The real name is kept inside the encrypted value, so everything keeps working, including migrations.
- It can be turned on or off at any time: stored values are converted.

##### Switching an existing app from `flutter_secure_storage`

Values saved with the default backend stay in `flutter_secure_storage`. Copy them over after changing `storageType`:

```dart
await PlayxCore.bootCore(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
  ),
);
// Safe to call on every start: it does nothing once the source is empty.
await PlayxSecurePrefs.migrateFromFlutterSecureStorage();
```

Values already present in the new backend are kept. Note that this reads `flutter_secure_storage`, so it runs into any native crash that plugin has on a given device.

##### Web

On web, every type except `memory` uses encrypted prefs with a **non-extractable WebCrypto key** kept in IndexedDB. Nothing secret ships with your app: there is no password, salt or key to configure. Scripts can use the key while the page runs, but the browser never lets them read or export its bytes, so stored data can't be decrypted somewhere else.

Values saved by previous versions (which used `flutter_secure_storage` on web) are migrated automatically on the first start.

Web storage still can't protect against code running in your page (e.g. XSS) or full access to the browser profile. For auth tokens, prefer `HttpOnly` cookies set by your server.

##### How failures are handled

- **`auto` moves data back.** Values written, removed or cleared while on a fallback backend are applied to the first backend of `autoOrder` on a later start where it works again. Stale values are never moved over newer ones, and a `clear()` (e.g. logout) done during a fallback session is applied too.
- **The encryption key is kept safe.** The store holding it is remembered. If that store is unavailable, or the key reads back missing, the fallback key is used for the session and the stored key is left untouched. Only if the key stays missing for 3 starts in a row (e.g. the Android Keystore was reset) is it replaced, and the values it encrypted are removed since they can't be decrypted anymore.
- **Values stay readable.** Each value records which key encrypted it, so values written with the fallback key remain readable once the primary key is back.
- **The fallback key only obfuscates data.** It is random per device and kept in preferences.
- **Native crashes can't be caught.** Only Dart exceptions trigger a fallback, which is why `autoOrder` is configurable.

#### PlayxAsyncPrefs

For asynchronous key-value storage, use `PlayxAsyncPrefs`:

```dart  
// Store data asynchronously  
await PlayxAsyncPrefs.setString('asyncName','Async John');  
  
// Retrieve data asynchronously  
String asyncName = await PlayxAsyncPrefs.getString('asyncName');  
```  

#### PlayxPrefsWithCache

Utilize `PlayxPrefsWithCache` for caching preferences:

```dart  
// Store data with caching  
await PlayxPrefsWithCache.setString('cachedName','Cached Jane');  
  
// Retrieve data with cache  
String cachedName = await PlayxPrefsWithCache.getString('cachedName');  
```  

#### Maps, lists and objects

`PlayxPrefs`, `PlayxAsyncPrefs`, `PlayxPrefsWithCache` and `PlayxSecurePrefs` can also store maps, lists and objects. Values are saved as JSON strings (encrypted by `PlayxSecurePrefs`).

```dart
// Maps
await PlayxPrefs.setMap('settings', {'theme': 'dark', 'fontSize': 14});
final settings = PlayxPrefs.getMap('settings');

// Lists, of JSON values or with item converters
await PlayxPrefs.setList('ids', [1, 2, 3]);
final ids = PlayxPrefs.getList<int>('ids');

await PlayxAsyncPrefs.setList('users', users, toJson: (u) => u.toJson());
final users = await PlayxAsyncPrefs.getList('users', fromJson: User.fromJson);

// Objects
await PlayxSecurePrefs.setObject('user', user, toJson: (u) => u.toJson());
final user = await PlayxSecurePrefs.maybeGetObject(
  'user',
  fromJson: User.fromJson,
);
```

- `maybeGet*` returns `null` and `get*` returns its fallback when the key is missing, the stored value isn't valid JSON, has another shape, or `fromJson` throws.
- `setMap` and `setList` without `toJson` accept JSON values and objects with a `toJson()` method. Anything else throws a `JsonUnsupportedObjectError`.

### Environment configuration

See the [example app](example/) for a complete setup with environments and secure env.

`PlayxEnv` reads configuration from `.env` files (declared as assets), per-environment files and `--dart-define`:

```yaml
# pubspec.yaml
flutter:
  assets:
    - .env
    - .env.dev
    - .env.prod
```

```dart
await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(
    // Fail at startup, listing every missing key.
    requiredKeys: ['API_URL'],
    // Build-time values, overriding the files.
    dartDefines: {'SENTRY_DSN': String.fromEnvironment('SENTRY_DSN')},
  ),
);

final apiUrl = PlayxEnv.getUri('API_URL', fallback: Uri.parse('https://api.example.com'));
final timeout = PlayxEnv.getDuration('TIMEOUT', fallback: const Duration(seconds: 30));
final debug = PlayxEnv.getBool('DEBUG');
```

Values are layered, later sources overriding earlier ones:

1. `.env`
2. `.env.<environment>`. The environment comes from `environment:`, else `--dart-define=PLAYX_ENV=<name>`, else the Flutter flavor (`--flavor <name>`).
3. `additionalFiles` (e.g. `.env.local`)
4. `mergeWith`
5. `PLAYX_DEFINES` (see below)
6. `dartDefines`

Files can reference earlier values (`API_URL=https://$HOST/api`). A reference is resolved when its line is read: if `.env.prod` changes `HOST`, redefine `API_URL` there too. Missing files are logged and skipped, unless `isOptional: false`. A missing `.env.<environment>` simply leaves the `.env` values in place.

#### Build-time values (`--dart-define`)

Dart can only read a define whose name is a constant in code. Reading one by a name known only at runtime works in debug, but returns `""` in release builds and throws on web. So there are two ways to pass build-time values:

**`PLAYX_DEFINES`**: one define that playx reads for you, carrying any number of values. Nothing to declare in code:

```sh
flutter run --dart-define=PLAYX_DEFINES="DEBUG=true;API_URL=https://dev.example.com"
```

```dart
PlayxEnv.getBool('DEBUG'); // true
```

Entries use `.env` syntax, separated by `;` or new lines. For values containing `;`, pass base64-encoded `.env` content: `--dart-define=PLAYX_DEFINES=base64:$(base64 < .env.ci)`. It also works with `--dart-define-from-file=defines.json` and `{"PLAYX_DEFINES": "DEBUG=true"}`. Disable it with `usePlayxDefines: false`.

**`dartDefines`**: individual defines, declared once in the settings. Unset (empty) ones are ignored:

```sh
flutter run --dart-define=DEBUG=true
```

```dart
const PlayxEnvSettings(dartDefines: {'DEBUG': String.fromEnvironment('DEBUG')});
```

If you only need a flag in code, `const debug = bool.fromEnvironment('DEBUG');` is a compile-time constant: code behind `if (debug)` is removed from release builds, which runtime config can't do.

#### Sensitive values (secure env)

Keep normal config in `.env`, and put values that shouldn't be readable in the app in a gitignored `.env.secrets` (plus `.env.secrets.<env>` per environment). A command turns them into an encrypted Dart file:

```
# .env.secrets                 # .env.secrets.prod
STRIPE_KEY=pk_test_1           STRIPE_KEY=pk_live_9
MAPS_KEY=AIza...
```

```sh
dart run playx:secure_env --env prod
# → lib/generated/playx_secure_env.g.dart
```

> The command is `dart run playx:secure_env` in apps using `playx`, and `dart run playx_core:secure_env` in apps depending on `playx_core` only. Both take the same options; the examples below use `playx:secure_env`.

```dart
import 'generated/playx_secure_env.g.dart';

await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(secureEnv: playxSecureEnv),
);

PlayxEnv.getString('API_URL');    // from .env
PlayxEnv.getString('STRIPE_KEY'); // decrypted from the secure env
PlayxEnv.isSecure('STRIPE_KEY');  // true; secure values are excluded from PlayxEnv.all
```

- Names and values are encrypted together (AES-256-GCM) and stored as numbers, never as strings, so unzipping the app, `strings`, devtools or key scanners find nothing.
- Secure values override `.env` files; `mergeWith`, `PLAYX_DEFINES` and `dartDefines` can still override them (e.g. for local testing).
- The key is created once in `.playx_secure_env.key` and embedded in the generated file, split into two parts. Run with `--rotate-key` to replace it.
- If secure values can't be decrypted (wrong key, tampered data), `load()` throws a `PlayxEnvException`.

Add to `.gitignore`:

```
.env.secrets*
.playx_secure_env.key
lib/generated/playx_secure_env.g.dart
secure_defines.json
```

**CI/CD** (Codemagic, GitHub Actions, Vercel, …): set `PLAYX_ENV` and one `PLAYX_SECRET_<NAME>` variable per secret in the platform's settings, and run this before `flutter build`:

```sh
dart run playx:secure_env --from-env-prefix PLAYX_SECRET_
```

`PLAYX_SECRET_STRIPE_KEY` becomes `STRIPE_KEY`, and adding a secret doesn't require changing the build. You can also use `--from-env STRIPE_KEY,MAPS_KEY` or `--define KEY=VALUE`. Ready-made configs: [Codemagic](doc/ci/codemagic.yaml), [GitHub Actions](doc/ci/github-actions.yml), [Vercel](doc/ci/vercel.json) with its [build script](doc/ci/vercel-build.sh).

Other options:

- **Encrypted define**: `dart run playx:secure_env define --from-env-prefix PLAYX_SECRET_ --out secure_defines.json`, then `flutter build ... --dart-define-from-file=secure_defines.json`. The define holds only ciphertext (`PLAYX_SECURE_DEFINES`), decrypted with the same key, and overrides the generated values.
- **Key from a define**: `--key-from-define` generates a file without the key, so it can be committed, and the build passes `--dart-define=PLAYX_ENV_KEY=<key>` (create one with `dart run playx:secure_env generate-key`). Note that defines are compiled into the app as readable strings, so this keeps the key out of git, not out of the app.

Run `dart run playx:secure_env --help` for all options.

> **How secure is it?** The key ships with the app, so a determined reverse engineer can still recover the values. Secure env protects against casual inspection and automated scanners. Keys that would cause real damage if leaked belong on your server (or a serverless function that calls the third-party service for the app).

Getters are synchronous and come in `maybeGet*` (returns `null`) and `get*` (returns a fallback) forms:

| Type | Example value | Getter |
| --- | --- | --- |
| `String`, `int`, `double`, `num`, `bool` | `3`, `true`/`1` | `getString`, `getInt`, `getDouble`, `getNum`, `getBool` |
| `Uri` | `https://api.example.com` | `getUri` |
| Enum | `dark` (case-insensitive) | `getEnum(key, Mode.values, fallback: ...)` |
| `Duration` | `250ms`, `30s`, `5m`, `1.5h`, `1d` (no unit = ms) | `getDuration` |
| List | `a, b, c` or `[1, 2, 3]` | `getList<int>(key)`, `getList(key, fromJson: ...)` |
| JSON object | `{"enabled": true}` | `getMap`, `getObject(key, fromJson: ...)` |

The same getters are available on `PlayxEnv.values`, an `EnvValues`. You can also wrap any map in one, e.g. remote config: `EnvValues(remoteConfig).getBool('NEW_CHECKOUT')`.

For tests, use `PlayxEnv.loadFromString('API_URL=http://localhost')` or `PlayxEnv.setMockValues({...})`, and `PlayxEnv.dispose()` to reset.

> **Security:** `.env` files ship as plain text inside your app, and `--dart-define` values are compiled into it. Anyone with the app can read them. Use them for configuration (URLs, feature flags), and [secure env](#sensitive-values-secure-env) for sensitive values.

### Layout extensions

Unscaled helpers for padding, radius and borders. With a scaling package such as `flutter_screenutil`, scale the number first (`16.r.p`).

```dart
// Padding: all, horizontal/vertical, single sides, RTL-aware start/end
Container(padding: 16.p);
Container(padding: 8.px + 4.py);
Text('Hi').withPadding(12.ps);           // EdgeInsetsDirectional.only(start: 12)
Text('Hi').pDirectional(start: 8, end: 16);

// Radius, borders and shapes
BoxDecoration(borderRadius: 12.borderRadius, border: 1.border(Colors.grey));
Card(shape: 8.roundedShape);
Image.network(url).clipRounded(12);
Text('Hi').bordered(color: Colors.grey, radius: 8);

// Responsive grids
GridView.count(crossAxisCount: context.crossAxisCount());
```

## Documentation

For detailed documentation on using PlayX Core, visit  
the [documentation](https://pub.dev/documentation/playx_core/latest/).

## Support and Contribution

For questions, issues, or feature requests, please visit  
the [GitHub repository](https://github.com/playx-flutter/playx_core). Contributions are welcome!

## See Also

- [Playx](https://pub.dev/packages/playx): The PlayX ecosystem for redundant features, reduced code,  
  and improved productivity.
- [Playx_theme](https://pub.dev/packages/playx_theme): Multi-theme features for Flutter apps.
- [Playx_localization](https://pub.dev/packages/playx_localization): Localization and  
  internationalization for Flutter apps.

## License

This project is licensed under the MIT License - see  
the [LICENSE](https://github.com/playx-flutter/playx_core/blob/main/LICENSE) file for details.  
 