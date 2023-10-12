## 0.2.0

> Note: This release has breaking changes.

### BREAKING Changes
- `Prefs` was renamed to `PlayxPrefs`.
- `SecurePrefs` was renamed to `PlayxSecurePrefs`.
- `SecurePrefsSettings` was renamed to `PlayxSecurePrefsSettings`.
-  `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxPrefs` now return non nullable value of it's type with the ability to provide it with a fallback that is returned if the key not found .
-  `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxSecurePrefsSettings` now return non nullable value of it's type with the ability to provide it with a fallback that is returned if the key not found .

### New features
- Update packages.
- Added `PlayxEnv` : Wrapper for configure any the application with global variables using a `.env` file`.
- Update `PlayxCore` `bootCore` method to take `PlayxEnvSettings` parameter which is used to configure `flutter_dotenv` and load the `.env` file.
- Added new `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods in `PlayxPrefs` which return the value of it's type or null if the key not found or any error happened .
- `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods in `PlayxSecurePrefsSettings` which return the value of it's type or null if the key not found or any error happened .


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
- Add multiple extensions like `DateExtensions`,  `DurationExtensions` , `NumDurationExtensions` and `NumExtensions`.
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
