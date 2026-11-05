import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show Parser;

import '../env_log.dart';
import '../env_values.dart';
import '../playx_env_exception.dart';
import '../playx_env_settings.dart';

/// The outcome of loading env values.
class EnvLoadResult {
  /// Every value, after layering.
  final EnvValues values;

  /// The resolved environment (e.g. `prod`), if any.
  final String? environment;

  /// The files that were found and loaded, in order.
  final List<String> loadedFiles;

  const EnvLoadResult(
    this.values, {
    this.environment,
    this.loadedFiles = const [],
  });
}

/// Loads and layers env values for [PlayxEnv].
abstract final class EnvLoader {
  /// `--dart-define=PLAYX_ENV=<name>` selects the environment file.
  static const _environmentDefine = String.fromEnvironment('PLAYX_ENV');

  /// `--dart-define=PLAYX_DEFINES=<values>` provides values without declaring
  /// each define in code. See [parsePlayxDefines].
  static const _playxDefines = String.fromEnvironment('PLAYX_DEFINES');

  /// Loads the files described by [settings], then applies
  /// [PlayxEnvSettings.mergeWith] and [PlayxEnvSettings.dartDefines].
  ///
  /// Throws a [PlayxEnvException] if a file is missing and
  /// [PlayxEnvSettings.isOptional] is `false`.
  static Future<EnvLoadResult> load(PlayxEnvSettings settings) async {
    final environment = resolveEnvironment(settings);
    final files = [
      settings.fileName,
      if (environment != null) '${settings.fileName}.$environment',
      ...settings.additionalFiles,
    ];

    final values = <String, String>{};
    final loaded = <String>[];
    final missing = <String>[];
    for (final file in files) {
      final content = await _loadAsset(file);
      if (content == null) {
        missing.add(file);
        continue;
      }
      _parseInto(values, content, settings.parser);
      loaded.add(file);
    }

    if (missing.isNotEmpty) {
      if (!settings.isOptional) {
        throw PlayxEnvException(
          'Missing env files: ${missing.join(', ')}',
          missingFiles: missing,
        );
      }
      envLogWarning('Env files not found, skipped: ${missing.join(', ')}');
    }

    _applyOverrides(
      values,
      mergeWith: settings.mergeWith,
      dartDefines: settings.dartDefines,
      usePlayxDefines: settings.usePlayxDefines,
      parser: settings.parser,
    );
    return EnvLoadResult(
      EnvValues(values),
      environment: environment,
      loadedFiles: List.unmodifiable(loaded),
    );
  }

  /// Parses [content] in `.env` format, then applies [mergeWith] and
  /// [dartDefines].
  static EnvLoadResult loadFromString(
    String content, {
    Map<String, String> mergeWith = const {},
    Map<String, String> dartDefines = const {},
    bool usePlayxDefines = true,
    Parser parser = const Parser(),
  }) {
    final values = <String, String>{};
    _parseInto(values, content, parser);
    _applyOverrides(
      values,
      mergeWith: mergeWith,
      dartDefines: dartDefines,
      usePlayxDefines: usePlayxDefines,
      parser: parser,
    );
    return EnvLoadResult(EnvValues(values));
  }

  /// The environment from [PlayxEnvSettings.environment], else
  /// `--dart-define=PLAYX_ENV`, else the Flutter flavor if
  /// [PlayxEnvSettings.useFlavor] is `true`.
  static String? resolveEnvironment(PlayxEnvSettings settings) {
    final candidates = [
      settings.environment,
      _environmentDefine,
      if (settings.useFlavor) appFlavor,
    ];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }

  /// Throws a [PlayxEnvException] listing [requiredKeys] without a value.
  static void checkRequiredKeys(EnvValues values, List<String> requiredKeys) {
    final missing = values.missingKeys(requiredKeys);
    if (missing.isNotEmpty) {
      throw PlayxEnvException(
        'Missing required env keys: ${missing.join(', ')}',
        missingKeys: missing,
      );
    }
  }

  static Future<String?> _loadAsset(String file) async {
    try {
      return await rootBundle.loadString(file, cache: false);
    } on FlutterError {
      return null;
    }
  }

  /// Parses [content] into [values]: later lines and files override earlier
  /// ones, and `$VAR` can reference any value parsed so far.
  static void _parseInto(
    Map<String, String> values,
    String content,
    Parser parser,
  ) {
    for (final line in content.split('\n')) {
      values.addAll(parser.parseOne(line, envMap: values));
    }
  }

  /// Applies [mergeWith], then `PLAYX_DEFINES`, then non-empty [dartDefines].
  static void _applyOverrides(
    Map<String, String> values, {
    required Map<String, String> mergeWith,
    required Map<String, String> dartDefines,
    required bool usePlayxDefines,
    required Parser parser,
  }) {
    values.addAll(mergeWith);
    if (usePlayxDefines) {
      values.addAll(
        parsePlayxDefines(_playxDefines, parser: parser, current: values),
      );
    }
    for (final MapEntry(:key, :value) in dartDefines.entries) {
      if (value.isNotEmpty) values[key] = value;
    }
  }

  static const _base64Prefix = 'base64:';

  /// Parses the value of the `PLAYX_DEFINES` define.
  ///
  /// [raw] is in `.env` format, with entries separated by `;` or new lines
  /// (`DEBUG=true;API_URL=https://example.com`), or `base64:` followed by
  /// base64-encoded `.env` content, for values containing `;` or characters
  /// that are hard to pass on a command line.
  ///
  /// Values can reference [current] values with `$VAR`. Returns an empty map
  /// if [raw] is empty or invalid.
  @visibleForTesting
  static Map<String, String> parsePlayxDefines(
    String raw, {
    Parser parser = const Parser(),
    Map<String, String> current = const {},
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return {};

    final String content;
    if (trimmed.startsWith(_base64Prefix)) {
      try {
        content = utf8.decode(
          base64.decode(
            trimmed
                .substring(_base64Prefix.length)
                .replaceAll(RegExp(r'\s'), ''),
          ),
        );
      } on FormatException {
        envLogWarning('PLAYX_DEFINES is not valid base64 and was ignored.');
        return {};
      }
    } else {
      content = trimmed.replaceAll(';', '\n');
    }

    final scope = Map.of(current);
    final values = <String, String>{};
    for (final line in content.split('\n')) {
      final parsed = parser.parseOne(line, envMap: scope);
      scope.addAll(parsed);
      values.addAll(parsed);
    }
    return values;
  }
}
