import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voiceflow_notes/data/datasources/local_database.dart';

// Core providers
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});
