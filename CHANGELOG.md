# Changelog

# 1.0.0-beta.2
> Note: This release has breaking changes.

- Update flutter_secure_storage: to v10.0.0-beta.4.
- Added v0.6.0 changes.


# 1.0.0-beta.1
- Add support for wasm support for web.
- Update flutter_secure_storage: to v10.0.0-beta.2 which includes some breaking changes.


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
