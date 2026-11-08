import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// The parser has no Flutter dependency, so it can run with plain `dart run`.
// ignore: implementation_imports
import 'package:flutter_dotenv/src/parser.dart';

import '../secure_env_codec.dart';

// Pure Dart: this file must not import Flutter (directly or transitively),
// because it runs with `dart run playx_core:secure_env` /
// `dart run playx:secure_env`.

String _usage(String executableName) =>
    '''
Encrypts secret env values for PlayxEnv.

Usage: dart run $executableName [command] [options]

Commands:
  generate (default)  Write the encrypted Dart file used with
                      PlayxEnvSettings(secureEnv: playxSecureEnv).
  define              Print (or write with --out) the encrypted value of the
                      PLAYX_SECURE_DEFINES define.
  generate-key        Print a new random key.

Values (later sources override earlier ones):
  --input <file>          Secrets file. Default: .env.secrets
  --env <name>            Also read <input>.<name>, e.g. .env.secrets.prod.
                          Default: the PLAYX_ENV environment variable.
  --no-file               Don't read secrets files.
  --from-env <A,B>        Read these environment variables.
  --from-env-prefix <P>   Read every environment variable starting with P,
                          without the prefix (PLAYX_SECRET_API_KEY -> API_KEY).
  --define <KEY=VALUE>    Add a value. Can be repeated.
  --allow-empty           Don't fail when no values are found.

Key (first available is used):
  --key <base64>          The key.
  PLAYX_ENV_KEY           Environment variable holding the key.
  --key-file <file>       Key file, created if missing.
                          Default: .playx_secure_env.key
  --rotate-key            Create a new key and overwrite the key file.

Output:
  --output <file>         generate: Dart file.
                          Default: lib/generated/playx_secure_env.g.dart
  --key-from-define       generate: don't embed the key; pass it with
                          --dart-define=PLAYX_ENV_KEY=<key> when building.
  --import <uri>          generate: import used by the Dart file. Default:
                          package:playx/playx.dart if the project depends on
                          playx, else package:playx_core/playx_core.dart.
  --out <file.json>       define: write a --dart-define-from-file JSON file.
  --verbose               List the names of the values (never the values).
  -h, --help              Show this help.
''';

const _defaultInput = '.env.secrets';
const _defaultKeyFile = '.playx_secure_env.key';
const _defaultOutput = 'lib/generated/playx_secure_env.g.dart';
const _secureDefinesName = 'PLAYX_SECURE_DEFINES';
const _keyEnvironmentVariable = 'PLAYX_ENV_KEY';

const _exitOk = 0;
const _exitFailure = 1;
const _exitUsage = 64;

/// Runs the `secure_env` command line tool and returns its exit code.
///
/// [executableName] is how the tool is invoked, shown in its help and in
/// generated files: `playx_core:secure_env` (default) or `playx:secure_env`
/// when wrapped by the `playx` package.
///
/// [environment], [workingDirectory], [stdoutSink] and [stderrSink] default to
/// the current process and exist for testing.
Future<int> runSecureEnvCli(
  List<String> arguments, {
  String executableName = 'playx_core:secure_env',
  Map<String, String>? environment,
  String? workingDirectory,
  StringSink? stdoutSink,
  StringSink? stderrSink,
}) async {
  final cli = _SecureEnvCli(
    executableName: executableName,
    environment: environment ?? Platform.environment,
    workingDirectory: workingDirectory ?? Directory.current.path,
    out: stdoutSink ?? stdout,
    err: stderrSink ?? stderr,
  );
  try {
    return await cli.run(arguments);
  } on _CliException catch (e) {
    cli.err.writeln('Error: ${e.message}');
    return e.exitCode;
  }
}

class _CliException implements Exception {
  final String message;
  final int exitCode;

  const _CliException(this.message, [this.exitCode = _exitFailure]);
}

