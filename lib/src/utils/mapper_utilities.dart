import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:playx_core/playx_core.dart';

typedef Mapper<T, S> = FutureOr<S> Function(T data);

/// Callback used by [MapUtils] helpers to recover from an error thrown while
/// mapping [data]. The value returned by this callback is returned to the
/// caller instead of rethrowing the error.
typedef MapOnError<T, S> = S Function(T data, Object error, StackTrace stack);

Future<S> _mapAsync<T, S>(List arguments) async {
  final data = arguments[0] as T;
  final mapper = arguments[1] as Mapper<T, S>;
  return await mapper(data);
}

class MapUtils {
  MapUtils._();

  /// Maps the value of the future to a new value.
  ///
  /// If [onError] is provided, any error thrown while running [mapper] is
  /// caught, logged when [printError] is `true`, and the value returned by
  /// [onError] is returned instead of rethrowing. If [onError] is `null`
  /// (the default), the error is rethrown after logging.
  static Future<S> mapAsync<T, S>({
    required T data,
    required Mapper<T, S> mapper,
    bool printError = kDebugMode,
    MapOnError<T, S>? onError,
  }) async {
    try {
      return await mapper(data);
    } catch (e, s) {
      if (printError) {
        PlayxCore.logger.error('MapAsync Error', error: e, stackTrace: s);
      }
      if (onError != null) {
        return onError(data, e, s);
      }
      // Handle any errors in the main thread
      rethrow;
    }
  }

  /// Maps the value of the future to a new value in an isolate.
  /// If [useWorkManager] is set to true, it will use [workerManager] to execute the task.
  /// Otherwise, it will use [compute] to execute the task.
  ///
  /// If [onError] is provided, any error thrown while running [mapper] (or
  /// while dispatching the task to the isolate) is caught, logged when
  /// [printError] is `true`, and the value returned by [onError] is returned
  /// instead of rethrowing. If [onError] is `null` (the default), the error is
  /// rethrown after logging.
  static Future<S> mapAsyncInIsolate<T, S>({
    required T data,
    required Mapper<T, S> mapper,
    bool useWorkManager = true,
    bool printError = kDebugMode,
    MapOnError<T, S>? onError,
  }) async {
    try {
      final res = useWorkManager
          ? await workerManager.execute(() => _mapAsync<T, S>([data, mapper]))
          : await compute(_mapAsync<T, S>, [data, mapper]);
      return res;
    } catch (e, s) {
      if (printError) {
        PlayxCore.logger
            .error('MapAsyncInIsolate Error', error: e, stackTrace: s);
      }
      if (onError != null) {
        return onError(data, e, s);
      }
      // Handle errors occurring in the isolate
      rethrow;
    }
  }
}

extension MapAsync<T> on T {
  /// Maps the value of the T to a new value.
  ///
  /// If [onError] is provided, any error thrown while running [mapper] is
  /// caught, logged when [printError] is `true`, and the value returned by
  /// [onError] is returned instead of rethrowing. If [onError] is `null`
  /// (the default), the error is rethrown after logging.
  Future<S> mapAsync<S>({
    required Mapper<T, S> mapper,
    bool printError = kDebugMode,
    MapOnError<T, S>? onError,
  }) =>
      MapUtils.mapAsync(
          data: this,
          mapper: mapper,
          printError: printError,
          onError: onError);

  //// Maps the value of the [T] to a new value in an isolate.
  /// If [useWorkManager] is set to true, it will use [WorkerManager] to execute the task.
  /// Otherwise, it will use [compute] to execute the task.
  ///
  /// If [onError] is provided, any error thrown while running [mapper] (or
  /// while dispatching the task to the isolate) is caught, logged when
  /// [printError] is `true`, and the value returned by [onError] is returned
  /// instead of rethrowing. If [onError] is `null` (the default), the error is
  /// rethrown after logging.
  Future<S> mapAsyncInIsolate<S>({
    required Mapper<T, S> mapper,
    bool useWorkManager = true,
    bool printError = kDebugMode,
    MapOnError<T, S>? onError,
  }) =>
      MapUtils.mapAsyncInIsolate(
          data: this,
          mapper: mapper,
          useWorkManager: useWorkManager,
          printError: printError,
          onError: onError);
}
