import 'talker_playx_logger.dart';
import 'playx_logger_settings.dart';
import 'base_logger.dart';

/// A centralized static logger utility for Playx-based applications.
///
/// `PlayxLogger` acts as a singleton-like logging service that supports
/// multiple named loggers while maintaining a default global logger for convenience.
///
/// It wraps the [BaseLogger] interface and provides a default implementation
/// via [TalkerPlayxLogger], using the `talker_logger` package under the hood.
///
/// Example usage:
///
/// ```dart
/// PlayxLogger.initLogger(
///   name: 'app',
///   settings: PlayxLoggerSettings(name: 'AppLogger'),
/// );
///
/// PlayxLogger.d('App started');
/// PlayxLogger.error('Something went wrong', error: Exception('Oops'));
/// ```
///
class PlayxLogger {
  /// A map holding named logger instances.
  static final Map<String, PlayxBaseLogger> _loggers = {};

  /// The default logger used by static logging methods.
  static PlayxBaseLogger? _defaultLogger;

  /// Initializes a logger with the provided [name] and [settings].
  ///
  /// If [name] is omitted, a default name `'PLAYX LOGGER'` will be used.
  /// If [settings] are not provided, default settings will be applied.
  ///
  /// When [setAsDefault] is `true` (default), this logger will be assigned
  /// as the default logger for static logging methods like [debug], [error], etc.
  static void initLogger({
    String? name,
    PlayxLoggerSettings? settings,
    bool setAsDefault = true,

  }) {
    final logger = TalkerPlayxLogger(
        settings: settings ?? PlayxLoggerSettings(), name: name);
    name ??= 'PLAYX LOGGER';
    _loggers[name] = logger;

    if (setAsDefault || _defaultLogger == null) {
      _defaultLogger = logger;
    }
  }

  /// Retrieves a logger instance by its [name].
  ///
  /// Returns `null` if no logger exists with the given name.
  static PlayxBaseLogger? getLogger(String name) => _loggers[name];

  /// Checks if a logger with the specified [name] exists.
  static bool hasLogger(String name) => _loggers.containsKey(name);

  /// Overrides the currently used default logger with a custom [logger] instance.
  static void setDefaultLogger(PlayxBaseLogger logger) {
    _defaultLogger = logger;
  }

  // Default logger convenience methods.
  // These delegate to the default logger if set.

  /// Logs a debug-level [message] with optional [tag].
  static void debug(dynamic message, {String? tag}) =>
      _defaultLogger?.debug(message, tag: tag);

  /// Logs an info-level [message] with optional [tag].
  static void info(dynamic message, {String? tag}) =>
      _defaultLogger?.info(message, tag: tag);

  /// Logs a warning-level [message] with optional [tag].
  static void warning(dynamic message, {String? tag}) =>
      _defaultLogger?.warning(message, tag: tag);

  /// Logs an error-level [message] with optional [error], [stackTrace], and [tag].
  static void error(dynamic message,
          {Object? error, StackTrace? stackTrace, String? tag}) =>
      _defaultLogger?.error(
        message,
        error: error,
        stackTrace: stackTrace,
        tag: tag,
      );

  /// Logs a critical-level [message] with optional [tag].
  static void critical(dynamic message, {String? tag}) =>
      _defaultLogger?.critical(message, tag: tag);

  /// Logs a verbose-level [message] with optional [tag].
  static void verbose(dynamic message, {String? tag}) =>
      _defaultLogger?.verbose(message, tag: tag);

  /// Alias for [debug]
  static void d(dynamic message, {String? tag}) =>
      _defaultLogger?.debug(message, tag: tag);

  /// Alias for [info]
  static void i(dynamic message, {String? tag}) =>
      _defaultLogger?.info(message, tag: tag);

  /// Alias for [warning]
  static void w(dynamic message, {String? tag}) =>
      _defaultLogger?.warning(message, tag: tag);

  /// Alias for [error]
  static void e(dynamic message,
          {Object? error, StackTrace? stackTrace, String? tag}) =>
      _defaultLogger?.error(
        message,
        error: error,
        stackTrace: stackTrace,
        tag: tag,
      );

  /// Alias for [critical]
  static void c(dynamic message, {String? tag}) =>
      _defaultLogger?.critical(message, tag: tag);

  /// Alias for [verbose]
  static void v(dynamic message, {String? tag}) =>
      _defaultLogger?.verbose(message, tag: tag);

  /// Logs a general [message] using the default log level with optional [tag].
  static void log(dynamic message, {String? tag}) =>
      _defaultLogger?.log(message, tag: tag);
}
