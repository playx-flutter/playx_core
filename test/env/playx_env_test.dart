import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/env/loader/env_loader.dart';

enum Mode { light, dark }

class Endpoint {
  final String host;
  final int port;

  const Endpoint(this.host, this.port);

  factory Endpoint.fromJson(dynamic json) =>
      Endpoint(asString(json, 'host'), asInt(json, 'port'));

  @override
  bool operator ==(Object other) =>
      other is Endpoint && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(host, port);
}

/// Serves [files] as Flutter assets.
void mockAssets(Map<String, String> files) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        final content = files[Uri.decodeFull(key)];
        if (content == null) return null;
        return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(PlayxEnv.dispose);

  group('load', () {
    test('loads .env', () async {
      mockAssets({'.env': 'API_URL=https://api.example.com\nRETRIES=3'});
      await PlayxEnv.load();

      expect(PlayxEnv.isLoaded, isTrue);
      expect(PlayxEnv.loadedFiles, ['.env']);
      expect(PlayxEnv.getString('API_URL'), 'https://api.example.com');
      expect(PlayxEnv.getInt('RETRIES'), 3);
    });

    test('layers the environment and additional files', () async {
      mockAssets({
        '.env': 'API_URL=https://api.example.com\nNAME=base\nLOG=info',
        '.env.prod': 'API_URL=https://prod.example.com\nNAME=prod',
        '.env.local': 'NAME=local',
      });
      await PlayxEnv.load(
        const PlayxEnvSettings(
          environment: 'prod',
          additionalFiles: ['.env.local'],
        ),
      );

      expect(PlayxEnv.environment, 'prod');
      expect(PlayxEnv.loadedFiles, ['.env', '.env.prod', '.env.local']);
      expect(PlayxEnv.getString('API_URL'), 'https://prod.example.com');
      expect(PlayxEnv.getString('NAME'), 'local');
      expect(PlayxEnv.getString('LOG'), 'info');
    });

    test('later files can reference earlier values', () async {
      mockAssets({
        '.env': 'HOST=example.com',
        '.env.dev': r'API_URL=https://dev.$HOST/api',
      });
      await PlayxEnv.load(const PlayxEnvSettings(environment: 'dev'));
      expect(PlayxEnv.getString('API_URL'), 'https://dev.example.com/api');
    });

    test('mergeWith and dartDefines override files', () async {
      mockAssets({'.env': 'A=file\nB=file\nC=file'});
      await PlayxEnv.load(
        const PlayxEnvSettings(
          mergeWith: {'B': 'merge', 'C': 'merge'},
          dartDefines: {'C': 'define', 'A': ''},
        ),
      );
      expect(PlayxEnv.getString('A'), 'file');
      expect(PlayxEnv.getString('B'), 'merge');
      expect(PlayxEnv.getString('C'), 'define');
    });

    test('keeps values with special characters as written', () async {
      mockAssets({'.env': ''});
      await PlayxEnv.load(
        const PlayxEnvSettings(mergeWith: {'PASSWORD': r'a$b#c"d'}),
      );
      expect(PlayxEnv.getString('PASSWORD'), r'a$b#c"d');
    });

    test('skips missing files when optional', () async {
      mockAssets({'.env': 'A=1'});
      await PlayxEnv.load(const PlayxEnvSettings(environment: 'staging'));
      expect(PlayxEnv.loadedFiles, ['.env']);
      expect(PlayxEnv.getInt('A'), 1);
    });

    test('throws for missing files when not optional', () async {
      mockAssets({'.env': 'A=1'});
      await expectLater(
        PlayxEnv.load(
          const PlayxEnvSettings(environment: 'staging', isOptional: false),
        ),
        throwsA(
          isA<PlayxEnvException>().having(
            (e) => e.missingFiles,
            'missingFiles',
            ['.env.staging'],
          ),
        ),
      );
    });

    test('throws for missing required keys', () async {
      mockAssets({'.env': 'A=1\nB='});
      await expectLater(
        PlayxEnv.load(const PlayxEnvSettings(requiredKeys: ['A', 'B', 'C'])),
        throwsA(
          isA<PlayxEnvException>().having((e) => e.missingKeys, 'missingKeys', [
            'B',
            'C',
          ]),
        ),
      );
    });
  });

  group('environment from the build', () {
    const define = String.fromEnvironment('PLAYX_ENV');
    const flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');

    test(
      'uses --dart-define=PLAYX_ENV',
      () async {
        mockAssets({'.env': 'NAME=base', '.env.$define': 'NAME=$define'});
        await PlayxEnv.load();
        expect(PlayxEnv.environment, define);
        expect(PlayxEnv.getString('NAME'), define);
      },
      skip: define.isEmpty ? 'Run with --dart-define=PLAYX_ENV=<name>' : false,
    );

    test(
      'uses the Flutter flavor',
      () async {
        mockAssets({'.env': 'NAME=base', '.env.$flavor': 'NAME=$flavor'});
        await PlayxEnv.load();
        expect(PlayxEnv.environment, flavor);
        expect(PlayxEnv.getString('NAME'), flavor);

        await PlayxEnv.load(const PlayxEnvSettings(useFlavor: false));
        expect(PlayxEnv.environment, isNull);
        expect(PlayxEnv.getString('NAME'), 'base');
      },
      skip: flavor.isEmpty || define.isNotEmpty
          ? 'Run with --flavor <name> (without PLAYX_ENV)'
          : false,
    );
  });

  group('PLAYX_DEFINES', () {
    test('parses entries separated by ; or new lines', () {
      expect(EnvLoader.parsePlayxDefines('DEBUG=true;RETRIES=3\nNAME="a b"'), {
        'DEBUG': 'true',
        'RETRIES': '3',
        'NAME': 'a b',
      });
      expect(EnvLoader.parsePlayxDefines(''), isEmpty);
      expect(EnvLoader.parsePlayxDefines(' ; ;'), isEmpty);
    });

    test('parses base64 content, even line-wrapped', () {
      final encoded = base64.encode(utf8.encode('A=1;2\nB=x=y'));
      final wrapped = '${encoded.substring(0, 6)}\n${encoded.substring(6)}';
      expect(EnvLoader.parsePlayxDefines('base64:$wrapped'), {
        'A': '1;2',
        'B': 'x=y',
      });
      expect(EnvLoader.parsePlayxDefines('base64:not base64!'), isEmpty);
    });

    test('can reference loaded values', () {
      expect(
        EnvLoader.parsePlayxDefines(
          r'API_URL=https://$HOST/api',
          current: {'HOST': 'example.com'},
        ),
        {'API_URL': 'https://example.com/api'},
      );
    });

    const defines = String.fromEnvironment('PLAYX_DEFINES');
    test(
      'is applied without declaring the define',
      () async {
        // Run with --dart-define=PLAYX_DEFINES="PD_DEBUG=true;PD_NAME=define"
        mockAssets({'.env': 'PD_DEBUG=false\nPD_NAME=file\nPD_KEEP=file'});
        await PlayxEnv.load();
        expect(PlayxEnv.getBool('PD_DEBUG'), isTrue);
        expect(PlayxEnv.getString('PD_NAME'), 'define');
        expect(PlayxEnv.getString('PD_KEEP'), 'file');

        await PlayxEnv.load(
          const PlayxEnvSettings(dartDefines: {'PD_NAME': 'explicit'}),
        );
        expect(PlayxEnv.getString('PD_NAME'), 'explicit');

        await PlayxEnv.load(const PlayxEnvSettings(usePlayxDefines: false));
        expect(PlayxEnv.getBool('PD_DEBUG'), isFalse);
      },
      skip: defines.isEmpty
          ? 'Run with --dart-define=PLAYX_DEFINES="PD_DEBUG=true;PD_NAME=define"'
          : false,
    );
  });

  group('testing helpers', () {
    test('loadFromString', () {
      PlayxEnv.loadFromString(
        'A=1\nB=two',
        mergeWith: {'B': '2'},
        usePlayxDefines: false,
      );
      expect(PlayxEnv.getInt('A'), 1);
      expect(PlayxEnv.getInt('B'), 2);
      expect(PlayxEnv.all, {'A': '1', 'B': '2'});
    });

    test('setMockValues and dispose', () async {
      PlayxEnv.setMockValues({'A': '1'});
      expect(PlayxEnv.containsKey('A'), isTrue);

      await PlayxEnv.dispose();
      expect(PlayxEnv.isLoaded, isFalse);
      expect(PlayxEnv.maybeGetString('A'), isNull);
    });
  });

  group('getters', () {
    setUp(
      () => PlayxEnv.setMockValues({
        'STRING': 'hello',
        'INT': '42',
        'DOUBLE': '1.5',
        'BOOL': 'TRUE',
        'BOOL_ZERO': '0',
        'NOT_BOOL': 'maybe',
        'URI': 'https://example.com/path?q=1',
        'MODE': 'Dark',
        'TIMEOUT': '30s',
        'DELAY': '250',
        'HOURS': '1.5h',
        'TAGS': 'a, b , ,c',
        'PORTS': '80,443',
        'JSON_LIST': '[1, 2, 3]',
        'BAD_PORTS': '80,abc',
        'MAP': '{"enabled": true, "limit": 10}',
        'ENDPOINT': '{"host": "example.com", "port": 443}',
        'ENDPOINTS': '[{"host": "a", "port": 1}, {"host": "b", "port": 2}]',
      }),
    );

    test('strings and numbers', () {
      expect(PlayxEnv.getString('STRING'), 'hello');
      expect(PlayxEnv.getString('MISSING', fallback: 'x'), 'x');
      expect(PlayxEnv.maybeGetInt('INT'), 42);
      expect(PlayxEnv.maybeGetInt('STRING'), isNull);
      expect(PlayxEnv.getInt('MISSING', fallback: 7), 7);
      expect(PlayxEnv.maybeGetDouble('DOUBLE'), 1.5);
      expect(PlayxEnv.maybeGetNum('INT'), 42);
    });

    test('bools', () {
      expect(PlayxEnv.maybeGetBool('BOOL'), isTrue);
      expect(PlayxEnv.maybeGetBool('BOOL_ZERO'), isFalse);
      expect(PlayxEnv.maybeGetBool('NOT_BOOL'), isNull);
      expect(PlayxEnv.getBool('NOT_BOOL', fallback: true), isTrue);
    });

    test('uris and enums', () {
      expect(
        PlayxEnv.maybeGetUri('URI'),
        Uri.parse('https://example.com/path?q=1'),
      );
      expect(PlayxEnv.maybeGetEnum('MODE', Mode.values), Mode.dark);
      expect(PlayxEnv.maybeGetEnum('STRING', Mode.values), isNull);
      expect(
        PlayxEnv.getEnum('MISSING', Mode.values, fallback: Mode.light),
        Mode.light,
      );
    });

    test('durations', () {
      expect(PlayxEnv.maybeGetDuration('TIMEOUT'), const Duration(seconds: 30));
      expect(
        PlayxEnv.maybeGetDuration('DELAY'),
        const Duration(milliseconds: 250),
      );
      expect(PlayxEnv.maybeGetDuration('HOURS'), const Duration(minutes: 90));
      expect(PlayxEnv.maybeGetDuration('STRING'), isNull);
      expect(
        PlayxEnv.getDuration('MISSING', fallback: Duration.zero),
        Duration.zero,
      );
    });

    test('lists', () {
      expect(PlayxEnv.maybeGetList<String>('TAGS'), ['a', 'b', 'c']);
      expect(PlayxEnv.maybeGetList<int>('PORTS'), [80, 443]);
      expect(PlayxEnv.maybeGetList<int>('JSON_LIST'), [1, 2, 3]);
      expect(PlayxEnv.maybeGetList<int>('BAD_PORTS'), isNull);
      expect(PlayxEnv.getList<int>('BAD_PORTS', fallback: [1]), [1]);
      expect(
        PlayxEnv.maybeGetList('ENDPOINTS', fromJson: Endpoint.fromJson),
        const [Endpoint('a', 1), Endpoint('b', 2)],
      );
      expect(PlayxEnv.maybeGetList<String>('STRING', separator: 'l'), [
        'he',
        'o',
      ]);
    });

    test('maps and objects', () {
      expect(PlayxEnv.maybeGetMap('MAP'), {'enabled': true, 'limit': 10});
      expect(PlayxEnv.maybeGetMap('STRING'), isNull);
      expect(
        PlayxEnv.maybeGetObject('ENDPOINT', fromJson: Endpoint.fromJson),
        const Endpoint('example.com', 443),
      );
      expect(
        PlayxEnv.maybeGetObject('MAP', fromJson: Endpoint.fromJson),
        isNull,
      );
      expect(
        PlayxEnv.getObject(
          'MISSING',
          fromJson: Endpoint.fromJson,
          fallback: const Endpoint('local', 80),
        ),
        const Endpoint('local', 80),
      );
    });
  });

  group('EnvValues', () {
    test('can be used on its own', () {
      final values = EnvValues({'RETRIES': '3', 'MODE': 'light'});
      expect(values.getInt('RETRIES'), 3);
      expect(
        values.getEnum('MODE', Mode.values, fallback: Mode.dark),
        Mode.light,
      );
      expect(values.missingKeys(['RETRIES', 'TOKEN']), ['TOKEN']);
    });

    test('copies and protects its values', () {
      final source = {'A': '1'};
      final values = EnvValues(source);
      source['A'] = '2';
      expect(values.getString('A'), '1');
      expect(() => values.all['A'] = '3', throwsUnsupportedError);
    });

    test('PlayxEnv exposes the loaded values', () {
      PlayxEnv.setMockValues({'A': '1'});
      expect(PlayxEnv.values.getInt('A'), 1);
      expect(PlayxEnv.values.all, PlayxEnv.all);
    });
  });

  test('returns nothing before load', () {
    expect(PlayxEnv.isLoaded, isFalse);
    expect(PlayxEnv.maybeGetString('A'), isNull);
    expect(PlayxEnv.getInt('A', fallback: 5), 5);
  });
}
