import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:talker_logger/talker_logger.dart';

/// A [PlayxBaseLogger] recording calls, to test aliases and [PlayxLogger].
class RecordingLogger extends PlayxBaseLogger {
  final calls = <String>[];

  RecordingLogger({super.name});

  @override
  void debug(message, {String? tag}) => calls.add('debug:$message:$tag');

  @override
  void info(message, {String? tag}) => calls.add('info:$message:$tag');

  @override
  void warning(message, {String? tag}) => calls.add('warning:$message:$tag');

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) =>
      calls.add('error:$message:$error:${stackTrace != null}:$tag');

  @override
  void critical(message, {String? tag}) => calls.add('critical:$message:$tag');

  @override
  void verbose(message, {String? tag}) => calls.add('verbose:$message:$tag');

  @override
  void log(message, {String? tag}) => calls.add('log:$message:$tag');
}

TalkerPlayxLogger talkerLogger(
  List<String> output, {
  String? name,
  bool enabled = true,
  LogLevel level = LogLevel.verbose,
  bool printToConsole = true,
}) => TalkerPlayxLogger(
  name: name,
  settings: PlayxLoggerSettings(
    enabled: enabled,
    printToConsole: printToConsole,
    useColors: false,
    level: level,
    output: output.add,
  ),
);

void main() {
  group('PlayxBaseLogger aliases', () {
    test('forward to the full methods', () {
      final logger = RecordingLogger()
        ..d('a', tag: 't')
        ..i('b')
        ..w('c')
        ..e('d', error: 'boom', stackTrace: StackTrace.current, tag: 'x')
        ..c('e')
        ..v('f')
        ..l('g');
      expect(logger.calls, [
        'debug:a:t',
        'info:b:null',
        'warning:c:null',
        'error:d:boom:true:x',
        'critical:e:null',
        'verbose:f:null',
        'log:g:null',
      ]);
    });
  });

  group('TalkerPlayxLogger', () {
    test('writes every level with its name and tag', () {
      final output = <String>[];
      final logger = talkerLogger(output, name: 'APP')
        ..debug('debug message', tag: 'net')
        ..info('info message')
        ..warning('warning message')
        ..error('error message')
        ..critical('critical message')
        ..verbose('verbose message')
        ..log('log message');

      expect(output, hasLength(7));
      final all = output.join('\n');
      for (final message in [
        'debug message',
        'info message',
        'warning message',
        'error message',
        'critical message',
        'verbose message',
        'log message',
      ]) {
        expect(all, contains(message));
      }
      expect(all, contains('[APP]'));
      expect(all, contains('[net]'));
      expect(logger.name, 'APP');
    });

    test('includes the error and stack trace', () {
      final output = <String>[];
      talkerLogger(output).error(
        'failed',
        error: StateError('bad state'),
        stackTrace: StackTrace.fromString('#0 main (file.dart:1:1)'),
      );
      final text = output.join();
      expect(text, contains('failed'));
      expect(text, contains('bad state'));
      expect(text, contains('#0 main (file.dart:1:1)'));
    });

    test('prints null messages', () {
      final output = <String>[];
      talkerLogger(output).info(null);
      expect(output.join(), contains('null'));
    });

    test('logs nothing when disabled', () {
      final output = <String>[];
      talkerLogger(output, enabled: false)
        ..debug('a')
        ..info('b')
        ..warning('c')
        ..error('d', error: 'e', stackTrace: StackTrace.current)
        ..critical('f')
        ..verbose('g')
        ..log('h');
      expect(output, isEmpty);
    });

    test('respects the log level', () {
      final output = <String>[];
      talkerLogger(output, level: LogLevel.error)
        ..debug('hidden')
        ..info('hidden')
        ..error('shown');
      expect(output.join(), contains('shown'));
      expect(output.join(), isNot(contains('hidden')));
    });

    test('does not call the output when printing is off', () {
      final output = <String>[];
      talkerLogger(output, printToConsole: false).info('quiet');
      expect(output, isEmpty);
    });
  });

  group('PlayxLogger', () {
    test('creates, finds and registers loggers', () {
      expect(PlayxLogger.hasLogger('LOGGER_TEST'), isFalse);
      expect(PlayxLogger.getLogger('LOGGER_TEST'), isNull);

      final logger = PlayxLogger.initLogger(name: 'LOGGER_TEST');
      expect(logger, isA<TalkerPlayxLogger>());
      expect(PlayxLogger.hasLogger('LOGGER_TEST'), isTrue);
      expect(PlayxLogger.getLogger('LOGGER_TEST'), same(logger));
    });

    test('can use a colored formatter and custom settings', () {
      final colored = PlayxLogger.initLogger(
        name: 'LOGGER_COLORED',
        useColoredFormatter: true,
        setAsDefault: false,
      );
      expect(colored, isA<TalkerPlayxLogger>());

      final custom = PlayxLogger.initLogger(
        name: 'LOGGER_CUSTOM',
        settings: PlayxLoggerSettings(enabled: false),
        setAsDefault: false,
      );
      expect(custom.name, 'LOGGER_CUSTOM');
    });

    test('unnamed loggers are registered as PLAYX LOGGER', () {
      PlayxLogger.initLogger(setAsDefault: false);
      expect(PlayxLogger.hasLogger('PLAYX LOGGER'), isTrue);
    });

    test('the static methods delegate to the default logger', () {
      final recorder = RecordingLogger();
      PlayxLogger.setDefaultLogger(recorder);

      PlayxLogger.debug('a', tag: 't');
      PlayxLogger.info('b');
      PlayxLogger.warning('c');
      PlayxLogger.error('d', error: 'boom', stackTrace: StackTrace.current);
      PlayxLogger.critical('e');
      PlayxLogger.verbose('f');
      PlayxLogger.log('g');
      PlayxLogger.d('h');
      PlayxLogger.i('i');
      PlayxLogger.w('j');
      PlayxLogger.e('k', error: 'bad', tag: 'x');
      PlayxLogger.c('l');
      PlayxLogger.v('m');

      expect(recorder.calls, [
        'debug:a:t',
        'info:b:null',
        'warning:c:null',
        'error:d:boom:true:null',
        'critical:e:null',
        'verbose:f:null',
        'log:g:null',
        'debug:h:null',
        'info:i:null',
        'warning:j:null',
        'error:k:bad:false:x',
        'critical:l:null',
        'verbose:m:null',
      ]);
    });

    test('setAsDefault replaces the default logger', () {
      final recorder = RecordingLogger();
      PlayxLogger.setDefaultLogger(recorder);
      PlayxLogger.initLogger(name: 'LOGGER_DEFAULT');
      PlayxLogger.info('goes to the new default');
      expect(recorder.calls, isEmpty);
    });
  });

  group('PlayxLoggerSettings', () {
    test('has sensible defaults', () {
      final settings = PlayxLoggerSettings();
      expect(settings.level, LogLevel.verbose);
      expect(settings.lineSymbol, '─');
      expect(settings.maxLineWidth, 140);
      expect(settings.useColors, isTrue);
      expect(settings.printLoggerName, isTrue);
      expect(settings.printDateTime, isFalse);
      expect(settings.colors.keys, containsAll(LogLevel.values));
    });
  });
}
