extension BoolExtensions on bool {
  /// Convert bool to int
  /// return 1 if true, 0 if false
  int toInt() => this ? 1 : 0;

  /// Reverse the value of bool
  bool toggle() => !this;

}
