import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/isar_note_model.dart';
import 'local_database.dart';

/// Isar database implementation for mobile platforms
class IsarLocalDatabase implements LocalDatabase {
  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw DatabaseException('Isar database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open(
        [IsarNoteModelSchema],
        directory: dir.path,
        name: 'voiceflow_notes',
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize Isar database: $e');
    }
  }

  @override
  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}

/// Extension to provide database access exception
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => message;
}

/// Web stub implementation using in-memory storage
class WebLocalDatabase implements LocalDatabase {
  @override
  Future<void> initialize() async {
    // Web will use Firebase or local storage
    // TODO: Implement web storage in Phase 12
  }

  @override
  Future<void> close() async {
    // No-op for web
  }
}

/// Factory function to create the appropriate database implementation
/// Used by local_database.dart to avoid circular imports
LocalDatabase createLocalDatabase() {
  if (kIsWeb) {
    return WebLocalDatabase();
  }
  return IsarLocalDatabase();
}