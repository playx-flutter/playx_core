# Changelog

## 2.0.0

> Upgrading from 1.x? Follow the [migration guide](doc/migration-2.0.md). The package now has full documentation in [`doc/`](doc/README.md).

### Breaking changes

- **Minimum SDK** is now Dart `>=3.12.0 <4.0.0` and Flutter `>=3.44.0` (was Dart 3.5 / Flutter 3.24), required by `simple_secure_storage` 0.4.3.
- **`PlayxEnv` getters are synchronous.** Values are in memory after `load()`, so `await PlayxEnv.getString(...)` becomes `PlayxEnv.getString(...)`.
- **`PlayxEnv.load` takes a `PlayxEnvSettings`** instead of named arguments, and **`PlayxEnv.instance`** (flutter_dotenv's global `dotenv`) is removed in favor of `PlayxEnv.all` and `PlayxEnv.values`. `PlayxEnv` moved to `lib/src/env/`.
- **Stricter parsing in `PlayxEnv` and `PlayxSecurePrefs`.** Both use the `safe_convert` helpers: an unrecognized bool (anything but `true`/`false`/`1`/`0`) reads as `null`, so `getBool` returns its fallback instead of `false`; `"1.5"` reads as `1` for ints.
- **`PlayxSecurePrefsSettings` groups the `flutter_secure_storage` options** (`iosOptions`, `androidOptions`, `linuxOptions`, `windowsOptions`, `macOsOptions`) into `flutterSecureStorageOptions: PlayxFlutterSecureStorageOptions(...)`. `webOptions` is removed.
- **The default `AndroidOptions` no longer sets `encryptedSharedPreferences`**, which `flutter_secure_storage` 11 removed (existing Android data is migrated automatically on first access).
- **Web:** `PlayxSecurePrefs` now uses AES-GCM encrypted preferences with a **non-extractable WebCrypto key** kept in IndexedDB for every storage type except `memory`. No password, salt or key ships with the app. Data saved by 1.x with `flutter_secure_storage` is migrated automatically on the first start.
- **`WebUtils.setAppTitle` takes named arguments on the web too** (`setAppTitle(title: 'x')`), matching the non-web version. The two signatures differed, so the same call could not compile on both.

### Added

**Secure preferences** (see [Secure preferences](doc/secure-prefs.md))
- Choice of backends via `PlayxSecurePrefsSettings.storageType` (`PlayxSecureStorageType`). The default stays `flutterSecureStorage`:
  - `simpleSecureStorage`: uses [`simple_secure_storage`](https://pub.dev/packages/simple_secure_storage), configured with `PlayxSimpleSecureStorageOptions`.
  - `encryptedPrefs`: stores AES-GCM encrypted values in `SharedPreferencesAsync`, configured with `PlayxEncryptedPrefsOptions`. The key is kept in the first healthy store of `keyStores` (`simple_secure_storage`, then `flutter_secure_storage`) and is not replaced while values encrypted with it may still be readable. A per-device fallback key is used when no key store is available. Falls back to `memory` if preferences are unavailable. `clear()` only removes keys with the configured prefix.
  - `auto`: uses the first backend of `autoOrder` (default: `simple_secure_storage`, `flutter_secure_storage`, `encryptedPrefs`) that passes a health check, then `memory`. Values written, removed or cleared on a fallback backend are applied to the preferred backend once it works again.
  - `memory`: in-memory only.
- `PlayxSecurePrefsSettings.encryptKeys` (default `false`) hides key names where storage would expose them: encrypted prefs (all platforms, including web) and `flutter_secure_storage` on Android. Each value is stored under an HMAC-SHA256 of its name, keyed by a key kept in secure storage, and the name is kept inside the encrypted value. Existing values are converted when it is turned on or off. The `auto` journal is encrypted as well.
- `PlayxSecurePrefsSettings.throwOnError` (default `true`). When `false`, storage errors are logged instead of thrown, and `memory` is used if the backend can't be created.
- `PlayxSecurePrefs.migrateFromFlutterSecureStorage()` moves existing data when switching an app away from the default backend.
- `PlayxSecurePrefs.storageType`, `PlayxSecurePrefs.isInitialized` and `PlayxSecurePrefs.dispose()`. `PlayxCore.dispose()` now also disposes `PlayxSecurePrefs`.

**Environment configuration** (see [Environment configuration](doc/env.md))
- Layered configuration: `.env`, then `.env.<environment>` (from `environment`, `--dart-define=PLAYX_ENV=<name>` or the Flutter flavor), then `additionalFiles`, secure env, `mergeWith`, `PLAYX_DEFINES` and `dartDefines`. Later files can reference earlier values.
- `--dart-define` values without declaring them in code: `--dart-define=PLAYX_DEFINES="DEBUG=true;API_URL=..."` (or `base64:` encoded `.env` content) is read automatically. Disable with `usePlayxDefines: false`. `dartDefines` covers individual `--dart-define` / `--dart-define-from-file` values.
- `requiredKeys`, failing at startup with a `PlayxEnvException` listing missing keys. Missing files are logged, or throw when `isOptional` is `false`.
- New getters: `getNum`, `getUri`, `getEnum`, `getDuration`, `getList` (comma-separated or JSON), `getMap` and `getObject`, each with a `maybeGet*` variant.
- `EnvValues`: an immutable set of values with all the typed getters, exposed as `PlayxEnv.values` and usable on its own (for example for remote config).
- `isLoaded`, `environment`, `loadedFiles`, `all`, `containsKey` and `isSecure`, plus `loadFromString`, `setMockValues` and `dispose()` for tests. `PlayxCore.dispose()` now also disposes `PlayxEnv`.

**Secure env** (see [Secure env](doc/secure-env.md))
- Put sensitive values in a gitignored `.env.secrets` (or CI variables) and run `dart run playx_core:secure_env` (`dart run playx:secure_env` in apps using `playx`) to generate an encrypted Dart file, passed as `PlayxEnvSettings.secureEnv`. Names and values are encrypted with AES-256-GCM and the key is embedded split, or passed with `--dart-define=PLAYX_ENV_KEY`.
- Supports per-environment files, `--from-env`, `--from-env-prefix PLAYX_SECRET_` and `--define` for CI, and an encrypted `PLAYX_SECURE_DEFINES` define. Secure values are excluded from `PlayxEnv.all`.
- Sample Codemagic, GitHub Actions and Vercel configurations in [`doc/ci/`](doc/ci/). Generated files start with `// dart format off` so the byte lists stay compact.

**Preferences**
- JSON helpers on `PlayxPrefs`, `PlayxAsyncPrefs`, `PlayxPrefsWithCache` and `PlayxSecurePrefs` to store maps, lists and objects: `setMap`/`maybeGetMap`/`getMap`, `setList`/`maybeGetList`/`getList` (with optional `toJson`/`fromJson` item converters) and `setObject`/`maybeGetObject`/`getObject`. Invalid or mismatched stored values return `null` or the fallback.

**Extensions and utilities** (see [Extensions](doc/extensions.md) and [Utilities](doc/utilities.md))
- Padding: `PlayxNumPaddingExtensions` on `num` (`p`, `px`, `py`, `pAll`, `pLR`, `pTB`, `pZero`, single-side `pt`, `pb`, `pl`, `pr`, and RTL-aware `ps`/`pe` as `EdgeInsetsDirectional`) and `PlayxWidgetPaddingExtensions` on `Widget` (`withPadding`, `pAll`, `pSymmetric`, `pOnly`, `pDirectional`, `pZero`), returning `Padding`. Values are unscaled; scale the number first (`16.r.p`) when using a scaling package.
- Border extensions (`border_extensions.dart`): `radius`, `ellipticalRadius`, `borderRadius` with `Top`/`Bottom`/`Left`/`Right` and RTL-aware `Start`/`End` variants, `roundedShape`, `border` and `borderSide` on `num`; `border`/`borderSide` on `Color`; `clipRounded`, `clipBorderRadius` and `bordered` on widgets.
- `String.capitalizedInitialChar` (Unicode-safe initial) and `String.toPrettyJson()`.
- `BuildContext.crossAxisCount(...)` for responsive grid columns.
- `ColorUtils` (`fromHex`, `fromRGB`) is now exported from `playx_core.dart`.
- `toLocalDateTime*` and `asLocalDateTime*` accept a `utcOffset` to read timestamps without zone information in a given zone (for example a server sending local Saudi time).
- Optional `onError` callback (`MapOnError<T, S>`) on `MapUtils.mapAsync`, `MapUtils.mapAsyncInIsolate` and the `MapAsync<T>` extension methods. When provided, errors thrown while running the mapper (or while dispatching the isolate task) are caught, logged (subject to `printError`), and the value returned by `onError` is returned instead of rethrowing. If `onError` is `null` (the default), errors are rethrown after logging.

**AI tooling**
- `llms.txt` and `llms-full.txt` are published with the documentation site (generated from the guides by `dart run tool/build_llms.dart`; a test fails when they are stale).
- `skills/playx-core/SKILL.md`, an agent skill with the correct API and the 1.x pitfalls.

**Logging** (see [Logging](doc/logging.md))
- `PlayxCore.bootCore(loggerSettings:)` configures the `PLAYX CORE` logger: turn colors off (no more `^[[38;5;4m` in consoles that don't render ANSI), add the time, hide the boot messages with `level: LogLevel.warning`, or send logs elsewhere.
- `PlayxLoggerSettings.printLoggerName` and `printDateTime` now work (they were accepted but ignored). New options: `dateTimeFormat` (`PlayxLogDateTimeFormat`), `dateTimeFormatter`, `printLevel` (`[INFO]`-style labels) and `target` (`PlayxLogTarget`: `debugPrint`, `stdout` or `developerLog`) to choose the output channel, for example to avoid the `flutter: ` prefix that the platform adds to `print` and `debugPrint`. Messages are written as `[time] [LEVEL] [name] [tag] message`.
- Colors are dropped automatically when the console can't show them (web, `NO_COLOR`, `TERM=dumb`, a `stdout` terminal without ANSI support). `--dart-define=PLAYX_LOG_COLORS=true|false` forces them on or off for a build, for example in an Android Studio run configuration, whose Run panel prints ANSI codes as text.
- `PlayxLogTarget.developerLog` now passes the logger name, the level and `error`/`stackTrace` to `dart:developer`'s `log` (styled by Android Studio and DevTools) instead of formatted text.
- `DefaultColoredLoggerFormatter` (plain single lines) has a `const` constructor.
- `LogLevel`, `AnsiPen`, `LoggerFormatter`, `LoggerFilter`, `LoggerOutput`, `LogDetails`, `ExtendedLoggerFormatter`, `ColoredLoggerFormatter` and `TalkerLoggerSettings` are re-exported, so apps don't need a direct `talker_logger` dependency.

**Documentation**
- Guides for every area in [`doc/`](doc/README.md): getting started, preferences, secure preferences, environment configuration, secure env, extensions, utilities, logging, testing and a [migration guide](doc/migration-2.0.md). The guides are published as a searchable website (with the API reference) on GitHub Pages by `.github/workflows/docs.yml`. The README is now a concise overview that links to them, and the example app demonstrates environments and secure env.

### Changed

- Dependencies: `flutter_secure_storage` ^11.2.0, `simple_secure_storage` ^0.4.3, `flutter_dotenv` ^6.0.1, `pointycastle`, `flutter_lints` ^6.0.0 and `lints` ^6.0.0. Ranges were widened for `shared_preferences` (`>=2.3.0 <3.0.0`), `get_it` (`>=8.0.0 <10.0.0`), `equatable` (`>=2.0.7 <4.0.0`), `talker_logger`, `worker_manager` and `web`.
- `clearOnReinstall` no longer requires `PlayxPrefs` to be created. It keeps using the same flag, so existing installs are not cleared.
- `WebUtils` now uses the web implementation on WebAssembly builds too (the condition is `dart.library.js_interop` instead of `dart.library.html`).
- Secure preferences, environment and JSON helper code was reorganized into focused files and folders. Import `package:playx_core/playx_core.dart` rather than files under `src/`.

### Fixed

- `BuildContext.form` threw outside a `Form` instead of returning `null` (it now uses `Form.maybeOf`).
- `asListInt` and `asListIntOr` rejected values that `asListIntOrNull` accepts, such as `[1, '2', 3.0]`; they now convert the same way.
- `PlayxAsyncPrefs.maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` did not catch asynchronous errors; they now return `null` as documented.
- A clean-up of the private `_mapAsync` isolate entry point (removed a redundant `try/catch` that only rethrew).
- Documented that `context.size` resolves to `BuildContext`'s own render size rather than the `MediaQuery` size; use `context.width`, `context.height` or `context.aspectRatio` for the screen size.
- `PlayxLogger`'s documentation example used a `PlayxLoggerSettings(name: ...)` argument that doesn't exist.

### Tests

- Test coverage rose from about 80% to about 98%: loggers, all preference stores, `PlayxCore`, secure storage backends and edge cases, env, secure env and its command, extensions, conversion helpers and web behavior (including browser tests).

## 1.0.0
- Added support for nested JSON keys using dot notation (e.g., `'data.user.name'`) in all `safe_json_convert` functions.
- Introduced `toEnum`/`asEnum` and `toUri`/`asUri` safe conversion functions.
- Improved generic list parsing in `toListOrNull` by adding a fallback to `List<T>.from(value)` for safer runtime casting.
- Optimized `TalkerPlayxLogger` to strictly respect the `enabled` configuration, utilize `debugPrint`, and automatically disable colored output in Web environments to avoid unformatted ANSI codes.
- Refactored `PlayxColorExtensions` to eliminate deprecated `dart:ui` getters, transitioning to Flutter 3.24 wide-gamut compatibility (`a`, `r`, `g`, `b`). Added `fromHex`, `lighten`, `darken`, and `isDark` helper methods.
- Expanded core extension libraries (`String`, `Iterable`, `DateTime`, `Duration`, `bool`, `BuildContext`) to include new highly-requested utilities:
  - **String**: Added helpers like `toIntOrNull()`, `isNumeric`, `isValidEmail`, `toSlug()`, and `NullableStringExtensions` on `String?` (e.g., `isNullOrEmpty`).
  - **Iterable**: Added functional utilities `chunked`, `groupBy`, `sortedBy`, and numeric aggregates (`sum`, `average`).
  - **DateTime**: Added boundary generators like `startOfDay`, `endOfMonth`, and `startOfWeek`.
  - **Context**: Mapped the complete Material 3 `ColorScheme` properties (e.g., `onPrimary`, `surfaceContainer`) directly to `BuildContext` for agile theming.

## 0.7.4
- Update packages
- Add new asTOr and asT safe json convert functions.

# 1.0.0-beta.4 - 1.0.0-beta.5
- Added v0.7.0 changes.

# 1.0.0-beta.3
- Add new `printError` param to `**MapUtils** mapAsync` and `mapAsyncInIsolate` methods to determine whether to print errors or not.
- Update `asyncMapInIsolate` in `NestedIterablesExtensions` to include a `printError` parameter and `printEachItemError` parameter to determine whether to print errors for each item or not.


## 0.7.2-0.7.3
- Enhance logging methods in `PlayxCore` to use the new `PlayxLogger` system.

# 1.0.0-beta.2
> Note: This release has breaking changes.

- Update flutter_secure_storage: to v10.0.0-beta.4.
- Added v0.6.0 changes.


# 1.0.0-beta.1
- Add support for wasm support for web.
- Update flutter_secure_storage: to v10.0.0-beta.2 which includes some breaking changes.


- Updated dependencies.
- Added `isWasm` to `PlayxPlatform` to detect if the app is running in a WebAssembly environment.
- Introduced `WebUtils`, a new utility class providing common browser-side features for web apps:
  - Update the browser URL and query parameters without navigation.
  - Control fullscreen mode (enter, exit, toggle).
  - Set the browser tab title and application switcher label.
  - Change `<body>` background color directly or by CSS class.
  - Open links in new tabs.
  - Reload the page.


##  v0.7.0

> Note: This release has breaking changes.


### ✨ Features

* **New System Utilities** (`common_utils.dart`)

  * `setNavigationBarColor`: Set navigation bar color and icon brightness.
  * `setOrientation`: Lock screen orientation with optional rotation.
  * `hideKeyboard` / `showKeyboard`: Control keyboard visibility.
  * `enterFullScreen` / `exitFullScreen`: Toggle immersive full-screen mode.
  * `copyToClipboard` / `getClipboardText` / `clearClipboard`: Manage clipboard content.
  * `setStatusBarColor` now sets `statusBarBrightness` for improved iOS support.

---

### 🧠 Type Conversion Enhancements

* **Safe Conversion Utilities** (`safe_convert.dart` & `safe_json_convert.dart`)

  * Added:

    * `toNumOrNull`, `toNumOr`, `toNum`
    * `toDateTimeOrNull`, `toDateTimeOr`, `toDateTime`
    * `toLocalDateTimeOrNull`, `toLocalDateTimeOr`, `toLocalDateTime`
  * Improved:

    * List conversion with optional `fromJson`
    * Renamed generic list conversion functions for consistency:
        *  toListOrNullT → toListOrNull 
        * toListTOr → toListOr 
        * oListT → toList
    * Map conversion support for generic types (`<T, S>`)
    * `asTOrNull`: Now cleaner and more robust
  * Refactored for consistency, better error handling, and improved documentation.

---

### 🚀 **New Logging System ** 🔥

This version introduces a **modern, powerful, and highly configurable logging system** using the [`talker_logger`](https://pub.dev/packages/talker_logger) package.

#### ✅ **What's New**

* 🔄 **Replaced** old `PlayxLogger` with a modular and extensible system.

#### 🧱 Core Components

* `PlayxBaseLogger`: Abstract base for all logger implementations.
* `TalkerPlayxLogger`: Concrete logger using `talker_logger`, supports customization (name, colors, log levels, filters, formatters).
* `PlayxLoggerSettings`: Configure behavior globally (log level, console output, filters, etc.).
* `PlayxLogger`: Static utility class to manage and use named logger instances.

#### 🔧 Integration Highlights

* `PlayxCore` now initializes a default logger named **`'PLAYX CORE'`** on setup.

* Internal operations like **preference booting**, **environment loading**, and **error tracking** now leverage the enhanced logger:

  ```dart
  PlayxLogger.d('Debug message');
  PlayxCore.logger.error('An error occurred', error:error);
  ```

* Existing utilities (`MapperUtilities`, `IterableExtensions`) now use the new logger for standardized logging.

#### 🧩 Dependency

* Added: `talker_logger: ^4.7.7` to `pubspec.yaml`.

---

## 0.6.2 - 0.6.3
- Update packages. 
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.6.1
- Add new `printError` param to `**MapUtils** mapAsync` and `mapAsyncInIsolate` methods to determine whether to print errors or not.
- Update `asyncMapInIsolate` in `NestedIterablesExtensions` to include a `printError` parameter and `printEachItemError` parameter to determine whether to print errors for each item or not.

## 0.6.0
> Note: This release has breaking changes.

#### Breaking Changes
- **MapUtils**
  - `mapAsync` and `mapAsyncInIsolate` now require the following parameters:
    - `T data`: The data to be mapped.
    - `Mapper<T, S> mapper`: A required named parameter for the transformation logic.
- **Extensions on `Iterable<T>`**
  - Updated `asyncMap` and `asyncMapInIsolate` to require `Mapper<T, S> mapper` as a named parameter.
  - `NestedIterablesExtensions<T>`:
    - Deprecated `asyncFlatMap`. Use `flatMapAsync` instead.
    - Updated `flatMap` and `flatMapAsync` to require `Mapper<T, S> mapper` as a named parameter.

#### New Features
- **MapUtils**
  - Enhanced `mapAsyncInIsolate` to map items in an isolate using `workerManager` by default.
  - Added a new `useWorkManager` parameter:
    - If `true`, uses `workerManager` to execute tasks.
    - If `false`, falls back to the `compute` method.
- **Playx Core (`bootCore`)**
  - Introduced new settings:
    - `PlayxPrefsSettings`: Handles configurations for `createPlayxPrefs`, `createPlayxAsyncPrefs`, and `createPlayxPrefsWithCache` methods, which are now moved from the `bootCore` method.
    - `WorkManagerSettings`: Supports additional configurations in the `bootCore` method.
- **PlayxSecurePrefsSettings**
  - Added a `createSecurePrefs` parameter to control the creation of secure storage during the `boot` process.

#### Refactor
- **MapAsync Extension**:
  - Updated the `mapAsync` and `mapAsyncInIsolate` methods in the `MapAsync<T>` extension:
    - `mapAsync` now takes a `Mapper<T, S> mapper` as a required named parameter.
    - `mapAsyncInIsolate` now includes the following parameters:
      - `Mapper<T, S> mapper`: Required transformation logic.
      - `bool useWorkManager`: Defaults to `true`. Specifies whether to use `workerManager` or `compute`.


## 0.5.5
- refactor: Update packages.
- fix: `getDouble` method in `PlayxPrefs` and `PlayxAsyncPrefs` return double not double or null.
- feat: Add ColorExtensions to convert color to hex string.


## 0.5.4
- refactor: Update packages.
- refactor: Update `safe_convert` methods `asIntOr`, `asDoubleOr`, `asBoolOr`, `asStringOr`, `asListOr`, `asMapOr`, `asListTOr`, `asListTFromJsonOr`, `asListIntOr`, `asListStringOr`, `asTOr` to take dynamic json instead of a Map<String,dynamic> json value.
- refactor: Move json safe convert functions to a new file
- feat: Add new tests for the package.

## 0.5.3
> Note: This release has breaking changes.
- Update packages.
- Update `safe_convert` methods 
  - `asInt`, `asDouble`, `asBool`, `asString` and `asList`, `asMap`, `asListT`, `asListTFromJson` ,`asListInt`, `asListString`, `asT` now throws `FormatException` if the result was invalid.
  - Added `asIntOr`, `asDoubleOr`, `asBoolOr`, `asStringOr`, `asListOr`, `asMapOr`, `asListTOr`, `asListTFromJsonOr`, `asListIntOr`, `asListStringOr`, `asTOr` methods to provide a fallback value if the result was invalid.
  - Added new `asListTFromJson` method to convert a list of dynamic values to a list of a specific type.
  - Added new `fromJson` to `asTOrNull`, `asT` and `asTOr`.
- Add new Map utilities functions to map objects in isolate.

## 0.5.1 - 0.5.2

- Update Readme

## 0.5.0

- Update packages.
- Added `PlayxAsyncPrefs` for non-blocking shared preferences handling.
- Introduced `PlayxPrefsWithCache` for faster data retrieval with in-memory caching.
- Updated PlayxCore.bootCore() to include options for initializing the new preference classes.
- Added `GetIt` integration for dependency injection management.
- Updated `PlayxCore` to include `GetIt` instance management.
- Added new `PlayxPlatform` class to provide platform-specific utilities.
- Remove GetX dependency from the package.
- Remove Scope Functions from the package as there is no need for them in flutter and can be
  implemented if needed by a separate package.

## 0.4.3

- Update packages.
- Add a new `clearOnReinstall` method to `PlayxSecurePrefs` to clear all the keys stored in the
  secure prefs when the app is reinstalled.
- Add a new `clearOnReinstall` parameter to `PlayxSecurePrefsSettings` to clear all the keys stored
  in the secure prefs when the app is reinstalled which is set to true by default.

## 0.4.2

- Update packages.

## 0.4.1

- Add Tests for the package. 
- Remove functions that check date weekDay and month from `DateExtensions`and replace them
  with `dayOfTheWeek()` and `monthOfTheYear()`.
- Add new `ColorExtensions` and `ColorUtils` to create custom utilities for colors.
- Update DurationExtensions to optimize duration extensions and formatting durations.
- Add new `IterableExtensions` to add extensions
  like `lastWhereOrNull`, `lastWhereOr`, `firstWhereOr` to
  Iterables.
- Update `PlayxEnv` to not require a `.env` file to be present in the project when `isOptional` is
  set true.
- Add new `FutureExtensions` Extensions on [Future] to provide additional functionality.`

## 0.3.4

- Remove `flutter_readable` package from dependencies.
- Add more extensions to the package.
- Add safe convert methods to `PlayxCore` to convert safely convert any dynamic value to the correct
  type.

## 0.3.3

- Update exports.

## 0.3.2

- Update exports.

## 0.3.1

> Note: This release has breaking changes.

### BREAKING Changes

- `PlayXCore` was renamed to `PlayxCore`.

### New features

- Added new IterableExtensions to add extensions like flatten, flatMap, flatAsyncMap to Iterables.
- Added new Kotlin inspired scope functions to `PlayxCore` like  `also`, `let`, `run`, `takeIf`
  and `takeUnless`.
- Added new `toBoolean` extension to `String` to convert string to boolean.\
- Added new example app to demonstrate the `PlayxCore` features.

## 0.2.0

> Note: This release has breaking changes.

### BREAKING Changes

- `Prefs` was renamed to `PlayxPrefs`.
- `SecurePrefs` was renamed to `PlayxSecurePrefs`.
- `SecurePrefsSettings` was renamed to `PlayxSecurePrefsSettings`.
- `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxPrefs` now return non nullable
  value of it's type with the ability to provide it with a fallback that is returned if the key not
  found .
- `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxSecurePrefsSettings` now return
  non nullable value of it's type with the ability to provide it with a fallback that is returned if
  the key not found .

### New features

- Update packages.
- Added `PlayxEnv` : Wrapper for configure any the application with global variables using a `.env`
  file`.
- Update `PlayxCore` `bootCore` method to take `PlayxEnvSettings` parameter which is used to
  configure `flutter_dotenv` and load the `.env` file.
- Added new `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods
  in `PlayxPrefs` which return the value of it's type or null if the key not found or any error
  happened .
- `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods
  in `PlayxSecurePrefsSettings` which return the value of it's type or null if the key not found or
  any error happened .

## 0.1.2

- Move `Intl` package, `DateExtensions` and `NumExtensions` to `playx_localization` package.

## 0.1.1

- update packages and exports.

## 0.1.0

- Enhancements to `SecurePrefs`.

## 0.0.7 - 0.0.9

- Add `SecurePrefs` to be able to store encrypted keys in the device.
- Upgrade Packages.

## 0.0.6

- Add format extension for strings to format stings.

## 0.0.5

- Add support for Dart 3.0.0 and Flutter 3.10
- Upgrade Packages.
- Add multiple extensions like `DateExtensions`,  `DurationExtensions` , `NumDurationExtensions`
  and `NumExtensions`.
- Add common utilities.

## 0.0.4

- update Readme

## 0.0.3

- update packages

## 0.0.2

- fix typos
- add `capitalizeFirstChar(String str)`
- add `capitalizeFirstCharForEachWord(String str)`

## 0.0.1

- initial release.
