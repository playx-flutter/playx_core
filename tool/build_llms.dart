// Builds `doc/llms.txt` (an index for LLMs, https://llmstxt.org) and
// `doc/llms-full.txt` (every guide in one file) from the guides in `doc/`.
//
//   dart run tool/build_llms.dart
//
// `mkdocs` copies both files to the root of the documentation site. A test
// fails when they are out of date.
import 'dart:io';

const siteUrl = 'https://playx-flutter.github.io/playx_core/';

/// The guides in reading order: file name, section and summary.
const guides = <(String, String, String)>[
  (
    'getting-started.md',
    'Guides',
    'Install, `PlayxCore.bootCore` and what it sets up, dependency injection '
        'with GetIt.',
  ),
  (
    'preferences.md',
    'Guides',
    '`PlayxPrefs`, `PlayxAsyncPrefs` and `PlayxPrefsWithCache`: typed '
        'shared_preferences helpers.',
  ),
  (
    'secure-prefs.md',
    'Guides',
    '`PlayxSecurePrefs`: encrypted storage for tokens and credentials, with a '
        'choice of backend.',
  ),
  (
    'env.md',
    'Guides',
    '`PlayxEnv`: typed config from `.env` files, flavors and `--dart-define`.',
  ),
  (
    'secure-env.md',
    'Guides',
    'Encrypt secret env values into a generated Dart file with '
        '`dart run playx_core:secure_env`, including CI setups.',
  ),
  (
    'extensions.md',
    'Guides',
    'Extensions for String, Iterable, DateTime, Duration, Future, Color, '
        'borders, padding, Locale and BuildContext.',
  ),
  (
    'utilities.md',
    'Guides',
    'Safe conversion, safe JSON access, `MapUtils`, system UI, clipboard, '
        'platform checks, `WebUtils`, colors and scroll behavior.',
  ),
  (
    'logging.md',
    'Guides',
    '`PlayxLogger`: levels, named loggers, message layout, colors, output '
        'targets and custom backends.',
  ),
  (
    'testing.md',
    'Guides',
    'Testing code that uses playx_core, and running this package\'s tests.',
  ),
  ('migration-2.0.md', 'Optional', 'Checklist for upgrading from 1.x to 2.0.'),
];

String _title(String markdown) =>
    RegExp(r'^# (.+)$', multiLine: true).firstMatch(markdown)!.group(1)!;

String _url(String file) => '$siteUrl${file.replaceAll('.md', '/')}';

/// Returns the content of `llms.txt` and `llms-full.txt`.
(String index, String full) buildLlms(Directory doc) {
  final pages = {
    for (final (file, _, _) in guides)
      file: File('${doc.path}/$file').readAsStringSync().trim(),
  };

  final index = StringBuffer()
    ..writeln('# playx_core')
    ..writeln()
    ..writeln(
      '> Flutter package: typed preferences, encrypted secure storage, '
      'environment configuration (with encrypted secrets), extensions, '
      'utilities and logging. One import: '
      "`package:playx_core/playx_core.dart`.",
    )
    ..writeln()
    ..writeln(
      'Call `PlayxCore.bootCore()` once before `runApp`. Requires Dart 3.12 '
      'and Flutter 3.44. Every guide is also in one file: '
      '[llms-full.txt](${siteUrl}llms-full.txt).',
    );
  for (final section in ['Guides', 'Optional']) {
    index
      ..writeln()
      ..writeln('## $section')
      ..writeln();
    for (final (file, _, summary) in guides.where((g) => g.$2 == section)) {
      index.writeln('- [${_title(pages[file]!)}](${_url(file)}): $summary');
    }
    if (section == 'Optional') {
      index
        ..writeln('- [API reference](${siteUrl}api/): every class and method')
        ..writeln(
          '- [Changelog](https://pub.dev/packages/playx_core/changelog): '
          'release notes',
        );
    }
  }

  final full = StringBuffer()
    ..writeln('# playx_core documentation')
    ..writeln()
    ..writeln('Source: $siteUrl. Generated from the guides; do not edit.');
  for (final (file, _, _) in guides) {
    full
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('<!-- ${_url(file)} -->')
      ..writeln(pages[file]);
  }
  return (index.toString(), full.toString());
}

void main() {
  final (index, full) = buildLlms(Directory('doc'));
  File('doc/llms.txt').writeAsStringSync(index);
  File('doc/llms-full.txt').writeAsStringSync(full);
  stdout.writeln('Wrote doc/llms.txt and doc/llms-full.txt');
}
