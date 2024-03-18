import 'dart:async';

/// Extensions on [Future] to provide additional functionality.
extension FutureExtensions<T> on Future<T> {
  /// Maps the value of the future to a new value.
  Future<R> map<R>(FutureOr<R> Function(T) transform) async {
    final value = await this;
    return transform(value);
  }
}
