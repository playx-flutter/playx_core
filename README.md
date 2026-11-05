
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
- **PlayxEnv:** Configure your application with global variables using a `.env` file.
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
 