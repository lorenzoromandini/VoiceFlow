import 'package:flutter/foundation.dart';

/// Local database interface - platform-specific implementations
abstract class LocalDatabase {
  Future<void> initialize();
  Future<void> close();
}

/// Factory that creates the appropriate database implementation
class LocalDatabaseFactory {
  static LocalDatabase create() {
    if (kIsWeb) {
      return _WebDatabase();
    } else {
      // Import the mobile implementation
      return _MobileDatabase();
    }
  }
}

/// Web stub implementation
class _WebDatabase implements LocalDatabase {
  @override
  Future<void> initialize() async {
    // Web will use Firebase or local storage
  }

  @override
  Future<void> close() async {
    // No-op for web
  }
}

/// Mobile database with Isar - imported separately to avoid web compilation issues
/// This will be implemented in a separate file that's only imported on mobile
class _MobileDatabase implements LocalDatabase {
  @override
  Future<void> initialize() async {
    // Mobile implementation - will be loaded from isar_database.dart
    throw UnimplementedError(
      'Mobile database not loaded. Ensure isar_database.dart is imported on mobile platforms.'
    );
  }

  @override
  Future<void> close() async {
    // No-op
  }
}
