import 'package:flutter/foundation.dart';
import 'package:talker_logger/talker_logger.dart';

import 'base_logger.dart';
import 'playx_logger_settings.dart';

class TalkerPlayxLogger extends PlayxBaseLogger {
  final TalkerLogger _talker;
  final PlayxLoggerSettings settings;

  TalkerPlayxLogger({required this.settings, super.name})
      : _talker = TalkerLogger(
          settings: TalkerLoggerSettings(
            colors: settings.colors,
            enable: settings.enabled,
            defaultTitle: name ?? 'Playx Logger',
            level: settings.level,
            lineSymbol: settings.lineSymbol,
            maxLineWidth: settings.maxLineWidth,
            enableColors: kIsWeb ? false : settings.useColors,
          ),
          formatter: settings.formatter,
          output: settings.printToConsole
              ? settings.output ?? ((String message) => debugPrint(message))
              : ((String message) {}),
          filter: settings.filter,
        );

  String _formatMessage(dynamic message, {String? tag}) {
    final StringBuffer buffer = StringBuffer();
    if (name != null) buffer.write('[$name] ');
    if (tag != null) buffer.write('[$tag] ');
    buffer.write(message?.toString() ?? 'null');
    return buffer.toString();
  }

  @override
  void critical(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.critical(
      _formatMessage(message, tag: tag),
    );
  }

  @override
  void debug(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.debug(
      _formatMessage(message, tag: tag),
    );
  }

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!settings.enabled) return;
    final formattedMessage = _formatMessage(message, tag: tag);
    final messageWithError =
        error != null ? '$formattedMessage\n$error' : formattedMessage;
    final messageWithStackTrace = stackTrace != null
        ? '$messageWithError\n$stackTrace'
        : messageWithError;
    _talker.error(messageWithStackTrace);
  }

  @override
  void info(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.info(
      _formatMessage(message, tag: tag),
    );
  }

  @override
  void log(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.log(
      _formatMessage(message, tag: tag),
    );
  }

  @override
  void warning(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.warning(
      _formatMessage(message, tag: tag),
    );
  }

  @override
  void verbose(message, {String? tag}) {
    if (!settings.enabled) return;
    _talker.verbose(
      _formatMessage(message, tag: tag),
    );
  }
}
