import 'package:talker_logger/talker_logger.dart';

import 'base_logger.dart';
import 'playx_logger_settings.dart';

class TalkerPlayxLogger extends PlayxBaseLogger {
  final TalkerLogger _talker;
  final PlayxLoggerSettings settings;

  TalkerPlayxLogger({required this.settings,
    super.name
  })
      : _talker = TalkerLogger(
    settings: TalkerLoggerSettings(
      colors: settings.colors,
      enable: settings.enabled,
      defaultTitle: name ??'PLay Logger',
      level: settings.level,
      lineSymbol: settings.lineSymbol,
      maxLineWidth: settings.maxLineWidth,
      enableColors: settings.useColors,
    ),
    formatter: settings.formatter,
    output: settings.output,
    filter: settings.filter,
  );


  String _formatMessage(dynamic message, {String? tag}) {
    final tagPart = tag != null ? '[$tag]' : '';
    final namePart = name != null ? '[$name]' : '';
    return '$namePart$tagPart $message';
  }

  @override
  void critical(message, {String? tag}) {
    _talker.critical(_formatMessage(message, tag: tag),);
  }

  @override
  void debug(message, {String? tag}) {
    _talker.debug(_formatMessage(message, tag: tag),);
  }

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final formattedMessage = _formatMessage(message, tag: tag);
    final messageWithError = error != null ? '$formattedMessage\n$error' : formattedMessage;
    final messageWithStackTrace = stackTrace != null ? '$messageWithError\n$stackTrace' : messageWithError;
    _talker.error(messageWithStackTrace);
  }



  @override
  void info(message, {String? tag}) {
    _talker.info(_formatMessage(message, tag: tag),);
  }

  @override
  void log(message, {String? tag}) {
    _talker.log(_formatMessage(message, tag: tag),);
  }

  @override
  void warning(message, {String? tag}) {
    _talker.warning(_formatMessage(message, tag: tag),);
  }

  @override
  void verbose(message, {String? tag}) {
    _talker.verbose(_formatMessage(message, tag: tag),);
  }


}
