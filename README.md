
# PlayX Core
[![pub package](https://img.shields.io/pub/v/playx_core.svg?color=1284C5)](https://pub.dev/packages/playx_core)  
[![Build](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml) <a href="https://codecov.io/gh/playx-flutter/playx_core"><img src="https://codecov.io/gh/playx-flutter/playx_core/branch/main/graph/badge.svg" alt="codecov"></a>  
<a href="https://github.com/playx-flutter/playx_core/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

Core package for the PlayX ecosystem containing shared classes and utilities.

## Features

- **Dependency Injection:** Manage your dependencies using `GetIt`.
- **PlayxPrefs:** Key-value storage powered by `SharedPreferences`.
- **PlayxSecurePrefs:** Encrypted key-value storage powered by `FlutterSecureStorage`.
- **PlayxAsyncPrefs:** Asynchronous key-value storage for non-blocking operations.
- **PlayxPrefsWithCache:** Key-value storage with caching capabilities for improved performance.
- **PlayxEnv:** Configure your application with global variables using a `.env` file.
- **bootCore Function:** Set up and initialize essential components for the PlayX ecosystem.

## Installation

Add `playx_core` to your `pubspec.yaml` dependencies:

```yaml  
dependencies:  
  playx_core: ^0.5.4  
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
 