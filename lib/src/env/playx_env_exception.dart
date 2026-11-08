/// Thrown by [PlayxEnv.load] when required files or keys are missing.
class PlayxEnvException implements Exception {
  final String message;

  /// Files that couldn't be loaded, when [PlayxEnvSettings.isOptional] is `false`.
  final List<String> missingFiles;

  /// Keys from [PlayxEnvSettings.requiredKeys] without a value.
  final List<String> missingKeys;

  const PlayxEnvException(
    this.message, {
    this.missingFiles = const [],
    this.missingKeys = const [],
  });

  @override
  String toString() => 'PlayxEnvException: $message';
}
