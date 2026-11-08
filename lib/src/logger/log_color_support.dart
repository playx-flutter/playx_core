import 'dart:io' as io;

import 'package:flutter/foundation.dart';

import 'playx_logger_settings.dart';

/// `--dart-define=PLAYX_LOG_COLORS=true|false` forces logger colors on or off
/// for a build, whatever the settings and the detection say.
///
/// It is the way to switch colors off for a console the app can't detect from
/// the inside, such as the Run panel of Android Studio.
const _colorsDefined = bool.hasEnvironment('PLAYX_LOG_COLORS');
const _colorsDefine = bool.fromEnvironment('PLAYX_LOG_COLORS');

/// Whether a logger should write ANSI color codes.
///
/// Colors are used only when [requested] (`PlayxLoggerSettings.useColors`) and
/// nothing is known to prevent them. Never on the web or when logging with
/// `PlayxLogTarget.developerLog`, which are not ANSI consoles. Otherwise:
///
/// 1. `--dart-define=PLAYX_LOG_COLORS=true|false` decides, when passed;
/// 2. the `NO_COLOR` environment variable (any non-empty value) turns colors
///    off, as does `TERM=dumb`;
/// 3. when writing to a terminal with `PlayxLogTarget.stdout`, the terminal
///    must support ANSI escape codes.
///
/// An app can't see which console shows its `print` output, so on mobile
/// colors stay on unless one of the signals above says otherwise.
///
/// The remaining parameters replace what is read from the platform, for tests.
bool resolveLogColors({
  required bool requested,
  required PlayxLogTarget target,
  bool? isWeb,
  Map<String, String>? environment,
  bool? stdoutHasTerminal,
  bool? stdoutSupportsAnsi,
  bool? colorsDefine,
}) {
  if (isWeb ?? kIsWeb) return false;
  if (target == PlayxLogTarget.developerLog) return false;

  final forced = colorsDefine ?? (_colorsDefined ? _colorsDefine : null);
  if (forced != null) return forced;

  if (!requested) return false;

  final env = environment ?? io.Platform.environment;
  if ((env['NO_COLOR'] ?? '').isNotEmpty) return false;
  if (env['TERM'] == 'dumb') return false;

  if (target == PlayxLogTarget.stdout) {
    final hasTerminal = stdoutHasTerminal ?? io.stdout.hasTerminal;
    if (hasTerminal) return stdoutSupportsAnsi ?? io.stdout.supportsAnsiEscapes;
  }
  return true;
}
