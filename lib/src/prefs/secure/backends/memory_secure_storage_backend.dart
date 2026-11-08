import '../settings/secure_storage_type.dart';
import 'secure_storage_backend.dart';

/// Backend that keeps values in memory only.
class MemorySecureStorageBackend implements PlayxSecureStorageBackend {
  final Map<String, String> _values = {};

  @override
  PlayxSecureStorageType get type => PlayxSecureStorageType.memory;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<Map<String, String>> readAll() async => Map.of(_values);
}
