import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/build_llms.dart';

void main() {
  test('doc/llms.txt and doc/llms-full.txt are up to date', () {
    final (index, full) = buildLlms(Directory('doc'));
    expect(
      File('doc/llms.txt').readAsStringSync(),
      index,
      reason: 'Run `dart run tool/build_llms.dart` and commit the result.',
    );
    expect(
      File('doc/llms-full.txt').readAsStringSync(),
      full,
      reason: 'Run `dart run tool/build_llms.dart` and commit the result.',
    );
  });
}
