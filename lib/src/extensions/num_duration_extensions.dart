/// Adds extensions to num (ie. int & double) to make creating durations simple:
///
/// ```
/// 100.ms // equivalent to Duration(milliseconds: 100)
/// 5.hours // equivalent to Duration(hours: 5)
/// 1.5.days // equivalent to Duration(hours: 36)
/// ```
extension NumDurationExtensions on num {
  Duration get microseconds => Duration(microseconds: round());
  Duration get ms => (this * 1000).microseconds;
  Duration get milliseconds => (this * 1000).microseconds;

  /// converts seconds of num type to a Duration
  /// ```
  /// 3.seconds // equivalent to Duration(milliseconds: 3000)
  /// ```
  Duration get seconds => (this * 1000 * 1000).microseconds;
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}
