import 'dart:io';

import 'package:playx_core/secure_env_cli.dart';

/// `dart run playx_core:secure_env --help`
Future<void> main(List<String> arguments) async {
  exitCode = await runSecureEnvCli(arguments);
}
