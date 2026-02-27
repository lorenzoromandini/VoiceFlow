import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for local database
/// This is a placeholder - actual implementation will be platform-specific
final localDatabaseProvider = Provider<void>((ref) {
  return;
});

/// This provider will be overridden in platform-specific main files
/// For now, we're skipping database initialization to allow web builds
