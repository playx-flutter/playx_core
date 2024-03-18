/// Extensions that can be used on any type [T] by using kotlin inspired scope functions.
extension ScopeFunctionExtensions<T> on T {
  /// Calls the specified function [block] with `this` value as its argument and
  /// returns its result.
  /// Often used for executing a code block only with non-null values.
  //
  // someNullable?.let((it) { ... });
  R let<R>(R Function(T it) block) {
    return block.call(this);
  }

  /// Calls the specified function [block] with this value as its argument and
  /// returns `this` value.
  /// also
  /// Used for additional actions that don't alter the object, such as logging or printing debug information.
  ///something.also((it) { ... }); // returns something.
  T also(void Function(T it) block) {
    block.call(this);
    return this;
  }

  /// Returns `this` value if it satisfies the given [predicate] or null if
  /// it doesn't.
  /// Used for checking some condition and returning the object itself if it matches the condition.
  /// someNullable?.takeIf((it) => it > 5); // returns someNullable if it is greater than 5.
  T? takeIf(bool Function(T it) predicate) {
    return predicate.call(this) ? this : null;
  }

  /// Returns `this` value if it does not satisfy the given [predicate] or
  /// null if it does.
  /// Used for checking some condition and returning the object itself if it doesn't match the condition.
  /// someNullable?.takeUnless((it) => it > 5); // returns someNullable if it is not greater than 5.
  T? takeUnless(bool Function(T it) predicate) {
    return predicate.call(this) ? null : this;
  }

  /// Calls the specified function [block] and returns its result.
  /// Used for evaluating a block of several statements where an expression is required.
  /// someNullable ?? run(() {
  //   var defaultValue = ......;
  //   // several process...
  //
  //   return defaultValue;
  // });
  T run(T Function() block) => block.call();
}
