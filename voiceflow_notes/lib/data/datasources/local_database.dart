import 'isar_database.dart';

/// Re-export the platform-aware database factory
export 'isar_database.dart' show createLocalDatabase;

/// Local database interface - platform-specific implementations
abstract class LocalDatabase {
  Future<void> initialize();
  Future<void> close();
}