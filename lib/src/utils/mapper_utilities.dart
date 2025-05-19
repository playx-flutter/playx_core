import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:playx_core/playx_core.dart';

typedef Mapper<T, S> = FutureOr<S> Function(T data);

Future<S> _mapAsync<T, S>(List arguments) async {
  try {
    final data = arguments[0] as T;
    final mapper = arguments[1] as Mapper<T, S>;
    return await mapper(data);
  } catch (e) {
    rethrow;
  }
}

class MapUtils {
  MapUtils._();

  /// Maps the value of the future to a new value.
  static Future<S> mapAsync<T, S>(
      {required T data,
      required Mapper<T, S> mapper,
      bool printError = kDebugMode}) async {
    try {
      return mapper(data);
    } catch (e, s) {
      if (printError) {
        PlayxCore.logger.error(
            'MapAsync Error',
            error: e,
            stackTrace: s);
      }
      // Handle any errors in the main thread
      rethrow;
    }
  }

  /// Maps the value of the future to a new value in an isolate.
  /// If [useWorkManager] is set to true, it will use [workerManager] to execute the task.
  /// Otherwise, it will use [compute] to execute the task.
  static Future<S> mapAsyncInIsolate<T, S>({
    required T data,
    required Mapper<T, S> mapper,
    bool useWorkManager = true,
    bool printError = kDebugMode,
  }) async {
    try {
      final res = useWorkManager
          ? await workerManager.execute(() => _mapAsync<T, S>([data, mapper]))
          : await compute(_mapAsync<T, S>, [data, mapper]);
      return res;
    } catch (e, s) {
      if (printError) {
        PlayxCore.logger.error(
             'MapAsyncInIsolate Error',
            error: e,
            stackTrace: s);
      }
      // Handle errors occurring in the isolate
      rethrow;
    }
  }
}

extension MapAsync<T> on T {
  /// Maps the value of the T to a new value.
  Future<S> mapAsync<S>({
    required Mapper<T, S> mapper,
    bool printError = kDebugMode,
  }) =>
      MapUtils.mapAsync(data: this, mapper: mapper, printError: printError);

  //// Maps the value of the [T] to a new value in an isolate.
  /// If [useWorkManager] is set to true, it will use [WorkerManager] to execute the task.
  /// Otherwise, it will use [compute] to execute the task.
  Future<S> mapAsyncInIsolate<S>({
    required Mapper<T, S> mapper,
    bool useWorkManager = true,
    bool printError = kDebugMode,
  }) =>
      MapUtils.mapAsyncInIsolate(
          data: this,
          mapper: mapper,
          useWorkManager: useWorkManager,
          printError: printError);
}
