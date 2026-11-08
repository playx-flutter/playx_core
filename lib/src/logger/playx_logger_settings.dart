import 'package:flutter/foundation.dart';
import 'package:talker_logger/talker_logger.dart';

final _defaultColors = {
  LogLevel.critical: AnsiPen()..red(),
  LogLevel.error: AnsiPen()..red(),
  LogLevel.warning: AnsiPen()..yellow(),
  LogLevel.verbose: AnsiPen()..gray(),
  LogLevel.info: AnsiPen()..blue(),
  LogLevel.debug: AnsiPen()..gray(),
};

/// Where a logger sends its formatted messages when no custom
/// [PlayxLoggerSettings.output] is set.
///
/// What you see depends on the console. Tools that print app output add their
/// own prefix to `print`/`debugPrint` (for example `flutter: ` on iOS and
/// macOS, `I/flutter` on Android); other channels avoid it, but not every
/// console shows them.
enum PlayxLogTarget {
  /// `debugPrint`. Shown by every console (`flutter run`, IDEs, `adb logcat`),
  /// usually with the platform's prefix, and safe for long messages.
  debugPrint,

  /// `stdout`. No prefix in a terminal running the app (for example
  /// `flutter run -d macos`), but consoles that only collect `print` output,
  /// such as a mobile device's system log, may not show it. Falls back to
  /// [debugPrint] on the web.
  stdout,

  /// `dart:developer`'s `log`. Appears in DevTools and in IDE debug consoles
  /// under the logger's name, with no prefix, but not in the terminal of
  /// `flutter run`.
  developerLog,
}

/// How [PlayxLoggerSettings.printDateTime] writes the time.
enum PlayxLogDateTimeFormat {
  /// `13:45:30.123`
  time,

  /// `2024-05-15 13:45:30.123`
  dateTime,

  /// `2024-05-15T13:45:30.123` (the local time in ISO 8601).
  iso8601,
}

/// Settings for initializing a logger without depending on any implementation.
///
/// Every message is written as
/// `[time] [LEVEL] [name] [tag] message`, where each part is optional:
/// the time with [printDateTime], the level with [printLevel], the logger name
/// with [printLoggerName], and the tag when one is passed to the log call.
class PlayxLoggerSettings {
  /// Field for enable and disable print logger
  final bool enabled;

  /// Whether to color the logs with ANSI escape codes.
  ///
  /// Turn it off when your console shows the codes as text, such as
  /// `^[[38;5;4m`, instead of colors. Always off on the web.
  final bool useColors;

  /// Field for enable and disable print logger to console
  final bool printToConsole;

  /// Field to setup custom log colors
  ///```dart
  /// final logger = TalkerLogger(
  ///   settings: TalkerLoggerSettings(
  ///     colors: {
  ///       LogLevel.critical: AnsiPen()..red(),
  ///       LogLevel.error: AnsiPen()..magenta(),
  ///       LogLevel.info: AnsiPen()..cyan(),
  ///     },
  ///     enableColors: true,
  ///   ),
  /// );
  /// ```
  final Map<LogLevel, AnsiPen> colors = _defaultColors;

  /// Whether to write the logger's name, for example `[PLAYX CORE]`, in front
  /// of each message. Defaults to `true`.
  final bool printLoggerName;

  /// Whether to write the time of each message. Defaults to `false`.
  ///
  /// The format is [dateTimeFormat], or [dateTimeFormatter] if provided.
  final bool printDateTime;

  /// How the time is written when [printDateTime] is `true`. Defaults to
  /// [PlayxLogDateTimeFormat.time].
  final PlayxLogDateTimeFormat dateTimeFormat;

  /// Writes the time yourself, for example with `intl`. Overrides
  /// [dateTimeFormat].
  final String Function(DateTime time)? dateTimeFormatter;

  /// Whether to write the level, for example `[INFO]`, in front of each
  /// message. Useful when [useColors] is off, since the level is otherwise
  /// only conveyed by color. Defaults to `false`.
  final bool printLevel;

  /// Current log level
  /// All messages with a priority below this will be ignored
  final LogLevel level;

  ///The symbol separating logs by lower border
  final String lineSymbol;

  /// Maximum width of the lower border
  final int maxLineWidth;

  /// You can setup different formatter (`ExtendedLoggerFormatter`, `ColoredLoggerFormatter`)
  /// Or your own fully customized formatter with extends [LoggerFormatter]
  ///
  /// The default draws a box around every message. For plain single-line
  /// messages use `DefaultColoredLoggerFormatter()`.
  final LoggerFormatter formatter;

  /// Where formatted messages are sent, for example a file or a crash
  /// reporter. Defaults to the [target]. Needs [printToConsole] to be `true`.
  final LoggerOutput? output;

  /// The channel used when no [output] is set. Defaults to
  /// [PlayxLogTarget.debugPrint].
  final PlayxLogTarget target;

  /// Drops messages for which it returns `false`.
  final LoggerFilter? filter;

  PlayxLoggerSettings({
    this.enabled = kDebugMode,
    this.useColors = true,
    this.printToConsole = kDebugMode,
    this.printLoggerName = true,
    this.printDateTime = false,
    this.dateTimeFormat = PlayxLogDateTimeFormat.time,
    this.dateTimeFormatter,
    this.printLevel = false,
    this.level = LogLevel.verbose,
    this.lineSymbol = '─',
    this.maxLineWidth = 140,
    this.formatter = const ExtendedLoggerFormatter(),
    this.output,
    this.target = PlayxLogTarget.debugPrint,
    this.filter,
  });
}
