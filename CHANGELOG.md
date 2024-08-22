#0.5.1

- Update Readme

# 0.5.0

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

# 0.4.3

- Update packages.
- Add a new `clearOnReinstall` method to `PlayxSecurePrefs` to clear all the keys stored in the
  secure prefs when the app is reinstalled.
- Add a new `clearOnReinstall` parameter to `PlayxSecurePrefsSettings` to clear all the keys stored
  in the secure prefs when the app is reinstalled which is set to true by default.

# 0.4.2

- Update packages.

# 0.4.1

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

# 0.3.4

- Remove `flutter_readable` package from dependencies.
- Add more extensions to the package.
- Add safe convert methods to `PlayxCore` to convert safely convert any dynamic value to the correct
  type.

# 0.3.3

- Update exports.

# 0.3.2

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