class _Options {
  String command = 'generate';
  String? input;
  String? env;
  bool noFile = false;
  final fromEnv = <String>[];
  String? fromEnvPrefix;
  final defines = <String>[];
  bool allowEmpty = false;
  String? key;
  String? keyFile;
  bool rotateKey = false;
  String? output;
  bool keyFromDefine = false;
  String? importUri;
  String? out;
  bool verbose = false;
  bool help = false;
}

class _SecureEnvCli {
  final String executableName;
  final Map<String, String> environment;
  final String workingDirectory;
  final StringSink out;
  final StringSink err;

  _SecureEnvCli({
    required this.executableName,
    required this.environment,
    required this.workingDirectory,
    required this.out,
    required this.err,
  });

  Future<int> run(List<String> arguments) async {
    final options = _parse(arguments);
    if (options.help) {
      out.write(_usage(executableName));
      return _exitOk;
    }
    switch (options.command) {
      case 'generate-key':
        out.writeln(base64Encode(generateSecureEnvKey()));
        return _exitOk;
      case 'generate':
        return _generate(options);
      case 'define':
        return _define(options);
      default:
        throw _CliException(
          'Unknown command "${options.command}". Use --help.',
          _exitUsage,
        );
    }
  }

  // Arguments

  static const _commands = {'generate', 'define', 'generate-key', 'help'};

  _Options _parse(List<String> arguments) {
    final options = _Options();
    final args = [...arguments];
    if (args.isNotEmpty && !args.first.startsWith('-')) {
      final command = args.removeAt(0);
      if (!_commands.contains(command)) {
        throw _CliException('Unknown command "$command".', _exitUsage);
      }
      options.command = command == 'help' ? 'generate' : command;
      options.help = command == 'help';
    }

    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      String? inlineValue;
      final equals = arg.indexOf('=');
      if (arg.startsWith('--') && equals > 0) {
        inlineValue = arg.substring(equals + 1);
        arg = arg.substring(0, equals);
      }
      String value() {
        if (inlineValue != null) return inlineValue;
        if (i + 1 >= args.length) {
          throw _CliException('Missing value for $arg.', _exitUsage);
        }
        return args[++i];
      }

      switch (arg) {
        case '-h' || '--help':
          options.help = true;
        case '--input':
          options.input = value();
        case '--env':
          options.env = value();
        case '--no-file':
          options.noFile = true;
        case '--from-env':
          options.fromEnv.addAll(
            value().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
        case '--from-env-prefix':
          options.fromEnvPrefix = value();
        case '--define':
          options.defines.add(value());
        case '--allow-empty':
          options.allowEmpty = true;
        case '--key':
          options.key = value();
        case '--key-file':
          options.keyFile = value();
        case '--rotate-key':
          options.rotateKey = true;
        case '--output':
          options.output = value();
        case '--key-from-define':
          options.keyFromDefine = true;
        case '--import':
          options.importUri = value();
        case '--out':
          options.out = value();
        case '--verbose':
          options.verbose = true;
        default:
          throw _CliException('Unknown option "$arg". Use --help.', _exitUsage);
      }
    }
    return options;
  }

  // Commands

  Future<int> _generate(_Options options) async {
    final environmentName = _environmentName(options);
    final values = _collectValues(options, environmentName);
    final key = _resolveKey(options);
    final data = await encryptSecureEnv(values, key);

    final output = _resolve(options.output ?? _defaultOutput);
    final file = File(output);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      _dartFile(
        data: data,
        key: options.keyFromDefine ? null : key,
        environment: environmentName,
        importUri: options.importUri ?? _defaultImport(),
      ),
    );

