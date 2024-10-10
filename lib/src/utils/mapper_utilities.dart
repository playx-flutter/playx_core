import 'dart:async';

import 'package:flutter/foundation.dart';

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
  static Future<S> mapAsync<T, S>(T data, Mapper<T, S> mapper) async {
    try {
      return mapper(data);
    } catch (e) {
      // Handle any errors in the main thread
      rethrow;
    }
  }

  /// Maps the value of the future to a new value in an isolate.
  static Future<S> mapAsyncInIsolate<T, S>(T data, Mapper<T, S> mapper) async {
    try {
      final res = await compute(_mapAsync<T, S>, [data, mapper]);
      return res;
    } catch (e) {
      // Handle errors occurring in the isolate
      rethrow;
    }
  }
}

extension MapAsync<T> on T {
  /// Maps the value of the T to a new value.
  Future<S> mapAsync<S>(Mapper<T, S> mapper) async {
    return MapUtils.mapAsync(this, mapper);
  }

  //// Maps the value of the T to a new value in an isolate.
  Future<S> mapAsyncInIsolate<S>(Mapper<T, S> mapper) async {
    return MapUtils.mapAsyncInIsolate(this, mapper);
  }
}
