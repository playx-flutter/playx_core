import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  test('PlayxEnvException exposes its details', () {
    const exception = PlayxEnvException(
      'Missing env files: .env.prod',
      missingFiles: ['.env.prod'],
      missingKeys: ['API_URL'],
    );
    expect(exception.message, 'Missing env files: .env.prod');
    expect(exception.missingFiles, ['.env.prod']);
    expect(exception.missingKeys, ['API_URL']);
    expect(
      exception.toString(),
      'PlayxEnvException: Missing env files: .env.prod',
    );
    expect(exception, isA<Exception>());
  });

  test('missing files and keys default to empty', () {
    const exception = PlayxEnvException('failed');
    expect(exception.missingFiles, isEmpty);
    expect(exception.missingKeys, isEmpty);
  });
}
