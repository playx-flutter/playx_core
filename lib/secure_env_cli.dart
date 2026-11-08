/// Command line tool generating encrypted env values for `PlayxEnv`.
///
/// Pure Dart, so it runs with `dart run`: `playx_core` exposes it as
/// `dart run playx_core:secure_env`, and the `playx` package wraps it as
/// `dart run playx:secure_env` with
/// `runSecureEnvCli(arguments, executableName: 'playx:secure_env')`.
library;

export 'src/env/secure/cli/secure_env_cli.dart' show runSecureEnvCli;
