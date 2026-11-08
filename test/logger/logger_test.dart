import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/logger/log_color_support.dart';

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

/// A [Stdout] that records what is written with `writeln`.
class RecordingStdout implements Stdout {
  final lines = <String>[];

  @override
  bool get hasTerminal => false;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  void writeln([Object? object = '']) => lines.add('$object');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Plain single-line logging that records every message.
PlayxLoggerSettings plainSettings(
  List<String> output, {
  bool printDateTime = false,
  PlayxLogDateTimeFormat dateTimeFormat = PlayxLogDateTimeFormat.time,
  String Function(DateTime)? dateTimeFormatter,
  bool printLevel = false,
  bool printLoggerName = true,
  bool useColors = false,
  LogLevel level = LogLevel.verbose,
}) => PlayxLoggerSettings(
  enabled: true,
  printToConsole: true,
  useColors: useColors,
  printDateTime: printDateTime,
  dateTimeFormat: dateTimeFormat,
  dateTimeFormatter: dateTimeFormatter,
  printLevel: printLevel,
  printLoggerName: printLoggerName,
  level: level,
  formatter: const DefaultColoredLoggerFormatter(),
  output: output.add,
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

  group('message layout', () {
    test('is plain by default: name, tag and message', () {
      final output = <String>[];
      TalkerPlayxLogger(
        settings: plainSettings(output),
        name: 'APP',
      ).info('hello', tag: 'net');
      expect(output, ['[APP] [net] hello']);
    });

    test('printLoggerName can be turned off', () {
      final output = <String>[];
      TalkerPlayxLogger(
        settings: plainSettings(output, printLoggerName: false),
        name: 'APP',
      ).info('hello', tag: 'net');
      expect(output, ['[net] hello']);
    });

    test('printLevel adds a label for every level', () {
      final output = <String>[];
      TalkerPlayxLogger(
          settings: plainSettings(output, printLevel: true),
          name: 'APP',
        )
        ..verbose('a')
        ..debug('b')
        ..info('c')
        ..warning('d')
        ..error('e')
        ..critical('f')
        ..log('g');
      expect(output, [
        '[VERBOSE] [APP] a',
        '[DEBUG] [APP] b',
        '[INFO] [APP] c',
        '[WARNING] [APP] d',
        '[ERROR] [APP] e',
        '[CRITICAL] [APP] f',
        '[LOG] [APP] g',
      ]);
    });

    test('parts come in the order time, level, name, tag, message', () {
      final output = <String>[];
      TalkerPlayxLogger(
        settings: plainSettings(
          output,
          printDateTime: true,
          printLevel: true,
          dateTimeFormatter: (_) => '12:00',
        ),
        name: 'APP',
      ).warning('slow', tag: 'db');
      expect(output, ['[12:00] [WARNING] [APP] [db] slow']);
    });

    test('the time is written in each built-in format', () {
      String logged(PlayxLogDateTimeFormat format) {
        final output = <String>[];
        TalkerPlayxLogger(
          settings: plainSettings(
            output,
            printDateTime: true,
            dateTimeFormat: format,
          ),
          name: 'APP',
        ).info('x');
        return output.single;
      }

      expect(
        logged(PlayxLogDateTimeFormat.time),
        matches(RegExp(r'^\[\d{2}:\d{2}:\d{2}\.\d{3}\] \[APP\] x$')),
      );
      expect(
        logged(PlayxLogDateTimeFormat.dateTime),
        matches(
          RegExp(r'^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}\] \[APP\] x$'),
        ),
      );
      expect(
        logged(PlayxLogDateTimeFormat.iso8601),
        matches(
          RegExp(r'^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}\] \[APP\] x$'),
        ),
      );
    });

    test('no time is written unless printDateTime is set', () {
      final output = <String>[];
      TalkerPlayxLogger(
        settings: plainSettings(output, dateTimeFormatter: (_) => 'NOPE'),
        name: 'APP',
      ).info('x');
      expect(output.single, isNot(contains('NOPE')));
    });

    test('the level setting still filters', () {
      final output = <String>[];
      TalkerPlayxLogger(
          settings: plainSettings(output, level: LogLevel.warning),
          name: 'APP',
        )
        ..info('hidden')
        ..warning('shown');
      expect(output, ['[APP] shown']);
    });

    test('unnamed loggers have no name part', () {
      final output = <String>[];
      TalkerPlayxLogger(settings: plainSettings(output)).info('x');
      expect(output, ['x']);
    });
  });

  group('colors', () {
    test('useColors: false writes no escape codes', () {
      final output = <String>[];
      TalkerPlayxLogger(settings: plainSettings(output), name: 'APP')
        ..info('a')
        ..error('b');
      expect(output.join(), isNot(contains('\x1B')));
    });

    test('useColors: true writes ANSI escape codes', () {
      final output = <String>[];
      TalkerPlayxLogger(
        settings: plainSettings(output, useColors: true),
        name: 'APP',
      ).info('a');
      expect(output.single, startsWith('\x1B['));
      expect(output.single, contains('[APP] a'));
    });
  });

  group('output target', () {
    late List<String> debugPrinted;
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      originalDebugPrint = debugPrint;
      debugPrinted = [];
      debugPrint = (String? message, {int? wrapWidth}) =>
          debugPrinted.add(message ?? '');
    });

    tearDown(() => debugPrint = originalDebugPrint);

    PlayxLoggerSettings settingsFor(PlayxLogTarget target) =>
        PlayxLoggerSettings(
          enabled: true,
          printToConsole: true,
          useColors: false,
          formatter: const DefaultColoredLoggerFormatter(),
          target: target,
        );

    test('debugPrint is the default', () {
      TalkerPlayxLogger(
        settings: settingsFor(PlayxLogTarget.debugPrint),
        name: 'APP',
      ).info('hello');
      expect(debugPrinted, ['[APP] hello']);
    });

    test('stdout writes without going through debugPrint', () {
      final fake = RecordingStdout();
      IOOverrides.runZoned(() {
        TalkerPlayxLogger(
          settings: settingsFor(PlayxLogTarget.stdout),
          name: 'APP',
        ).info('hello');
      }, stdout: () => fake);
      expect(fake.lines, ['[APP] hello']);
      expect(debugPrinted, isEmpty);
    });

    test('developerLog does not go through debugPrint or stdout', () {
      final fake = RecordingStdout();
      IOOverrides.runZoned(() {
        TalkerPlayxLogger(
          settings: settingsFor(PlayxLogTarget.developerLog),
          name: 'APP',
        ).info('hello');
      }, stdout: () => fake);
      expect(fake.lines, isEmpty);
      expect(debugPrinted, isEmpty);
    });

    test('a custom output wins over the target', () {
      final custom = <String>[];
      final fake = RecordingStdout();
      IOOverrides.runZoned(() {
        TalkerPlayxLogger(
          settings: PlayxLoggerSettings(
            enabled: true,
            printToConsole: true,
            useColors: false,
            formatter: const DefaultColoredLoggerFormatter(),
            target: PlayxLogTarget.stdout,
            output: custom.add,
          ),
          name: 'APP',
        ).info('hello');
      }, stdout: () => fake);
      expect(custom, ['[APP] hello']);
      expect(fake.lines, isEmpty);
    });

    test('printToConsole: false discards messages for every target', () {
      final fake = RecordingStdout();
      IOOverrides.runZoned(() {
        for (final target in PlayxLogTarget.values) {
          TalkerPlayxLogger(
            settings: PlayxLoggerSettings(
              enabled: true,
              printToConsole: false,
              target: target,
            ),
            name: 'APP',
          ).info('hello');
        }
      }, stdout: () => fake);
      expect(fake.lines, isEmpty);
      expect(debugPrinted, isEmpty);
    });
  });

  group('color support', () {
    bool resolve({
      bool requested = true,
      PlayxLogTarget target = PlayxLogTarget.debugPrint,
      bool isWeb = false,
      Map<String, String> env = const {},
      bool hasTerminal = false,
      bool supportsAnsi = false,
      bool? define,
    }) => resolveLogColors(
      requested: requested,
      target: target,
      isWeb: isWeb,
      environment: env,
      stdoutHasTerminal: hasTerminal,
      stdoutSupportsAnsi: supportsAnsi,
      colorsDefine: define,
    );

    test('are on when requested and nothing prevents them', () {
      expect(resolve(), isTrue);
    });

    test('are off when not requested', () {
      expect(resolve(requested: false), isFalse);
    });

    test('are off on the web and for the developer log', () {
      expect(resolve(isWeb: true), isFalse);
      expect(resolve(target: PlayxLogTarget.developerLog), isFalse);
    });

    test('NO_COLOR and TERM=dumb turn them off', () {
      expect(resolve(env: {'NO_COLOR': '1'}), isFalse);
      expect(resolve(env: {'NO_COLOR': ''}), isTrue);
      expect(resolve(env: {'TERM': 'dumb'}), isFalse);
    });

    test('a stdout terminal must support ANSI', () {
      const t = PlayxLogTarget.stdout;
      expect(resolve(target: t, hasTerminal: true), isFalse);
      expect(resolve(target: t, hasTerminal: true, supportsAnsi: true), isTrue);
      expect(resolve(target: t), isTrue); // piped: not a terminal
    });

    test('the PLAYX_LOG_COLORS define overrides the rest', () {
      expect(resolve(define: false), isFalse);
      expect(resolve(define: true, env: {'NO_COLOR': '1'}), isTrue);
      expect(resolve(define: true, requested: false), isTrue);
      expect(resolve(define: true, isWeb: true), isFalse);
    });
  });

  group('developer log target', () {
    late List<Map<String, Object?>> entries;

    TalkerPlayxLogger create({
      bool printLoggerName = true,
      bool printLevel = false,
    }) {
      entries = [];
      return TalkerPlayxLogger(
        name: 'APP',
        settings: PlayxLoggerSettings(
          enabled: true,
          target: PlayxLogTarget.developerLog,
          printLoggerName: printLoggerName,
          printLevel: printLevel,
        ),
        developerLog:
            (
              message, {
              String name = '',
              int level = 0,
              Object? error,
              StackTrace? stackTrace,
            }) => entries.add({
              'message': message,
              'name': name,
              'level': level,
              'error': error,
              'stackTrace': stackTrace,
            }),
      );
    }

    test('passes the name and level, with plain text', () {
      final logger = create();
      logger.info('hello');
      logger.warning('careful', tag: 'net');
      expect(entries[0], containsPair('message', 'hello'));
      expect(entries[0], containsPair('name', 'APP'));
      expect(entries[0], containsPair('level', 800));
      expect(entries[1], containsPair('message', '[net] careful'));
      expect(entries[1], containsPair('level', 900));
    });

    test('maps every level', () {
      final logger = create();
      logger
        ..verbose('a')
        ..debug('a')
        ..info('a')
        ..warning('a')
        ..error('a')
        ..critical('a')
        ..log('a');
      expect(entries.map((e) => e['level']), [
        500,
        700,
        800,
        900,
        1000,
        1200,
        0,
      ]);
    });

    test('passes the error and stack trace separately', () {
      final logger = create();
      final trace = StackTrace.current;
      logger.error('failed', error: 'boom', stackTrace: trace);
      expect(entries.single, containsPair('message', 'failed'));
      expect(entries.single, containsPair('error', 'boom'));
      expect(entries.single, containsPair('stackTrace', trace));
      logger.info('next');
      expect(entries.last, containsPair('error', null));
    });

    test('has no ANSI codes and no duplicated name', () {
      final logger = create(printLevel: true);
      logger.info('hello');
      expect(entries.single['message'], '[INFO] hello');
      expect(entries.single['message'], isNot(contains('\u001b')));
    });

    test('printLoggerName: false sends an empty name', () {
      create(printLoggerName: false).info('hello');
      expect(entries.single, containsPair('name', ''));
    });
  });

  group('PlayxCore.bootCore loggerSettings', () {
    tearDown(PlayxCore.dispose);

    Future<void> boot(PlayxLoggerSettings? loggerSettings) async {
      PlayxPrefs.setMockInitialValues({});
      await PlayxCore.bootCore(
        securePrefsSettings: const PlayxSecurePrefsSettings(
          storageType: PlayxSecureStorageType.memory,
          clearOnReinstall: false,
        ),
        workerManagerSettings: const WorkManagerSettings(
          initWorkerManager: false,
        ),
        prefsSettings: const PlayxPrefsSettings(createPlayxAsyncPrefs: false),
        loggerSettings: loggerSettings,
      );
    }

    test('configures how the boot messages are written', () async {
      final output = <String>[];
      await boot(
        plainSettings(
          output,
          printLevel: true,
          printDateTime: true,
          dateTimeFormatter: (_) => 'T',
        ),
      );
      expect(output, [
        '[T] [INFO] [PLAYX CORE] Booting Preferences...',
        '[T] [INFO] [PLAYX CORE] Booting Environment...',
        '[T] [INFO] [PLAYX CORE] PlayxCore initialized',
      ]);
    });

    test('can silence the boot messages with a level', () async {
      final output = <String>[];
      await boot(plainSettings(output, level: LogLevel.warning));
      expect(output, isEmpty);
    });

    test('can turn the logger off', () async {
      final output = <String>[];
      await boot(
        PlayxLoggerSettings(
          enabled: false,
          printToConsole: true,
          output: output.add,
        ),
      );
      expect(output, isEmpty);
    });

    test('the logger is still the default logger', () async {
      final output = <String>[];
      await boot(plainSettings(output));
      output.clear();
      PlayxCore.logger.w('from core');
      PlayxLogger.w('from the facade');
      expect(output, [
        '[PLAYX CORE] from core',
        '[PLAYX CORE] from the facade',
      ]);
    });
  });
}
