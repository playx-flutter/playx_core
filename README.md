
# PlayX Core
[![pub package](https://img.shields.io/pub/v/playx_core.svg?color=1284C5)](https://pub.dev/packages/playx_core)
[![Build](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/playx-flutter/playx_core/actions/workflows/build.yml) <a href="https://codecov.io/gh/playx-flutter/playx_core"><img src="https://codecov.io/gh/playx-flutter/playx_core/branch/main/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/playx-flutter/playx_core/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>


Core package for playx eco system contains shared classes and utilities.


## Features
- Common `utilities` and  `packages` across PlayX packages
- Common extensions that is needed for different apps.
- `PlayxPrefs` facade  : Key value pair storage powered by `SharedPreferences`.
- `PlayxSecurePrefs` facade : Key value pair encrypted storage powered by `SecurePreferences`.
- `PlayxEnv` : Wrapper for configure any the application with global variables using a `.env` file`.
- `bootCore` function : inject and setup what is necessary .
-  Exports :  packages like `get`, `shardPreference`.

## Installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml  
playx_core: ^0.4.3
```  

## Usage
- Boot the core

  ```dart
   void main ()async{
   WidgetsFlutterBinding.ensureInitialized();
 
    /// boot the core
    await PlayXCore.bootCore();
  
    /// run the real app
    runApp(const MyApp());
  }
  ```

- You can then use the `PlayxCore` to access the different utilities and packages.

  Here is an example to use `PlayxPrefs` to store and retrieve data.

  ```dart
  /// store data
  PlayxPrefs.setString('name', 'John Doe');
  PlayxPrefs.setInt('age', 25);
  PlayxPrefs.setDouble('height', 5.8);

  /// retrieve data
  String name = PlayxPrefs.getString('name');
  int age = PlayxPrefs.getInt('age');
  double? height = PlayxPrefs.maybeGetDouble('height');
  ```

## Documentation
Check out the [documentation](https://pub.dev/documentation/playx_core/latest/) for detailed information on how to integrate and utilize playx_core in your Flutter applications.

## Support and Contribution
For any questions, issues, or feature requests, please visit the GitHub repository of [playx_core](https://github.com/playx-flutter/playx_core). Contributions are welcome!

## See Also:
[Playx](https://pub.dev/packages/playx) : Playx eco system helps with redundant features , less code , more productivity , better organizing.

[Playx_theme](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system

[Playx_localization](https://pub.dev/packages/playx_localization) : Localization and internationalization for flutter apps from playx eco system

## Reference
- [PlayX](https://pub.dev/packages/playx)
- [flutter_readable](https://pub.dev/packages/flutter_readable)

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/playx-flutter/playx_core/blob/main/LICENSE) file for details

