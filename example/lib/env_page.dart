import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';

/// Feature flags stored as JSON in `FEATURES`, read with [PlayxEnv.getObject].
class FeatureFlags {
  final bool newCheckout;
  final int maxUploads;

  const FeatureFlags({this.newCheckout = false, this.maxUploads = 1});

  factory FeatureFlags.fromJson(dynamic json) => FeatureFlags(
    newCheckout: asBoolOr(json, 'newCheckout'),
    maxUploads: asIntOr(json, 'maxUploads', fallback: 1),
  );
}

/// Shows what [PlayxEnv] loaded: environment, files, typed and secure values.
class EnvPage extends StatelessWidget {
  const EnvPage({super.key});

  static const secureKeys = ['STRIPE_KEY', 'MAPS_API_KEY'];

  @override
  Widget build(BuildContext context) {
    final features = PlayxEnv.getObject(
      'FEATURES',
      fromJson: FeatureFlags.fromJson,
      fallback: const FeatureFlags(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Environment')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _Section('Loaded from'),
          _Row('Environment', PlayxEnv.environment ?? 'none (.env only)'),
          _Row('Files', PlayxEnv.loadedFiles.join(', ')),
          const _Section('Typed values'),
          _Row('API_URL (Uri)', '${PlayxEnv.maybeGetUri('API_URL')}'),
          _Row('ENABLE_LOGS (bool)', '${PlayxEnv.getBool('ENABLE_LOGS')}'),
          _Row(
            'THEME_MODE (enum)',
            PlayxEnv.getEnum(
              'THEME_MODE',
              ThemeMode.values,
              fallback: ThemeMode.system,
            ).name,
          ),
          _Row(
            'TIMEOUT (Duration)',
            '${PlayxEnv.getDuration('TIMEOUT', fallback: Duration.zero).inSeconds}s',
          ),
          _Row(
            'SUPPORTED_LOCALES (List)',
            PlayxEnv.getList<String>('SUPPORTED_LOCALES').join(' | '),
          ),
          _Row(
            'FEATURES (object)',
            'newCheckout: ${features.newCheckout}, '
                'maxUploads: ${features.maxUploads}',
          ),
          const _Section('Secure values (from .env.secrets)'),
          for (final key in secureKeys)
            _Row(
              key,
              _mask(PlayxEnv.maybeGetString(key)),
              trailing: PlayxEnv.isSecure(key)
                  ? const Icon(Icons.lock_outline, size: 18)
                  : null,
            ),
          const _Section('PlayxEnv.all (secure values excluded)'),
          _Row('Keys', (PlayxEnv.all.keys.toList()..sort()).join(', ')),
        ],
      ),
    );
  }

  /// Never display secrets in full.
  static String _mask(String? value) {
    if (value == null) return 'not set';
    if (value.length <= 4) return '••••';
    return '${value.substring(0, 4)}••••';
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      title,
      style: context.textTheme.titleSmall?.copyWith(color: context.primary),
    ),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _Row(this.label, this.value, {this.trailing});

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(label),
    subtitle: SelectableText(value),
    trailing: trailing,
  );
}
