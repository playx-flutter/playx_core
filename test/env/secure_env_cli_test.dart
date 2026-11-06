import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/secure_env_cli.dart';
import 'package:playx_core/src/env/secure/secure_env_codec.dart';

/// Extracts the key parts and data from a generated Dart file.
({Uint8List? key, List<int> data, String? environment}) parseGenerated(
  String source,
) {
  List<int> ints(String text) => RegExp(
    r'\d+',
  ).allMatches(text).map((m) => int.parse(m.group(0)!)).toList();

  final lists = RegExp(
    r'\[([\d,\s]*)\]',
  ).allMatches(source).map((m) => ints(m.group(1)!)).toList();
  final hasKey = source.contains('PlayxEnvKey.parts(');
  final environment = RegExp(
    r"environment: '([^']*)'",
  ).firstMatch(source)?.group(1);
  if (!hasKey) {
    return (key: null, data: lists.single, environment: environment);
  }
  final mask = lists[0];
  final masked = lists[1];
  return (
    key: Uint8List.fromList([
      for (var i = 0; i < mask.length; i++) mask[i] ^ masked[i],
    ]),
    data: lists[2],
    environment: environment,
  );
}

void main() {
  late Directory dir;
  late StringBuffer out;
  late StringBuffer err;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('secure_env_cli_test');
    out = StringBuffer();
    err = StringBuffer();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  void write(String path, String content) {
    final file = File('${dir.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  String read(String path) => File('${dir.path}/$path').readAsStringSync();

  bool exists(String path) => File('${dir.path}/$path').existsSync();

  Future<int> run(List<String> args, {Map<String, String> env = const {}}) =>
      runSecureEnvCli(
        args,
        environment: env,
        workingDirectory: dir.path,
        stdoutSink: out,
        stderrSink: err,
      );

  Future<Map<String, String>> decryptOutput([
    String path = 'lib/generated/playx_secure_env.g.dart',
  ]) async {
    final generated = parseGenerated(read(path));
    final key =
        generated.key ?? decodeSecureEnvKey(read('.playx_secure_env.key'));
    return decryptSecureEnv(generated.data, key);
  }

  group('generate', () {
    test('encrypts .env.secrets and the selected environment', () async {
      write('.env.secrets', 'STRIPE_KEY=pk_test\nMAPS_KEY="AIza 1"\n');
      write(
        '.env.secrets.prod',
        r'STRIPE_KEY=pk_live$SUFFIX'
            '\nSUFFIX=x\n',
      );

      expect(await run(['--env', 'prod']), 0);

      final source = read('lib/generated/playx_secure_env.g.dart');
      for (final secret in ['STRIPE_KEY', 'MAPS_KEY', 'pk_', 'AIza']) {
        expect(source, isNot(contains(secret)));
      }
      expect(parseGenerated(source).environment, 'prod');
      expect(source, contains('// dart format off'));
      expect(await decryptOutput(), {
        'STRIPE_KEY': 'pk_live',
        'MAPS_KEY': 'AIza 1',
        'SUFFIX': 'x',
      });
      expect(exists('.playx_secure_env.key'), isTrue);
      expect(out.toString(), contains('Encrypted 3 value(s)'));
      expect(out.toString(), isNot(contains('pk_live')));
    });

    test('takes the environment from PLAYX_ENV', () async {
      write('.env.secrets', 'A=base');
      write('.env.secrets.staging', 'A=staging');
      expect(await run([], env: {'PLAYX_ENV': 'staging'}), 0);
      expect(await decryptOutput(), {'A': 'staging'});
    });

    test('reads CI variables and defines, later sources winning', () async {
      write('.env.secrets', 'A=file\nB=file\nC=file\nD=file');
      final code = await run(
        [
          '--from-env',
          'B',
          '--from-env-prefix=PLAYX_SECRET_',
          '--define',
          'D=define=with=equals',
        ],
        env: {
          'B': 'env',
          'PLAYX_SECRET_C': 'prefix',
          'PLAYX_SECRET_': 'ignored',
          'OTHER': 'ignored',
        },
      );
      expect(code, 0);
      expect(await decryptOutput(), {
        'A': 'file',
        'B': 'env',
        'C': 'prefix',
        'D': 'define=with=equals',
      });
    });

    test('works without a secrets file', () async {
      expect(
        await run(
          ['--no-file', '--from-env-prefix', 'PLAYX_SECRET_'],
          env: {'PLAYX_SECRET_TOKEN': 't'},
        ),
        0,
      );
      expect(await decryptOutput(), {'TOKEN': 't'});
    });

    test('reuses the key file and rotates it on demand', () async {
      write('.env.secrets', 'A=1');
      await run([]);
      final firstKey = read('.playx_secure_env.key');
      await run([]);
      expect(read('.playx_secure_env.key'), firstKey);
      expect(
        parseGenerated(read('lib/generated/playx_secure_env.g.dart')).key,
        decodeSecureEnvKey(firstKey),
      );

      await run(['--rotate-key']);
      expect(read('.playx_secure_env.key'), isNot(firstKey));
      expect(await decryptOutput(), {'A': '1'});
    });

    test('uses --key or PLAYX_ENV_KEY without a key file', () async {
      write('.env.secrets', 'A=1');
      final key = base64Encode(generateSecureEnvKey());
      expect(await run(['--key', key]), 0);
      expect(exists('.playx_secure_env.key'), isFalse);

      expect(await run([], env: {'PLAYX_ENV_KEY': key}), 0);
      expect(
        parseGenerated(read('lib/generated/playx_secure_env.g.dart')).key,
        decodeSecureEnvKey(key),
      );
    });

    test('--key-from-define does not embed the key', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['--key-from-define', '--output', 'out.g.dart']), 0);
      final source = read('out.g.dart');
      expect(source, contains('key: null'));
      expect(source, isNot(contains('PlayxEnvKey')));
      expect(await decryptOutput('out.g.dart'), {'A': '1'});
      expect(out.toString(), contains('--dart-define=PLAYX_ENV_KEY'));
    });

    test('imports playx when the project depends on it', () async {
      write('.env.secrets', 'A=1');
      write('pubspec.yaml', 'name: app\ndependencies:\n  playx: ^2.0.0\n');
      await run([]);
      expect(
        read('lib/generated/playx_secure_env.g.dart'),
        contains("import 'package:playx/playx.dart';"),
      );

      write(
        'pubspec.yaml',
        'name: app\ndependencies:\n  playx: ^2.0.0\n  playx_core: ^2.0.0\n',
      );
      await run([]);
      expect(
        read('lib/generated/playx_secure_env.g.dart'),
        contains("import 'package:playx_core/playx_core.dart';"),
      );
    });
  });

  group('define', () {
    test('writes a --dart-define-from-file JSON file', () async {
      write('.env.secrets', 'A=1');
      write('defines.json', '{"OTHER": "kept"}');
      expect(await run(['define', '--out', 'defines.json']), 0);

      final json = jsonDecode(read('defines.json')) as Map<String, dynamic>;
      expect(json['OTHER'], 'kept');
      final key = decodeSecureEnvKey(read('.playx_secure_env.key'));
      expect(
        await decryptSecureEnv(
          decodeSecureDefine(json['PLAYX_SECURE_DEFINES'] as String),
          key,
        ),
        {'A': '1'},
      );
    });

    test('prints the define value', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['define']), 0);
      final value = out.toString().trim().split('\n').last;
      expect(value, startsWith('v1:'));
      expect(value, isNot(contains('A=1')));
    });
  });

  test('generate-key prints a valid key', () async {
    expect(await run(['generate-key']), 0);
    expect(decodeSecureEnvKey(out.toString().trim()), hasLength(32));
  });

  test('--help shows the command it was run with', () async {
    expect(await run(['--help']), 0);
    expect(out.toString(), contains('Usage: dart run playx_core:secure_env'));

    out.clear();
    await runSecureEnvCli(
      ['--help'],
      executableName: 'playx:secure_env',
      environment: const {},
      workingDirectory: dir.path,
      stdoutSink: out,
      stderrSink: err,
    );
    expect(out.toString(), contains('Usage: dart run playx:secure_env'));
  });

  test('generated files name the command', () async {
    write('.env.secrets', 'A=1');
    await run([]);
    expect(
      read('lib/generated/playx_secure_env.g.dart'),
      contains('GENERATED by `dart run playx_core:secure_env`'),
    );

    await runSecureEnvCli(
      [],
      executableName: 'playx:secure_env',
      environment: const {},
      workingDirectory: dir.path,
      stdoutSink: out,
      stderrSink: err,
    );
    expect(
      read('lib/generated/playx_secure_env.g.dart'),
      contains('GENERATED by `dart run playx:secure_env`'),
    );
  });

  group('errors', () {
    test('unknown options and commands are usage errors', () async {
      expect(await run(['--nope']), 64);
      expect(await run(['nope']), 64);
      expect(await run(['--env']), 64);
    });

    test('missing values fail', () async {
      expect(await run([]), 1);
      expect(err.toString(), contains('No secret values found'));
      expect(await run(['--input', 'missing.env']), 1);
      expect(await run(['--no-file', '--from-env', 'UNSET']), 1);
      expect(await run(['--no-file', '--define', 'novalue']), 1);
    });

    test('invalid keys fail', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['--key', 'c2hvcnQ=']), 1);
      expect(await run([], env: {'PLAYX_ENV_KEY': 'not base64!'}), 1);
    });

    test('--allow-empty generates a key-only file', () async {
      expect(await run(['--allow-empty']), 0);
      expect(await decryptOutput(), isEmpty);
    });
  });

  group('options', () {
    test('--key-file chooses where the key is kept', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['--key-file', 'keys/custom.key']), 0);
      expect(exists('keys/custom.key'), isTrue);
      expect(exists('.playx_secure_env.key'), isFalse);

      final key = decodeSecureEnvKey(read('keys/custom.key'));
      final generated = parseGenerated(
        read('lib/generated/playx_secure_env.g.dart'),
      );
      expect(generated.key, key);
    });

    test('--import chooses the import of the generated file', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['--import', 'package:my_app/env.dart']), 0);
      expect(
        read('lib/generated/playx_secure_env.g.dart'),
        contains("import 'package:my_app/env.dart';"),
      );
    });

    test('--verbose lists key names but never values', () async {
      write('.env.secrets', 'STRIPE_KEY=pk_secret_value\nMAPS_KEY=m');
      expect(await run(['--verbose']), 0);
      final text = out.toString();
      expect(text, contains('Sources: .env.secrets'));
      expect(text, contains('Keys: MAPS_KEY, STRIPE_KEY'));
      expect(text, isNot(contains('pk_secret_value')));
    });

    test('--verbose mentions skipped environment files', () async {
      write('.env.secrets', 'A=1');
      expect(await run(['--verbose', '--env', 'prod']), 0);
      expect(out.toString(), contains('Skipped .env.secrets.prod'));
    });

    test('a prefix without matches warns', () async {
      expect(
        await run([
          '--no-file',
          '--define',
          'A=1',
          '--from-env-prefix',
          'NOPE_',
        ]),
        0,
      );
      expect(
        err.toString(),
        contains('no environment variables start with NOPE_'),
      );
    });

    test('define --out rejects a file that is not JSON', () async {
      write('.env.secrets', 'A=1');
      write('defines.json', 'not json');
      expect(await run(['define', '--out', 'defines.json']), 1);
      expect(err.toString(), contains('defines.json is not a JSON object'));
    });

    test('the help command prints the usage', () async {
      expect(await run(['help']), 0);
      expect(out.toString(), contains('Usage: dart run'));
    });
  });

  group('gitignore warnings', () {
    bool hasGit() {
      try {
        return Process.runSync('git', ['--version']).exitCode == 0;
      } on ProcessException {
        return false;
      }
    }

    test('warns about files that are not ignored', () async {
      if (!hasGit()) markTestSkipped('git is not available');
      Process.runSync('git', ['init', '-q'], workingDirectory: dir.path);
      write('.env.secrets', 'A=1');

      expect(await run([]), 0);
      final warnings = err.toString();
      expect(warnings, contains('.env.secrets holds secret values'));
      expect(warnings, contains('.playx_secure_env.key contains the key'));
      expect(
        warnings,
        contains('lib/generated/playx_secure_env.g.dart contains the key'),
      );
    });

    test('is quiet when the files are ignored', () async {
      if (!hasGit()) markTestSkipped('git is not available');
      Process.runSync('git', ['init', '-q'], workingDirectory: dir.path);
      write(
        '.gitignore',
        '.env.secrets*\n.playx_secure_env.key\nlib/generated/\n',
      );
      write('.env.secrets', 'A=1');

      expect(await run([]), 0);
      expect(err.toString(), isNot(contains('.gitignore')));
    });

    test('is quiet outside a git repository', () async {
      write('.env.secrets', 'A=1');
      expect(await run([]), 0);
      expect(err.toString(), isNot(contains('.gitignore')));
    });
  });
}
