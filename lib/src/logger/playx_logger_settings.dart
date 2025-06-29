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

/// Settings for initializing a logger without depending on any implementation.
class PlayxLoggerSettings {
  /// Field for enable and disable print logger
  final bool enabled;

  /// Field for enable and disable colored logs
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

  /// When [name] is not null, it will be used as a prefix for all logs
  final bool printLoggerName;

  /// Whether to print the date and time in the log
  final bool printDateTime;

  /// Current log level
  /// All messages with a priority below this will be ignored
  final LogLevel level;

  ///The symbol separating logs by lower border
  final String lineSymbol;

  /// Maximum width of the lower border
  final int maxLineWidth;

  /// You can setup different formatter [ExtendedLoggerFormatter, ColoredLoggerFormatter]
  /// Or your own fully customized formatter with extends [LoggerFormatter]
  final LoggerFormatter formatter;

  /// Field to setup custom log colors
  final LoggerOutput? output;
  final LoggerFilter? filter;

  PlayxLoggerSettings({
    this.enabled = kDebugMode,
    this.useColors = true,
    this.printToConsole = true,
    this.printLoggerName = true,
    this.printDateTime = false,
    this.level = LogLevel.verbose,
    this.lineSymbol = '─',
    this.maxLineWidth = 120,
    this.formatter = const ExtendedLoggerFormatter(),
    this.output,
    this.filter,
  });
}
