import '../../core/utils/result.dart';
import '../entities/note.dart';

/// Repository interface for Note operations
/// Abstracts data source from business logic
abstract class NoteRepository {
  /// Get all notes sorted by update time (newest first)
  /// Returns stream for reactive updates
  Stream<List<Note>> getNotesStream();

  /// Get all notes (one-time fetch)
  Future<Result<List<Note>>> getAllNotes();

  /// Get single note by ID
  Future<Result<Note?>> getNoteById(String id);

  /// Create new note
  Future<Result<Note>> createNote({
    required String title,
    required String content,
  });

  /// Update existing note
  Future<Result<void>> updateNote(Note note);

  /// Delete note by ID
  Future<Result<void>> deleteNote(String id);

  /// Search notes by title or content
  Future<Result<List<Note>>> searchNotes(String query);

  /// Get notes count
  Future<Result<int>> getNotesCount();

  /// Delete all notes (for testing/debugging)
  Future<Result<void>> deleteAllNotes();

  /// Move note to trash (soft delete)
  Future<Result<void>> moveToTrash(String id);

  /// Restore note from trash
  Future<Result<void>> restoreFromTrash(String id);

  /// Get all trashed notes
  Future<Result<List<Note>>> getTrashedNotes();

  /// Get stream of trashed notes for reactive updates
  Stream<List<Note>> getTrashedNotesStream();

  /// Permanently delete note (bypass trash)
  Future<Result<void>> permanentlyDeleteNote(String id);

  /// Permanently delete notes older than 15 days in trash
  Future<Result<int>> emptyTrash();
}
