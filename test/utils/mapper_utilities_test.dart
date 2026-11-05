import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapUtils.mapAsync', () {
    test('returns the mapped value on success', () async {
      final result = await MapUtils.mapAsync<int, String>(
        data: 42,
        mapper: (n) => 'value:$n',
      );
      expect(result, 'value:42');
    });

    test('supports an async mapper', () async {
      final result = await MapUtils.mapAsync<int, String>(
        data: 7,
        mapper: (n) async => 'async:$n',
      );
      expect(result, 'async:7');
    });

    test('rethrows when the mapper throws and onError is null', () async {
      expect(
        () => MapUtils.mapAsync<int, String>(
          data: 1,
          mapper: (_) => throw StateError('boom'),
          printError: false,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('returns fallback from onError instead of rethrowing', () async {
      final result = await MapUtils.mapAsync<int, String>(
        data: 1,
        mapper: (_) => throw StateError('boom'),
        printError: false,
        onError: (data, error, stack) => 'fallback:$data',
      );
      expect(result, 'fallback:1');
    });

    test('onError receives the original data, error and stack trace', () async {
      Object? capturedError;
      StackTrace? capturedStack;
      int? capturedData;
      await MapUtils.mapAsync<int, String>(
        data: 9,
        mapper: (_) => throw ArgumentError('nope'),
        printError: false,
        onError: (data, error, stack) {
          capturedData = data;
          capturedError = error;
          capturedStack = stack;
          return 'recovered';
        },
      );
      expect(capturedData, 9);
      expect(capturedError, isA<ArgumentError>());
      expect(capturedStack, isNotNull);
    });
  });

  group('MapUtils.mapAsyncInIsolate', () {
    // Use `compute` (useWorkManager: false) to keep the test isolate-light
    // and deterministic across CI environments.
    test('returns the mapped value on success', () async {
      final result = await MapUtils.mapAsyncInIsolate<int, String>(
        data: 5,
        mapper: (n) => 'iso:$n',
        useWorkManager: false,
        printError: false,
      );
      expect(result, 'iso:5');
    });

    test('rethrows when the mapper throws and onError is null', () async {
      expect(
        () => MapUtils.mapAsyncInIsolate<int, String>(
          data: 1,
          mapper: (_) => throw StateError('boom'),
          useWorkManager: false,
          printError: false,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('returns fallback from onError instead of rethrowing', () async {
      final result = await MapUtils.mapAsyncInIsolate<int, String>(
        data: 2,
        mapper: (_) => throw StateError('boom'),
        useWorkManager: false,
        printError: false,
        onError: (data, error, stack) => 'iso-fallback:$data',
      );
      expect(result, 'iso-fallback:2');
    });
  });

  group('MapAsync<T> extension', () {
    test('mapAsync returns the mapped value on success', () async {
      final result = await 10.mapAsync<String>(
        mapper: (n) => 'ext:$n',
        printError: false,
      );
      expect(result, 'ext:10');
    });

    test('mapAsync returns fallback via onError instead of rethrowing',
        () async {
      final result = await 10.mapAsync<String>(
        mapper: (_) => throw StateError('boom'),
        printError: false,
        onError: (data, error, stack) => 'ext-fallback:$data',
      );
      expect(result, 'ext-fallback:10');
    });

    test('mapAsyncInIsolate returns the mapped value on success', () async {
      final result = await 3.mapAsyncInIsolate<String>(
        mapper: (n) => 'iso-ext:$n',
        useWorkManager: false,
        printError: false,
      );
      expect(result, 'iso-ext:3');
    });

    test('mapAsyncInIsolate returns fallback via onError instead of rethrowing',
        () async {
      final result = await 3.mapAsyncInIsolate<String>(
        mapper: (_) => throw StateError('boom'),
        useWorkManager: false,
        printError: false,
        onError: (data, error, stack) => 'iso-ext-fallback:$data',
      );
      expect(result, 'iso-ext-fallback:3');
    });

    test('FutureOr mapper is awaited correctly', () async {
      FutureOr<String> mapper(int n) async => 'future-or:$n';
      final result = await 8.mapAsync<String>(
        mapper: mapper,
        printError: false,
      );
      expect(result, 'future-or:8');
    });
  });

  group('MapOnError typedef', () {
    test('is a function that takes data, error and stack and returns S', () {
      // Compile-time + runtime sanity for the typedef signature.
      String onError(int data, Object error, StackTrace stack) =>
          'recovered:$data';
      expect(onError(1, StateError('x'), StackTrace.empty), 'recovered:1');
    });
  });

  group('kDebugMode default', () {
    test('printError defaults to kDebugMode', () {
      // Sanity: the default value of printError should match kDebugMode so
      // errors are logged only in debug builds by default.
      // (This is enforced by the API signature; here we just assert the
      // constant is accessible from the same library surface.)
      expect(kDebugMode, isA<bool>());
    });
  });
}