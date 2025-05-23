import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../playx_core.dart';

/// Extensions on [Iterable] class to make it easier to work with.
extension PlayxIterableExtensions<T> on Iterable<T> {
  /// Count the number of elements that satisfy predicate [predicate].
  int countWhere([
    bool Function(T element)? predicate,
  ]) =>
      predicate == null ? length : where(predicate).length;

  /// Count the number of elements that are not null.
  int countNotNull() => countWhere((e) => e != null);

  /// Asynchronously map each element of this collection by [action].
  Future<List<S>> asyncMap<S>({
    required Mapper<T, S> mapper,
  }) =>
      Future.wait(map((i) async => mapper(i)));

  /// Maps the value of the [List] of type [T] to a new value of type [S] in an isolate.
  Future<List<S>> asyncMapInIsolate<S>({
    required Mapper<T, S> mapper,
    bool useWorkManager = true,
    bool printError = kDebugMode,
    bool printEachItemError = false,
  }) async {
    try {
      final res = await Future.wait(map((e) => e.mapAsyncInIsolate(
          mapper: mapper,
          useWorkManager: useWorkManager,
          printError: printEachItemError)));
      return res;
    } catch (e, s) {
      if (printError) {
        PlayxCore.logger
            .error('AsyncMapInIsolate Error', error: e, stackTrace: s);
      }
      rethrow;
    }
  }

  /// Returns a new list after removing duplicates from the original list.
  List<T> withoutDuplicate() => toSet().toList();

  /// Returns a random item from the list or `null` if the list is empty.
  T? get random => isEmpty ? null : atOrNull(Random().nextInt(length));

  /// Returns first element if list is not empty.
  T? firstOrNull() => isEmpty ? null : first;

  /// Returns the first element if list is not empty. Otherwise, return `value`
  T firstOr(T value) => firstOrNull() ?? value;

  /// Returns last element if list is not empty.
  T? lastOrNull() => isEmpty ? null : last;

  /// Returns the last element if list is not empty. Otherwise, return `value`
  T lastOr(T value) => lastOrNull() ?? value;

  /// Checks if the item with [index] exists or not in the list.
  bool isIndexValid(int index) => index >= 0 && index < length;

  /// Returns the element at the given [index] or `null` if the [index] is out of bounds of this list.
  T? atOrNull(int index) => isIndexValid(index) ? elementAt(index) : null;

  /// Returns the element at the given [index] or [value] if the [index] is out of bounds of this list.
  T atOr(int index, T value) => isIndexValid(index) ? elementAt(index) : value;

  /// Returns the element where equals predicate or `null` if not found.
  T? firstWhereOrNull(bool Function(T e) predicate) {
    try {
      return firstWhere(predicate, orElse: null);
    } catch (e) {
      return null;
    }
  }

  /// Returns the element where equals predicate or [value] if not found.
  T firstWhereOr(bool Function(T e) predicate, T value) {
    try {
      return firstWhere(predicate, orElse: () => value);
    } catch (e) {
      return value;
    }
  }

  /// Returns the element where equals predicate or `null` if not found.
  T? lastWhereOrNull(bool Function(T e) predicate) {
    try {
      return lastWhere(predicate, orElse: null);
    } catch (e) {
      return null;
    }
  }

  /// Returns the element where equals predicate or [value] if not found.
  T lastWhereOr(bool Function(T e) predicate, T value) {
    try {
      return lastWhere(predicate, orElse: () => value);
    } catch (e) {
      return value;
    }
  }

  /// Map each element of the list to a [MapEntry] with it's index and returns the resulting map.
  List<E> mapWithIndex<E>(E Function(int index, T element) mapper) {
    final result = <E>[];
    for (int i = 0; i < length; i++) {
      result.add(mapper(i, elementAt(i)));
    }
    return result;
  }
}

extension NestedIterablesExtensions<T> on Iterable<Iterable<T>> {
  /// Returns a new list after flattening the original Iterable of Iterables.
  List<T> flatten() => [for (final sublist in this) ...sublist];

  /// Returns a new list after flattening the original Iterable of Iterables and then mapping each element.
  Iterable<S> flatMap<S>({
    required S Function(T data) mapper,
  }) =>
      flatten().map((e) => mapper(e));

  /// Returns a new list after flattening the original Iterable of Iterables and then mapping each element asynchronously.
  @Deprecated('Use flatMapAsync instead.')
  Future<Iterable<X>> asyncFlatMap<X>(Future<X> Function(T) f) async =>
      flatten().asyncMap(mapper: f);

  /// Returns a new list after flattening the original Iterable of Iterables and then mapping each element asynchronously.
  Future<Iterable<S>> flatMapAsync<S>({
    required Mapper<T, S> mapper,
  }) async =>
      flatten().asyncMap(
        mapper: mapper,
      );
}
