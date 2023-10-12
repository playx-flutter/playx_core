
# PlayX Core
 [![pub package](https://img.shields.io/pub/v/playx_core.svg?color=1284C5)](https://pub.dev/packages/playx_core)

Core package for playx eco system contains shared classes and utilities.


## Features
- Common `utilities` and  `packages` across PlayX packages
- Common extensions that is needed for different apps.
- `PlayxPrefs` facade  : Key value pair storage powered by `SharedPreferences`.
- `PlayxSecurePrefs` facade : Key value pair encrypted storage powered by `SecurePreferences`.
- `PlayxEnv` : Wrapper for configure any the application with global variables using a `.env` file`.
- `bootCore` function : inject and setup what is necessary .
-  Exports :  packages like `get` , `readable`.

## Playx:
`this packages is not for developers to use in day to day do not use it directly in your project`

Consider using our [Playx Package](https://pub.dev/packages/playx):
Which comes prepackaged with Playx Theme with more features and is easy to use.

## Installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml  
playx_core: ^0.2.0
```  

## Usage
### Boot the core

```dart
 void main ()async{
 WidgetsFlutterBinding.ensureInitialized();

  /// boot the core
  await PlayXCore.bootCore();
  
  /// run the real app
  runApp(const MyApp());
}
```

### Thats it
You can now access PlayxCore capabilities like ``PlayxPrefs`` on your app.

## See Also:
[Playx](https://pub.dev/packages/playx) : Playx eco system helps with redundant features , less code , more productivity , better organizing.

[Playx_theme](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system 
