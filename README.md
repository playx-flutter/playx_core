
# PlayX Core
Core package for playx eco system contains shared classes and utilities.


## Features
- Common `utilities` and  `packages` across PlayX packages
- Common extensions that is needed for different apps.
- `Prefs` facade  : Key value pair storage powered by `SharedPreferences`
- `bootCore` function : inject and setup what is necessary .
-  Exports :  packages like `get` , `readable`.

## Playx:
`this packages is not for developers to use in day to day do not use it directly in your project`

Consider using our [Playx Package](https://pub.dev/packages/playx):
Which comes prepakaged with Playx Theme with more features and is easy to use.

## Installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml  
playx_core: ^0.0.5
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
You can now access PlayxCore capibalities like ``Prefs`` on your app.

## See Also:
[Playx](https://pub.dev/packages/playx) : Playx eco system helps with redundant features , less code , more productivity , better organizing.

[Playx_theme](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system 
