/// Abstract logger interface used by PlayxLogger.
/// Can be implemented with any backend (e.g., Talker, Logger, etc.).
abstract class PlayxBaseLogger {
  /// Title of the logger.
  final String? name;

  /// Constructor for the logger.
  const PlayxBaseLogger({this.name});

  /// Logs a debug-level message.
  void debug(dynamic message, {String? tag});

  /// Logs an info-level message.
  void info(dynamic message, {String? tag});

  /// Logs a warning-level message.
  void warning(dynamic message, {String? tag});

  /// Logs an error-level message with optional exception and stack trace.
  void error(dynamic message,
      {Object? error, StackTrace? stackTrace, String? tag});

  /// Logs a critical-level message.
  void critical(dynamic message, {String? tag});

  /// Logs a success/good message.
  void verbose(dynamic message, {String? tag});

  /// Logs a raw/unspecified-level message.
  void log(dynamic message, {String? tag});

  /// Alias for [debug]
  void d(dynamic message, {String? tag}) => debug(message, tag: tag);

  /// Alias for [info]
  void i(dynamic message, {String? tag}) => info(message, tag: tag);

  /// Alias for [warning]
  void w(dynamic message, {String? tag}) => warning(message, tag: tag);

  /// Alias for [error]
  void e(dynamic message,
          {Object? error, StackTrace? stackTrace, String? tag}) => this.error(message,
          error: error, stackTrace: stackTrace, tag: tag);

  /// Alias for [critical]
  void c(dynamic message, {String? tag}) => critical(message, tag: tag);

  /// Alias for [good]
  void v(dynamic message, {String? tag}) => verbose(message, tag: tag);

  /// Alias for [log]
  void l(dynamic message, {String? tag}) => log(message, tag: tag);
}
