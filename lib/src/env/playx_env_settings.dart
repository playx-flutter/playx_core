import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Settings for [PlayxEnv.load].
///
/// Values are layered, later sources overriding earlier ones:
///
/// 1. [fileName] (e.g. `.env`);
/// 2. `'$fileName.$environment'` (e.g. `.env.prod`) when an environment is
///    resolved, see [environment];
/// 3. [additionalFiles], in order (e.g. `.env.local`);
/// 4. [mergeWith];
/// 5. the `PLAYX_DEFINES` define, see [usePlayxDefines];
/// 6. [dartDefines].
///
/// Files are Flutter assets: list them under `flutter: assets:` in your
/// `pubspec.yaml`.
///
/// **Security:** asset files ship as plain text inside the app and can be read
/// by anyone who has it. Use them for configuration (URLs, flags), never for
/// secrets. Values from [dartDefines] are compiled into the app and can also
/// be extracted.
class PlayxEnvSettings {
  /// The base file. Defaults to `.env`.
  final String fileName;

  /// The environment (e.g. `dev`, `staging`, `prod`), loading
  /// `'$fileName.$environment'` after [fileName].
  ///
  /// When `null`, it is resolved from `--dart-define=PLAYX_ENV=<name>`, then
  /// from the Flutter flavor (`--flavor <name>`) if [useFlavor] is `true`.
  final String? environment;

  /// Whether to use the Flutter flavor as the environment when none is set.
  ///
  /// Defaults to `true`.
  final bool useFlavor;

  /// Whether to read values from `--dart-define=PLAYX_DEFINES=<values>`,
  /// without declaring each define in code:
  ///
  /// ```sh
  /// flutter run --dart-define=PLAYX_DEFINES="DEBUG=true;API_URL=https://dev.example.com"
  /// ```
  ///
  /// Entries use `.env` syntax, separated by `;` or new lines. For values
  /// containing `;`, pass `base64:` followed by base64-encoded `.env` content.
  /// It can also be set with `--dart-define-from-file`.
  ///
  /// Defaults to `true`.
  final bool usePlayxDefines;

  /// More files loaded after the environment file, e.g. `.env.local`.
  final List<String> additionalFiles;

  /// Values overriding the files.
  final Map<String, String> mergeWith;

  /// Values from `--dart-define` or `--dart-define-from-file`, overriding
  /// everything else. Empty values (undefined defines) are ignored.
  ///
  /// Dart only reads defines with a constant name, so declare the ones you use:
  ///
  /// ```dart
  /// dartDefines: {
  ///   'API_URL': String.fromEnvironment('API_URL'),
  /// },
  /// ```
  final Map<String, String> dartDefines;

  /// Keys that must have a non-empty value once loaded.
  ///
  /// [PlayxEnv.load] throws a [PlayxEnvException] listing every missing key.
  final List<String> requiredKeys;

  /// Whether missing files are allowed. When `false`, [PlayxEnv.load] throws a
  /// [PlayxEnvException] if any file is missing.
  ///
  /// Defaults to `true`: missing files are logged and skipped.
  final bool isOptional;

  /// The parser used for the files. Handles comments, quotes and `$VAR`
  /// interpolation, which can reference values from earlier files.
  final Parser parser;

  const PlayxEnvSettings({
    this.fileName = '.env',
    this.environment,
    this.useFlavor = true,
    this.usePlayxDefines = true,
    this.additionalFiles = const [],
    this.mergeWith = const {},
    this.dartDefines = const {},
    this.requiredKeys = const [],
    this.isOptional = true,
    this.parser = const Parser(),
  });
}
