import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_core/src/env/parsers/env_value_parser.dart';

enum Level { low, high }

void main() {
  const values = {
    'STRING': 'text',
    'INT': '3',
    'DOUBLE': '2.5',
    'NUM': '7',
    'BOOL': 'true',
    'URI': 'https://example.com',
    'LEVEL': 'high',
    'DURATION': '2m',
    'LIST': 'a,b',
    'MAP': '{"a": 1}',
    'OBJECT': '{"n": 4}',
  };
  const fallbackUri = 'https://fallback.dev';

  int fromJson(dynamic json) => asInt(json, 'n');

  setUp(() => PlayxEnv.setMockValues(values));
  tearDown(PlayxEnv.dispose);

  group('PlayxEnv getters read the loaded values', () {
    test('every type', () {
      expect(PlayxEnv.getString('STRING'), 'text');
      expect(PlayxEnv.getInt('INT'), 3);
      expect(PlayxEnv.getDouble('DOUBLE'), 2.5);
      expect(PlayxEnv.getNum('NUM'), 7);
      expect(PlayxEnv.getBool('BOOL'), isTrue);
      expect(
        PlayxEnv.getUri('URI', fallback: Uri()),
        Uri.parse(values['URI']!),
      );
      expect(
        PlayxEnv.getEnum('LEVEL', Level.values, fallback: Level.low),
        Level.high,
      );
      expect(
        PlayxEnv.getDuration('DURATION', fallback: Duration.zero),
        const Duration(minutes: 2),
      );
      expect(PlayxEnv.getList<String>('LIST'), ['a', 'b']);
      expect(PlayxEnv.getMap('MAP'), {'a': 1});
      expect(PlayxEnv.getObject('OBJECT', fromJson: fromJson, fallback: 0), 4);
    });

    test('the nullable variants', () {
      expect(PlayxEnv.maybeGetString('STRING'), 'text');
      expect(PlayxEnv.maybeGetInt('INT'), 3);
      expect(PlayxEnv.maybeGetDouble('DOUBLE'), 2.5);
      expect(PlayxEnv.maybeGetNum('NUM'), 7);
      expect(PlayxEnv.maybeGetBool('BOOL'), isTrue);
      expect(PlayxEnv.maybeGetUri('URI'), Uri.parse(values['URI']!));
      expect(PlayxEnv.maybeGetEnum('LEVEL', Level.values), Level.high);
      expect(PlayxEnv.maybeGetDuration('DURATION'), const Duration(minutes: 2));
      expect(PlayxEnv.maybeGetList<String>('LIST'), ['a', 'b']);
      expect(PlayxEnv.maybeGetMap('MAP'), {'a': 1});
      expect(PlayxEnv.maybeGetObject('OBJECT', fromJson: fromJson), 4);
    });
  });

  group('PlayxEnv getters use the fallback for missing keys', () {
    test('every type', () {
      expect(PlayxEnv.getString('NOPE', fallback: 's'), 's');
      expect(PlayxEnv.getInt('NOPE', fallback: 1), 1);
      expect(PlayxEnv.getInt('NOPE'), -1);
      expect(PlayxEnv.getDouble('NOPE', fallback: 1.5), 1.5);
      expect(PlayxEnv.getDouble('NOPE'), -1);
      expect(PlayxEnv.getNum('NOPE', fallback: 9), 9);
      expect(PlayxEnv.getNum('NOPE'), -1);
      expect(PlayxEnv.getBool('NOPE', fallback: true), isTrue);
      expect(
        PlayxEnv.getUri('NOPE', fallback: Uri.parse(fallbackUri)),
        Uri.parse(fallbackUri),
      );
      expect(
        PlayxEnv.getEnum('NOPE', Level.values, fallback: Level.low),
        Level.low,
      );
      expect(
        PlayxEnv.getDuration('NOPE', fallback: const Duration(seconds: 5)),
        const Duration(seconds: 5),
      );
      expect(PlayxEnv.getList<int>('NOPE', fallback: [1]), [1]);
      expect(PlayxEnv.getList<int>('NOPE'), isEmpty);
      expect(PlayxEnv.getMap('NOPE', fallback: {'z': 1}), {'z': 1});
      expect(PlayxEnv.getMap('NOPE'), isEmpty);
      expect(PlayxEnv.getObject('NOPE', fromJson: fromJson, fallback: -5), -5);
    });

    test('the nullable variants return null', () {
      expect(PlayxEnv.maybeGetString('NOPE'), isNull);
      expect(PlayxEnv.maybeGetInt('NOPE'), isNull);
      expect(PlayxEnv.maybeGetDouble('NOPE'), isNull);
      expect(PlayxEnv.maybeGetNum('NOPE'), isNull);
      expect(PlayxEnv.maybeGetBool('NOPE'), isNull);
      expect(PlayxEnv.maybeGetUri('NOPE'), isNull);
      expect(PlayxEnv.maybeGetEnum('NOPE', Level.values), isNull);
      expect(PlayxEnv.maybeGetDuration('NOPE'), isNull);
      expect(PlayxEnv.maybeGetList<int>('NOPE'), isNull);
      expect(PlayxEnv.maybeGetMap('NOPE'), isNull);
      expect(PlayxEnv.maybeGetObject('NOPE', fromJson: fromJson), isNull);
    });
  });

  group('EnvValues getters', () {
    final env = EnvValues(values);

    test('read values', () {
      expect(env.getDouble('DOUBLE'), 2.5);
      expect(env.getNum('NUM'), 7);
      expect(env.getUri('URI', fallback: Uri()), Uri.parse(values['URI']!));
      expect(env.getMap('MAP'), {'a': 1});
    });

    test('use fallbacks', () {
      expect(env.getDouble('NOPE', fallback: 0.5), 0.5);
      expect(env.getDouble('NOPE'), -1);
      expect(env.getNum('NOPE'), -1);
      expect(env.getNum('NOPE', fallback: 2), 2);
      expect(
        env.getUri('NOPE', fallback: Uri.parse(fallbackUri)),
        Uri.parse(fallbackUri),
      );
      expect(env.getMap('NOPE', fallback: {'z': 0}), {'z': 0});
      expect(env.getMap('NOPE'), isEmpty);
    });

    test('secure keys are readable but hidden from all', () {
      final secure = EnvValues({'A': '1', 'B': '2'}, {'B'});
      expect(secure.all, {'A': '1'});
      expect(secure.getInt('B'), 2);
      expect(secure.isSecure('B'), isTrue);
      expect(secure.isSecure('A'), isFalse);
      expect(secure.containsKey('B'), isTrue);
    });
  });

  group('list items', () {
    test('are converted to the requested type', () {
      expect(parseEnvList<double>('1.5, 2'), [1.5, 2.0]);
      expect(parseEnvList<num>('1, 2.5'), [1, 2.5]);
      expect(parseEnvList<bool>('true, 0, FALSE'), [true, false, false]);
      expect(parseEnvList<Uri>('https://a.dev, /b'), [
        Uri.parse('https://a.dev'),
        Uri.parse('/b'),
      ]);
      expect(parseEnvList<String>('[1, "two"]'), ['1', 'two']);
    });

    test('keep JSON values for other types', () {
      expect(parseEnvList<dynamic>('[1, "a"]'), [1, 'a']);
      expect(parseEnvList<Map<String, dynamic>>('[{"a": 1}]'), [
        {'a': 1},
      ]);
      expect(parseEnvList<int>('[1, 2]'), [1, 2]);
    });

    test('return null when an item has the wrong type', () {
      expect(parseEnvList<bool>('true, maybe'), isNull);
      expect(parseEnvList<double>('1.5, x'), isNull);
      expect(parseEnvList<int>('[1, "x"]'), isNull);
      expect(parseEnvList<int>('[1, null]'), isNull);
      expect(parseEnvList<int>('[1, 2'), isNull);
      expect(parseEnvList<int>(null), isNull);
    });

    test('use a custom separator and skip empty items', () {
      expect(parseEnvList<String>('a; b;; c', separator: ';'), ['a', 'b', 'c']);
      expect(parseEnvList<String>(' , '), isEmpty);
    });

    test('converter exceptions return null', () {
      expect(
        parseEnvList<int>('a,b', fromJson: (_) => throw StateError('no')),
        isNull,
      );
      expect(parseEnvList<int>('a,b', fromJson: (e) => (e as String).length), [
        1,
        1,
      ]);
    });
  });
}
