import 'package:isar/isar.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local_database.dart';
import '../models/isar_note_model.dart';

/// Isar implementation of NoteRepository
class IsarNoteRepository implements NoteRepository {
  final LocalDatabase _database;

  IsarNoteRepository(this._database);

  Isar get _isar {
    if (_database is! IsarLocalDatabase) {
      throw DatabaseException('Expected IsarLocalDatabase, got ${_database.runtimeType}');
    }
    return (_database as IsarLocalDatabase).isar;
  }

  @override
  Stream<List<Note>> getNotesStream() {
    return _isar.isarNoteModels
        .where()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Result<List<Note>>> getAllNotes() async {
    try {
      final models = await _isar.isarNoteModels
          .where()
          .isDeletedEqualTo(false)
          .sortByUpdatedAtDesc()
          .findAll();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.databaseError,
        'Failed to load notes: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<Note?>> getNoteById(String id) async {
    try {
      final model = await _isar.isarNoteModels
          .where()
          .uuidEqualTo(id)
          .findFirst();
      return Success(model?.toEntity());
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.databaseError,
        'Failed to load note: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<Note>> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final note = Note(
        id: '${now.millisecondsSinceEpoch}_${title.hashCode}',
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      final model = IsarNoteModel.fromEntity(note);

      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.put(model);
      });

      return Success(note);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.saveFailed,
        'Failed to create note: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> updateNote(Note note) async {
    try {
      final existing = await _isar.isarNoteModels
          .where()
          .uuidEqualTo(note.id)
          .findFirst();

      if (existing == null) {
        return Failure(NoteException(
          NoteErrorCode.notFound,
          'Note not found: ${note.id}',
        ));
      }

      final updated = existing.copyWith(
        title: note.title,
        content: note.content,
        updatedAt: DateTime.now(),
        isSynced: note.isSynced,
        userId: note.userId,
      );

      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.put(updated);
      });

      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.saveFailed,
        'Failed to update note: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    // Soft delete - move to trash instead of permanent deletion
    return moveToTrash(id);
  }

  @override
  Future<Result<void>> moveToTrash(String id) async {
    try {
      final model = await _isar.isarNoteModels
          .where()
          .uuidEqualTo(id)
          .findFirst();

      if (model == null) {
        return Failure(NoteException(
          NoteErrorCode.notFound,
          'Note not found: $id',
        ));
      }

      final trashed = model.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.put(trashed);
      });

      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.deleteFailed,
        'Failed to move note to trash: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> restoreFromTrash(String id) async {
    try {
      final model = await _isar.isarNoteModels
          .where()
          .uuidEqualTo(id)
          .findFirst();

      if (model == null) {
        return Failure(NoteException(
          NoteErrorCode.notFound,
          'Note not found: $id',
        ));
      }

      final restored = model.copyWith(
        isDeleted: false,
        deletedAt: null,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.put(restored);
      });

      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.saveFailed,
        'Failed to restore note: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<Note>>> getTrashedNotes() async {
    try {
      final models = await _isar.isarNoteModels
          .where()
          .isDeletedEqualTo(true)
          .sortByDeletedAtDesc()
          .findAll();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.databaseError,
        'Failed to load trashed notes: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> permanentlyDeleteNote(String id) async {
    try {
      final model = await _isar.isarNoteModels
          .where()
          .uuidEqualTo(id)
          .findFirst();

      if (model == null) {
        return Failure(NoteException(
          NoteErrorCode.notFound,
          'Note not found: $id',
        ));
      }

      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.delete(model.id);
      });

      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.deleteFailed,
        'Failed to delete note: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<int>> emptyTrash() async {
    try {
      // Find all notes in trash older than 15 days
      final fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
      
      final trashedModels = await _isar.isarNoteModels
          .where()
          .isDeletedEqualTo(true)
          .findAll();

      final modelsToDelete = trashedModels.where((m) {
        if (m.deletedAt == null) return false;
        return m.deletedAt!.isBefore(fifteenDaysAgo);
      }).toList();

      await _isar.writeTxn(() async {
        for (final model in modelsToDelete) {
          await _isar.isarNoteModels.delete(model.id);
        }
      });

      return Success(modelsToDelete.length);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.deleteFailed,
        'Failed to empty trash: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<Note>>> searchNotes(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      
      // Search in title and content for non-deleted notes
      final models = await _isar.isarNoteModels
          .where()
          .isDeletedEqualTo(false)
          .findAll();

      final matches = models.where((m) {
        return m.title.toLowerCase().contains(lowerQuery) ||
            m.content.toLowerCase().contains(lowerQuery);
      }).toList();

      // Sort by updatedAt descending
      matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return Success(matches.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.databaseError,
        'Failed to search notes: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<int>> getNotesCount() async {
    try {
      final count = await _isar.isarNoteModels
          .where()
          .isDeletedEqualTo(false)
          .count();
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.databaseError,
        'Failed to count notes: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> deleteAllNotes() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.isarNoteModels.clear();
      });
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(NoteException(
        NoteErrorCode.deleteFailed,
        'Failed to delete all notes: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
