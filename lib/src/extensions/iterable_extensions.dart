import 'dart:async';
import 'dart:math';

/// Extensions on [Iterable] class to make it easier to work with.
extension IterableExtensions<T> on Iterable<T> {
  /// Count the number of elements that satisfy predicate [predicate].
  int countWhere([
    bool Function(T element)? predicate,
  ]) =>
      predicate == null ? length : where(predicate).length;

  /// Count the number of elements that are not null.
  int countNotNull() => countWhere((e) => e != null);

  /// For each element of the iterable, apply [action] to the element asynchronously.
  Future<void> asyncForEach(
    FutureOr<void> Function(T e) action,
  ) async {
    for (final item in this) {
      await action(item);
    }
  }

  /// Asynchronously map each element of this collection by [action].
  Future<List<S>> asyncMap<S>(
    FutureOr<S> Function(T e) action,
  ) async {
    final list = <S>[];
    for (final item in this) {
      list.add(await action(item));
    }
    return list;
  }

  /// Returns a new list after removing duplicates from the original list.
  List<T> withoutDuplicate() => toSet().toList();

  /// Returns a random item from the list or `null` if the list is empty.
  T? get random => atOrNull(Random().nextInt(length));

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
  T? atOrNull(int index) =>
      isIndexValid(index) ? elementAt(index) : null;

  /// Returns the element at the given [index] or [value] if the [index] is out of bounds of this list.
  T atOr(int index, T value) => isIndexValid(index) ? elementAt(index) : value;


  /// Returns the element where equals predicate or `null` if not found.
  T? firstWhereOrNull(bool Function(T e) predicate) {
    try {
      return firstWhere(predicate);
    } catch (e) {
      if (e is StateError) return null;
      rethrow;
    }
  }

  /// * like `map()` function but now you have the index with the element
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
  Iterable<X> flatMap<X>(X Function(T) f) => flatten().map(f);

  /// Returns a new list after flattening the original Iterable of Iterables and then mapping each element asynchronously.
  Future<Iterable<X>> asyncFlatMap<X>(Future<X> Function(T) f) async => flatten().asyncMap(f);
}

