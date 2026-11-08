import 'dart:developer' as developer;
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:talker_logger/talker_logger.dart';

import 'base_logger.dart';
import 'log_color_support.dart';
import 'playx_logger_settings.dart';

/// The signature of `dart:developer`'s `log`, so tests can observe it.
typedef DeveloperLogFunction =
    void Function(
      String message, {
      String name,
      int level,
      Object? error,
      StackTrace? stackTrace,
    });

/// Severity values of `dart:developer`'s `log`, as used by `package:logging`.
abstract final class _DeveloperLevel {
  static const verbose = 500;
  static const debug = 700;
  static const info = 800;
  static const warning = 900;
  static const error = 1000;
  static const critical = 1200;
  static const log = 0;
}

/// Passes messages through unchanged: with the developer log, the IDE styles
/// the output, so there is nothing to draw or color.
class _PassThroughFormatter implements LoggerFormatter {
  const _PassThroughFormatter();

  @override
  String fmt(LogDetails details, TalkerLoggerSettings settings) =>
      details.message?.toString() ?? '';
}

class TalkerPlayxLogger extends PlayxBaseLogger {
  late final TalkerLogger _talker;
  final PlayxLoggerSettings settings;
  final DeveloperLogFunction _developerLog;

  /// What the next developer log entry carries. Set right before a message is
  /// passed to the logger, and read by its output in the same call.
  int _pendingLevel = _DeveloperLevel.log;
  Object? _pendingError;
  StackTrace? _pendingStackTrace;

  bool get _usesDeveloperLog =>
      settings.output == null && settings.target == PlayxLogTarget.developerLog;

  TalkerPlayxLogger({
    required this.settings,
    super.name,
    @visibleForTesting DeveloperLogFunction? developerLog,
  }) : _developerLog = developerLog ?? developer.log {
    _talker = TalkerLogger(
      settings: TalkerLoggerSettings(
        colors: settings.colors,
        enable: settings.enabled,
        defaultTitle: name ?? 'Playx Logger',
        level: settings.level,
        lineSymbol: settings.lineSymbol,
        maxLineWidth: settings.maxLineWidth,
        enableColors: resolveLogColors(
          requested: settings.useColors,
          target: settings.target,
        ),
      ),
      formatter: _usesDeveloperLog
          ? const _PassThroughFormatter()
          : settings.formatter,
      output: _selectOutput(),
      filter: settings.filter,
    );
  }

  /// The output for the settings: the custom one, or the one of the target.
  LoggerOutput _selectOutput() {
    if (!settings.printToConsole) return (String message) {};
    final custom = settings.output;
    if (custom != null) return custom;
    switch (settings.target) {
      case PlayxLogTarget.debugPrint:
        return (String message) => debugPrint(message);
      case PlayxLogTarget.stdout:
        // `dart:io` has no stdout on the web.
        if (kIsWeb) return (String message) => debugPrint(message);
        return (String message) => io.stdout.writeln(message);
      case PlayxLogTarget.developerLog:
        return (String message) => _developerLog(
          message,
          name: settings.printLoggerName ? (name ?? 'PLAYX LOGGER') : '',
          level: _pendingLevel,
          error: _pendingError,
          stackTrace: _pendingStackTrace,
        );
    }
  }

  /// Writes `[time] [LEVEL] [name] [tag] message`, leaving out the parts the
  /// settings turn off.
  ///
  /// With the developer log the name is not part of the text: the IDE shows it
  /// in front of the message by itself.
  String _formatMessage(dynamic message, {String? tag, String? level}) {
    final StringBuffer buffer = StringBuffer();
    if (settings.printDateTime) {
      buffer.write('[${_formatTime(DateTime.now())}] ');
    }
    if (settings.printLevel && level != null) buffer.write('[$level] ');
    if (!_usesDeveloperLog && settings.printLoggerName && name != null) {
      buffer.write('[$name] ');
    }
    if (tag != null) buffer.write('[$tag] ');
    buffer.write(message?.toString() ?? 'null');
    return buffer.toString();
  }

  String _formatTime(DateTime time) {
    final custom = settings.dateTimeFormatter;
    if (custom != null) return custom(time);

    String two(int n) => n.toString().padLeft(2, '0');
    final clock =
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}'
        '.${time.millisecond.toString().padLeft(3, '0')}';
    final date =
        '${time.year.toString().padLeft(4, '0')}'
        '-${two(time.month)}-${two(time.day)}';
    switch (settings.dateTimeFormat) {
      case PlayxLogDateTimeFormat.time:
        return clock;
      case PlayxLogDateTimeFormat.dateTime:
        return '$date $clock';
      case PlayxLogDateTimeFormat.iso8601:
        return '${date}T$clock';
    }
  }

  /// Sends [message] to the logger with what the developer log needs.
  void _write(
    void Function(dynamic message) write,
    String message, {
    required int developerLevel,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _pendingLevel = developerLevel;
    _pendingError = error;
    _pendingStackTrace = stackTrace;
    try {
      write(message);
    } finally {
      _pendingError = null;
      _pendingStackTrace = null;
    }
  }

  @override
  void critical(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.critical,
      _formatMessage(message, tag: tag, level: 'CRITICAL'),
      developerLevel: _DeveloperLevel.critical,
    );
  }

  @override
  void debug(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.debug,
      _formatMessage(message, tag: tag, level: 'DEBUG'),
      developerLevel: _DeveloperLevel.debug,
    );
  }

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!settings.enabled) return;
    final formattedMessage = _formatMessage(message, tag: tag, level: 'ERROR');
    if (_usesDeveloperLog) {
      // Passed separately: Android Studio and DevTools show them in red.
      _write(
        _talker.error,
        formattedMessage,
        developerLevel: _DeveloperLevel.error,
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
    final messageWithError = error != null
        ? '$formattedMessage\n$error'
        : formattedMessage;
    final messageWithStackTrace = stackTrace != null
        ? '$messageWithError\n$stackTrace'
        : messageWithError;
    _write(
      _talker.error,
      messageWithStackTrace,
      developerLevel: _DeveloperLevel.error,
    );
  }

  @override
  void info(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.info,
      _formatMessage(message, tag: tag, level: 'INFO'),
      developerLevel: _DeveloperLevel.info,
    );
  }

  @override
  void log(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.log,
      _formatMessage(message, tag: tag, level: 'LOG'),
      developerLevel: _DeveloperLevel.log,
    );
  }

  @override
  void warning(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.warning,
      _formatMessage(message, tag: tag, level: 'WARNING'),
      developerLevel: _DeveloperLevel.warning,
    );
  }

  @override
  void verbose(message, {String? tag}) {
    if (!settings.enabled) return;
    _write(
      _talker.verbose,
      _formatMessage(message, tag: tag, level: 'VERBOSE'),
      developerLevel: _DeveloperLevel.verbose,
    );
  }
}
