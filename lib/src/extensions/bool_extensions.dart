extension BoolExtensions on bool {
  /// Convert bool to int
  /// return 1 if true, 0 if false
  int toInt() => this ? 1 : 0;

  /// Reverse the value of bool
  bool toggle() => !this;
}

/// Extensions for nullable booleans.
extension NullableBoolExtensions on bool? {
  /// Returns `true` only if the value is explicitly `true`.
  bool get isTrue => this == true;

  /// Returns `true` only if the value is explicitly `false`.
  bool get isFalse => this == false;
}
