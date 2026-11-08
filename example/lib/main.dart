import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';

import 'env_page.dart';
import 'generated/playx_secure_env.g.dart';

/// Env settings used by the app (and its tests).
const envSettings = PlayxEnvSettings(
  // Encrypted values generated from .env.secrets with
  // `dart run playx_core:secure_env`.
  secureEnv: playxSecureEnv,
  // Fail at startup, listing every missing key.
  requiredKeys: ['API_URL', 'STRIPE_KEY'],
  // A single build-time value: flutter run --dart-define=APP_NAME=Demo
  dartDefines: {'APP_NAME': String.fromEnvironment('APP_NAME')},
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlayxCore.bootCore(
    envSettings: envSettings,
    // Readable logs: the time on every line. Colors are dropped automatically
    // where the console cannot show them.
    loggerSettings: PlayxLoggerSettings(
      useColors: true,
      printDateTime: true,
      formatter: const ExtendedLoggerFormatter(),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = PlayxEnv.getString('APP_NAME', fallback: 'Playx Core');
    return MaterialApp(
      title: appName,
      themeMode: PlayxEnv.getEnum(
        'THEME_MODE',
        ThemeMode.values,
        fallback: ThemeMode.system,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = PlayxPrefs.getInt('counter', fallback: 0);

  void _incrementCounter() {
    setState(() {
      _counter++;
      PlayxPrefs.setInt('counter', _counter);
      PlayxLogger.i('Counter: $_counter');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Environment',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const EnvPage())),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: context.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'API: ${PlayxEnv.getString('API_URL')}',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