    out.writeln(
      'Encrypted ${values.length} value(s) into ${options.output ?? _defaultOutput}'
      '${environmentName == null ? '' : ' for "$environmentName"'}.',
    );
    if (options.keyFromDefine) {
      out.writeln(
        'The key is not embedded: build with '
        '--dart-define=$_keyEnvironmentVariable=<key>.',
      );
    } else {
      _warnIfNotIgnored(output, 'contains the key');
    }
    return _exitOk;
  }

  Future<int> _define(_Options options) async {
    final environmentName = _environmentName(options);
    final values = _collectValues(options, environmentName);
    final key = _resolveKey(options);
    final define = encodeSecureDefine(await encryptSecureEnv(values, key));

    final outPath = options.out;
    if (outPath == null) {
      out.writeln(define);
      return _exitOk;
    }

    final file = File(_resolve(outPath));
    final json = <String, dynamic>{};
    if (file.existsSync()) {
      try {
        final existing = jsonDecode(file.readAsStringSync());
        if (existing is Map<String, dynamic>) json.addAll(existing);
      } on FormatException {
        throw _CliException('$outPath is not a JSON object.');
      }
    }
    json[_secureDefinesName] = define;
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    out.writeln(
      'Encrypted ${values.length} value(s) into $outPath '
      '(--dart-define-from-file=$outPath).',
    );
    return _exitOk;
  }

  // Values

  String? _environmentName(_Options options) {
    final name = (options.env ?? environment['PLAYX_ENV'])?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  Map<String, String> _collectValues(_Options options, String? env) {
    final values = <String, String>{};
    final sources = <String>[];

    if (!options.noFile) {
      final input = options.input ?? _defaultInput;
      final files = [input, if (env != null) '$input.$env'];
      for (final path in files) {
        final file = File(_resolve(path));
        if (!file.existsSync()) {
          if (path == options.input) {
            throw _CliException('Input file $path not found.');
          }
          if (options.verbose) out.writeln('Skipped $path (not found).');
          continue;
        }
        final parser = const Parser();
        for (final line in file.readAsStringSync().split('\n')) {
          values.addAll(parser.parseOne(line, envMap: values));
        }
        sources.add(path);
        _warnIfNotIgnored(file.path, 'holds secret values');
      }
    }

    for (final name in options.fromEnv) {
      final value = environment[name];
      if (value == null) {
        throw _CliException('Environment variable $name is not set.');
      }
      values[name] = value;
    }
    if (options.fromEnv.isNotEmpty) sources.add('--from-env');

    final prefix = options.fromEnvPrefix;
    if (prefix != null && prefix.isNotEmpty) {
      var count = 0;
      for (final MapEntry(:key, :value) in environment.entries) {
        if (key.startsWith(prefix) && key.length > prefix.length) {
          values[key.substring(prefix.length)] = value;
          count++;
        }
      }
      if (count == 0) {
        err.writeln('Warning: no environment variables start with $prefix.');
      }
      sources.add('--from-env-prefix');
    }

    for (final define in options.defines) {
      final equals = define.indexOf('=');
      if (equals <= 0) {
        throw _CliException('Invalid --define "$define", expected KEY=VALUE.');
      }
      values[define.substring(0, equals).trim()] = define.substring(equals + 1);
    }
    if (options.defines.isNotEmpty) sources.add('--define');

    if (values.isEmpty && !options.allowEmpty) {
      throw _CliException(
        'No secret values found. Create $_defaultInput or use --from-env, '
        '--from-env-prefix or --define (or --allow-empty).',
      );
    }
    if (options.verbose) {
      out.writeln('Sources: ${sources.join(', ')}');
      out.writeln('Keys: ${(values.keys.toList()..sort()).join(', ')}');
    }
    return values;
  }

  // Key

  Uint8List _resolveKey(_Options options) {
    Uint8List decode(String value, String source) {
      try {
        return decodeSecureEnvKey(value);
      } on FormatException catch (e) {
        throw _CliException('Invalid key from $source: ${e.message}');
      }
    }

    final explicit = options.key;
    if (explicit != null) return decode(explicit, '--key');
    final fromEnvironment = environment[_keyEnvironmentVariable];
    if (fromEnvironment != null && fromEnvironment.trim().isNotEmpty) {
      return decode(fromEnvironment, _keyEnvironmentVariable);
    }

    final keyPath = options.keyFile ?? _defaultKeyFile;
    final keyFile = File(_resolve(keyPath));
    if (keyFile.existsSync() && !options.rotateKey) {
      return decode(keyFile.readAsStringSync(), keyPath);
    }
    final key = generateSecureEnvKey();
    keyFile.parent.createSync(recursive: true);
    keyFile.writeAsStringSync('${base64Encode(key)}\n');
    out.writeln('Created a new key in $keyPath.');
    _warnIfNotIgnored(keyFile.path, 'contains the key');
    return key;
  }

  // Output

  String _dartFile({
    required Uint8List data,
    required Uint8List? key,
    required String? environment,
    required String importUri,
  }) {
    final buffer = StringBuffer()
      ..writeln('// GENERATED by `dart run $executableName`. Do not edit.')
      ..writeln(
        key == null
            ? '// Contains encrypted values; the key is passed with '
                  '--dart-define=$_keyEnvironmentVariable.'
            : '// Contains encrypted values and their key: keep it out of '
                  'version control.',
      )
      ..writeln('// ignore_for_file: type=lint')
      // Keep the byte lists compact when the project is formatted.
      ..writeln('// dart format off')
      ..writeln()
      ..writeln("import '$importUri';")
      ..writeln()
      ..writeln(
        '/// Encrypted secure env values for `PlayxEnvSettings.secureEnv`.',
      )
      ..writeln('const playxSecureEnv = PlayxSecureEnvData(')
      ..writeln('  version: $secureEnvFormatVersion,')
      ..writeln(
        '  environment: ${environment == null ? 'null' : "'${_escape(environment)}'"},',
      );
    if (key == null) {
      buffer.writeln('  key: null,');
    } else {
      final mask = generateSecureEnvKey();
      final masked = [for (var i = 0; i < key.length; i++) key[i] ^ mask[i]];
      buffer
        ..writeln('  key: PlayxEnvKey.parts(')
        ..write(_intList(mask, indent: 4))
        ..writeln(',')
        ..write(_intList(masked, indent: 4))
        ..writeln(',')
        ..writeln('  ),');
    }
    buffer
      ..write('  data: ')
      ..write(_intList(data, indent: 2, leadingIndent: false))
      ..writeln(',')
      ..writeln(');');
    return buffer.toString();
  }

  static String _intList(
    List<int> bytes, {
    required int indent,
    bool leadingIndent = true,
  }) {
    final pad = ' ' * indent;
    final buffer = StringBuffer(leadingIndent ? '$pad[\n' : '[\n');
    for (var i = 0; i < bytes.length; i += 16) {
      final end = i + 16 < bytes.length ? i + 16 : bytes.length;
      buffer.writeln('$pad  ${bytes.sublist(i, end).join(', ')},');
    }
    buffer.write('$pad]');
    return buffer.toString();
  }

  static String _escape(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');

  String _defaultImport() {
    final pubspec = File(_resolve('pubspec.yaml'));
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      final dependsOnCore = RegExp(
        r'^\s+playx_core\s*:',
        multiLine: true,
      ).hasMatch(content);
      final dependsOnPlayx = RegExp(
        r'^\s+playx\s*:',
        multiLine: true,
      ).hasMatch(content);
      if (dependsOnPlayx && !dependsOnCore) return 'package:playx/playx.dart';
    }
    return 'package:playx_core/playx_core.dart';
  }

  String _resolve(String path) => File(path).isAbsolute
      ? path
      : '$workingDirectory${Platform.pathSeparator}$path';

  /// Warns when [path] isn't ignored by git. Silent outside a git repository.
  void _warnIfNotIgnored(String path, String reason) {
    try {
      final result = Process.runSync('git', [
        'check-ignore',
        '-q',
        path,
      ], workingDirectory: workingDirectory);
      if (result.exitCode == 1) {
        err.writeln(
          'Warning: ${_relative(path)} $reason but is not in .gitignore.',
        );
      }
    } on ProcessException {
      // git isn't available.
    }
  }

  String _relative(String path) {
    final prefix = '$workingDirectory${Platform.pathSeparator}';
    return path.startsWith(prefix) ? path.substring(prefix.length) : path;
  }
}
