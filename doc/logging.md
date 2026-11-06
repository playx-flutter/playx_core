# Logging

`PlayxLogger` is a small logging facade: static methods that forward to a **default logger**, plus support for any number of **named loggers**. The built-in implementation uses [`talker_logger`](https://pub.dev/packages/talker_logger), and you can plug in any other backend.

## Quick start

`PlayxCore.bootCore` creates a logger named `PLAYX CORE` and makes it the default, so you can log straight away:

```dart
PlayxLogger.i('App started');
PlayxLogger.d('Cart loaded', tag: 'cart');
PlayxLogger.w('Slow response');
PlayxLogger.e('Request failed', error: error, stackTrace: stackTrace);
```

Not using `bootCore`? Create a logger yourself:

```dart
PlayxLogger.initLogger(name: 'APP');
```

If no default logger exists, the static methods do nothing.

## Levels

| Method | Short | Level |
| --- | --- | --- |
| `PlayxLogger.verbose(msg)` | `v` | verbose |
| `PlayxLogger.debug(msg)` | `d` | debug |
| `PlayxLogger.info(msg)` | `i` | info |
| `PlayxLogger.warning(msg)` | `w` | warning |
| `PlayxLogger.error(msg, {error, stackTrace})` | `e` | error |
| `PlayxLogger.critical(msg)` | `c` | critical |
| `PlayxLogger.log(msg)` | | unspecified |

Every method takes a `message` (anything: it is converted with `toString`, and `null` prints as `null`) and an optional `tag`, which is shown in brackets next to the logger name:

```
[APP] [cart] Cart loaded
```

`error` also accepts an `error` and a `stackTrace`, appended below the message.

## Named loggers

```dart
final network = PlayxLogger.initLogger(name: 'NETWORK', setAsDefault: false);
final storage = PlayxLogger.initLogger(name: 'STORAGE', setAsDefault: false);

network.i('GET /users');                       // log with a specific logger
PlayxLogger.getLogger('STORAGE')?.w('Disk almost full');

PlayxLogger.hasLogger('NETWORK');              // true
PlayxLogger.setDefaultLogger(network);         // make it the target of PlayxLogger.i(...)
```

| Member | Does |
| --- | --- |
| `initLogger({name, settings, setAsDefault = true, useColoredFormatter = false})` | Creates a `TalkerPlayxLogger`, registers it under `name` (`PLAYX LOGGER` when omitted), and returns it. It becomes the default when `setAsDefault` is `true`, or when there is no default yet. |
| `getLogger(name)` | The logger registered under `name`, or `null`. |
| `hasLogger(name)` | Whether it exists. |
| `setDefaultLogger(logger)` | Sets any `PlayxBaseLogger` as the default. |

`PlayxCore.logger` returns the `PLAYX CORE` logger created by `bootCore`.

## Settings

```dart
PlayxLogger.initLogger(
  name: 'APP',
  settings: PlayxLoggerSettings(
    enabled: true,                 // log in release builds too
    level: LogLevel.info,          // ignore verbose and debug
    useColors: false,
  ),
);
```

`PlayxLoggerSettings`:

| Option | Default | Meaning |
| --- | --- | --- |
| `enabled` | `kDebugMode` | Master switch. When `false`, nothing is logged. |
| `printToConsole` | `kDebugMode` | Whether formatted messages are passed to `output`. When `false` they are discarded (see the note below). |
| `level` | `LogLevel.verbose` | Messages with a lower priority than this are ignored. |
| `useColors` | `true` | ANSI colors. Always off on web, where they render as noise. |
| `colors` | red/yellow/blue/gray per level | Colors per `LogLevel` (`AnsiPen`). |
| `formatter` | `ExtendedLoggerFormatter()` | How messages are laid out (`ExtendedLoggerFormatter`, `ColoredLoggerFormatter`, or your own `LoggerFormatter`). `useColoredFormatter: true` in `initLogger` uses the colored one. |
| `lineSymbol` | `─` | The symbol of the separator line. |
| `maxLineWidth` | `140` | Width of the separator line. |
| `output` | `debugPrint` | Where formatted messages go. |
| `filter` | `null` | A `LoggerFilter` to drop messages. |
| `printLoggerName`, `printDateTime` | | Accepted, but **currently have no effect**: the logger name is always shown and no timestamp is added. |

> **`printToConsole` and `output`.** With `printToConsole: true` messages go to `output` (or `debugPrint` when none is given). With `printToConsole: false` nothing is printed, even if you passed an `output`. To send logs somewhere else (a file, a crash reporter), keep `printToConsole: true` and pass `output`.

Types such as `LogLevel`, `AnsiPen`, `LoggerFormatter` and `LoggerFilter` come from `talker_logger`. Add it to your own `pubspec.yaml` to use them:

```yaml
dependencies:
  talker_logger: ^5.1.0
```

```dart
import 'package:talker_logger/talker_logger.dart';
```

### Sending logs elsewhere

```dart
PlayxLogger.initLogger(
  name: 'APP',
  settings: PlayxLoggerSettings(
    enabled: true,
    printToConsole: true,
    output: (message) => crashReporter.addBreadcrumb(message),
  ),
);
```

### Release builds

`enabled` and `printToConsole` default to `kDebugMode`, so a default logger is **silent in release builds**. Enable it explicitly (as above) if you want logs in production, ideally with a `level` of `warning` or higher and an `output` that goes to your reporting tool.

## Your own logger

Implement `PlayxBaseLogger` to use another backend (for example `package:logger`, Sentry or Crashlytics) and make it the default:

```dart
class SentryLogger extends PlayxBaseLogger {
  const SentryLogger() : super(name: 'SENTRY');

  @override
  void debug(message, {String? tag}) => Sentry.addBreadcrumb(Breadcrumb(message: '$message'));

  @override
  void info(message, {String? tag}) => Sentry.addBreadcrumb(Breadcrumb(message: '$message'));

  @override
  void warning(message, {String? tag}) => Sentry.captureMessage('$message', level: SentryLevel.warning);

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) =>
      Sentry.captureException(error ?? message, stackTrace: stackTrace);

  @override
  void critical(message, {String? tag}) => Sentry.captureMessage('$message', level: SentryLevel.fatal);

  @override
  void verbose(message, {String? tag}) {}

  @override
  void log(message, {String? tag}) {}
}

PlayxLogger.setDefaultLogger(const SentryLogger());
```

You only implement the seven level methods: the short aliases (`d`, `i`, `w`, `e`, `c`, `v`, `l`) are provided by the base class.

## What `playx_core` logs

The package logs through the `PLAYX CORE` logger, for example:

- startup steps (`Booting Preferences...`);
- skipped env files and reads before `PlayxEnv.load`;
- secure storage fallbacks and failures (`auto` choosing another backend, an unreadable key, a lost key);
- errors in `MapUtils` helpers when `printError` is set.

Messages never include secret values. In release builds nothing is printed unless you enabled the logger.
