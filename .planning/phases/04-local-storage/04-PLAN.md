# Phase 4 Plan: Local Storage & Note CRUD

**Phase:** 4 - Local Storage Architecture  
**Goal:** Notes persist locally with proper data models, repositories, and local-first persistence patterns.

---

## Plan Overview

| Plan ID | Name | Wave | Est. Time | Autonomous |
|---------|------|------|-----------|------------|
| 04-01 | Complete Isar Note Model | 1 | 20 min | Yes |
| 04-02 | Create Note Repository Interface | 1 | 15 min | Yes |
| 04-03 | Implement Isar Note Repository | 2 | 30 min | Yes |
| 04-04 | Create Note Use Cases | 2 | 25 min | Yes |
| 04-05 | Configure Note Providers | 3 | 20 min | Yes |
| 04-06 | Integrate Note List in Home Page | 3 | 25 min | Yes |
| 04-07 | Implement Note Editor with Auto-Save | 4 | 30 min | Yes |
| 04-08 | Add Note Creation Flow | 4 | 20 min | Yes |
| 04-09 | Implement Delete with Confirmation | 5 | 15 min | Yes |
| 04-10 | Test CRUD Operations | 5 | 15 min | Yes |

**Total Plans:** 10  
**Total Est. Time:** ~3.5 hours  
**Waves:** 5

---

## Wave 1: Data Models (35 min)

### Plan 04-01: Complete Isar Note Model (with Trash)

**Task:** Finalize Note entity with all fields including trash functionality

```xml
<task>
  <action>Update Note domain entity</action>
  <edit file="lib/domain/entities/note.dart">
    import 'package:equatable/equatable.dart';

    /// Domain entity for a Note
    /// Represents a text note with metadata and trash state
    class Note extends Equatable {
      final String id;                    // UUID for cross-platform sync
      final String title;                  // Note title
      final String content;                // Note content (transcribed text)
      final DateTime createdAt;            // Creation timestamp
      final DateTime updatedAt;            // Last modification timestamp
      final bool isSynced;                 // Cloud sync status
      final String? userId;                // Owner (null for local-only)
      
      // Trash fields
      final bool isDeleted;                // Soft delete flag
      final DateTime? deletedAt;             // When moved to trash (null if not deleted)

      const Note({
        required this.id,
        required this.title,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
        this.isSynced = false,
        this.userId,
        this.isDeleted = false,
        this.deletedAt,
      });

      /// Check if note should be auto-deleted (after 15 days in trash)
      bool get shouldBePermanentlyDeleted {
        if (!isDeleted || deletedAt == null) return false;
        final daysInTrash = DateTime.now().difference(deletedAt!).inDays;
        return daysInTrash >= 15;
      }

      /// Days remaining before permanent deletion
      int get daysRemainingInTrash {
        if (!isDeleted || deletedAt == null) return 0;
        final daysInTrash = DateTime.now().difference(deletedAt!).inDays;
        return (15 - daysInTrash).clamp(0, 15);
      }

      /// Create empty note with new ID
      factory Note.empty() {
        final now = DateTime.now();
        return Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          content: '',
          createdAt: now,
          updatedAt: now,
        );
      }

      /// Convert to trash state
      Note toTrash() {
        return copyWith(
          isDeleted: true,
          deletedAt: DateTime.now(),
        );
      }

      /// Restore from trash
      Note restore() {
        return copyWith(
          isDeleted: false,
          deletedAt: null,
        );
      }
      String get preview {
        if (content.isEmpty) return '';
        final lines = content.split('\n');
        final firstLine = lines.first.trim();
        if (firstLine.length > 100) {
          return '${firstLine.substring(0, 100)}...';
        }
        return firstLine;
      }

      /// Check if note is empty
      bool get isEmpty => title.isEmpty && content.isEmpty;

      /// Create copy with modifications
      Note copyWith({
        String? id,
        String? title,
        String? content,
        DateTime? createdAt,
        DateTime? updatedAt,
        bool? isSynced,
        String? userId,
      }) {
        return Note(
          id: id ?? this.id,
          title: title ?? this.title,
          content: content ?? this.content,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          isSynced: isSynced ?? this.isSynced,
          userId: userId ?? this.userId,
        );
      }

      @override
      List<Object?> get props => [
        id, title, content, createdAt, updatedAt, isSynced, userId,
      ];
    }
  </edit>
</task>

<task>
  <action>Create Isar Note model</action>
  <write file="lib/data/models/isar_note_model.dart">
    import 'package:isar/isar.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';

    part 'isar_note_model.g.dart';

    /// Isar database model for Note
    /// Maps to Note domain entity
    @collection
    class IsarNoteModel {
      /// Primary key (auto-increment)
      Id isarId = Isar.autoIncrement;

      /// UUID for cross-platform identification
      @Index(unique: true, replace: true)
      late String id;

      /// Note title
      late String title;

      /// Note content
      late String content;

      /// Creation timestamp (indexed for sorting)
      @Index()
      late DateTime createdAt;

      /// Last modification timestamp (indexed for sorting)
      @Index()
      late DateTime updatedAt;

      /// Cloud sync status
      late bool isSynced;

      /// Owner user ID (null for local-only notes)
      String? userId;

      /// Convert to domain entity
      Note toEntity() => Note(
        id: id,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: isSynced,
        userId: userId,
      );

      /// Create from domain entity
      static IsarNoteModel fromEntity(Note note) => IsarNoteModel()
        ..id = note.id
        ..title = note.title
        ..content = note.content
        ..createdAt = note.createdAt
        ..updatedAt = note.updatedAt
        ..isSynced = note.isSynced
        ..userId = note.userId;

      /// Create copy with modifications
      IsarNoteModel copyWith({
        String? title,
        String? content,
        DateTime? updatedAt,
        bool? isSynced,
        String? userId,
      }) {
        return IsarNoteModel()
          ..isarId = isarId
          ..id = id
          ..title = title ?? this.title
          ..content = content ?? this.content
          ..createdAt = createdAt
          ..updatedAt = updatedAt ?? this.updatedAt
          ..isSynced = isSynced ?? this.isSynced
          ..userId = userId ?? this.userId;
      }
    }
  </write>
</task>

<task>
  <action>Run code generation</action>
  <command>flutter pub run build_runner build --delete-conflicting-outputs</command>
  <verify>isar_note_model.g.dart is created</verify>
</task>
```

**Files Modified:**
- `lib/domain/entities/note.dart`
- `lib/data/models/isar_note_model.dart`
- `lib/data/models/isar_note_model.g.dart` (generated)

**Must Haves for Success:**
- [ ] Note entity with all fields
- [ ] Isar model with @collection
- [ ] toEntity/fromEntity methods
- [ ] Code generation succeeds

---

### Plan 04-02: Create Note Repository Interface

**Task:** Define contract for note operations

```xml
<task>
  <action>Create NoteRepository interface</action>
  <write file="lib/domain/repositories/note_repository.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';

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
    }
  </write>
</task>

<task>
  <action>Create NoteException types</action>
  <edit file="lib/core/errors/app_exception.dart">
    // Add after AuthException:

    class NoteException extends AppException {
      final NoteErrorCode code;

      const NoteException(this.code, super.message, {super.stackTrace})
          : super(code: code.name);
    }

    enum NoteErrorCode {
      notFound,
      saveFailed,
      deleteFailed,
      invalidData,
      databaseError,
    }
  </edit>
</task>
```

**Files Modified:**
- `lib/domain/repositories/note_repository.dart`
- `lib/core/errors/app_exception.dart`

**Must Haves for Success:**
- [ ] All CRUD methods defined
- [ ] Stream for reactive updates
- [ ] Search method
- [ ] NoteException types

---

## Wave 2: Repository Implementation (55 min)

### Plan 04-03: Implement Isar Note Repository

**Task:** Implement repository with Isar database

```xml
<task>
  <action>Create IsarNoteRepository</action>
  <write file="lib/data/repositories/isar_note_repository.dart">
    import 'package:isar/isar.dart';
    import 'package:voiceflow_notes/core/errors/app_exception.dart';
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/data/datasources/local_database.dart';
    import 'package:voiceflow_notes/data/models/isar_note_model.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';

    /// Isar implementation of NoteRepository
    class IsarNoteRepository implements NoteRepository {
      final LocalDatabase _database;

      IsarNoteRepository(this._database);

      Isar get _isar => _database.isar;

      @override
      Stream<List<Note>> getNotesStream() {
        return _isar.isarNoteModels
            .where()
            .sortByUpdatedAtDesc()
            .watch(fireImmediately: true)
            .map((models) => models.map((m) => m.toEntity()).toList());
      }

      @override
      Future<Result<List<Note>>> getAllNotes() async {
        try {
          final models = await _isar.isarNoteModels
              .where()
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
              .idEqualTo(id)
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
              .idEqualTo(note.id)
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
        try {
          final model = await _isar.isarNoteModels
              .where()
              .idEqualTo(id)
              .findFirst();

          if (model == null) {
            return Failure(NoteException(
              NoteErrorCode.notFound,
              'Note not found: $id',
            ));
          }

          await _isar.writeTxn(() async {
            await _isar.isarNoteModels.delete(model.isarId);
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
      Future<Result<List<Note>>> searchNotes(String query) async {
        try {
          // Search in title and content
          final titleMatches = await _isar.isarNoteModels
              .where()
              .titleWordsStartsWith(query)
              .findAll();

          final contentMatches = await _isar.isarNoteModels
              .where()
              .contentWordsStartsWith(query)
              .findAll();

          // Combine and remove duplicates
          final allMatches = {...titleMatches, ...contentMatches};
          final sorted = allMatches.toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return Success(sorted.map((m) => m.toEntity()).toList());
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
          final count = await _isar.isarNoteModels.count();
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
  </write>
</task>

<task>
  <action>Verify no compile errors</action>
  <command>flutter analyze</command>
</task>
```

**Files Modified:**
- `lib/data/repositories/isar_note_repository.dart`

**Must Haves for Success:**
- [ ] All repository methods implemented
- [ ] Error handling with NoteException
- [ ] Stream for reactive updates
- [ ] No analysis errors

---

### Plan 04-04: Create Note Use Cases

**Task:** Create use cases for each note operation

```xml
<task>
  <action>Create GetNotesUseCase</action>
  <write file="lib/domain/usecases/get_notes_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class GetNotesUseCase implements UseCase<List<Note>, NoParams> {
      final NoteRepository _repository;

      GetNotesUseCase(this._repository);

      @override
      Future<Result<List<Note>>> call(NoParams params) {
        return _repository.getAllNotes();
      }
    }
  </write>
</task>

<task>
  <action>Create GetNoteByIdUseCase</action>
  <write file="lib/domain/usecases/get_note_by_id_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class GetNoteByIdParams {
      final String id;
      const GetNoteByIdParams(this.id);
    }

    class GetNoteByIdUseCase implements UseCase<Note?, GetNoteByIdParams> {
      final NoteRepository _repository;

      GetNoteByIdUseCase(this._repository);

      @override
      Future<Result<Note?>> call(GetNoteByIdParams params) {
        return _repository.getNoteById(params.id);
      }
    }
  </write>
</task>

<task>
  <action>Create CreateNoteUseCase</action>
  <write file="lib/domain/usecases/create_note_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class CreateNoteParams {
      final String title;
      final String content;

      const CreateNoteParams({
        required this.title,
        required this.content,
      });
    }

    class CreateNoteUseCase implements UseCase<Note, CreateNoteParams> {
      final NoteRepository _repository;

      CreateNoteUseCase(this._repository);

      @override
      Future<Result<Note>> call(CreateNoteParams params) {
        return _repository.createNote(
          title: params.title,
          content: params.content,
        );
      }
    }
  </write>
</task>

<task>
  <action>Create UpdateNoteUseCase</action>
  <write file="lib/domain/usecases/update_note_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class UpdateNoteUseCase implements UseCase<void, Note> {
      final NoteRepository _repository;

      UpdateNoteUseCase(this._repository);

      @override
      Future<Result<void>> call(Note note) {
        return _repository.updateNote(note);
      }
    }
  </write>
</task>

<task>
  <action>Create DeleteNoteUseCase</action>
  <write file="lib/domain/usecases/delete_note_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class DeleteNoteParams {
      final String id;
      const DeleteNoteParams(this.id);
    }

    class DeleteNoteUseCase implements UseCase<void, DeleteNoteParams> {
      final NoteRepository _repository;

      DeleteNoteUseCase(this._repository);

      @override
      Future<Result<void>> call(DeleteNoteParams params) {
        return _repository.deleteNote(params.id);
      }
    }
  </write>
</task>

<task>
  <action>Create SearchNotesUseCase</action>
  <write file="lib/domain/usecases/search_notes_usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';

    class SearchNotesParams {
      final String query;
      const SearchNotesParams(this.query);
    }

    class SearchNotesUseCase implements UseCase<List<Note>, SearchNotesParams> {
      final NoteRepository _repository;

      SearchNotesUseCase(this._repository);

      @override
      Future<Result<List<Note>>> call(SearchNotesParams params) {
        return _repository.searchNotes(params.query);
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/domain/usecases/get_notes_usecase.dart`
- `lib/domain/usecases/get_note_by_id_usecase.dart`
- `lib/domain/usecases/create_note_usecase.dart`
- `lib/domain/usecases/update_note_usecase.dart`
- `lib/domain/usecases/delete_note_usecase.dart`
- `lib/domain/usecases/search_notes_usecase.dart`

**Must Haves for Success:**
- [ ] All 6 use cases created
- [ ] Each implements UseCase interface
- [ ] Proper params classes
- [ ] No analysis errors

---

## Wave 3: Providers & UI Integration (45 min)

### Plan 04-05: Configure Note Providers

**Task:** Setup Riverpod providers for notes

```xml
<task>
  <action>Create notes providers</action>
  <write file="lib/presentation/providers/notes_provider.dart">
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/data/repositories/isar_note_repository.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
    import 'package:voiceflow_notes/domain/usecases/create_note_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/delete_note_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/get_note_by_id_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/get_notes_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/search_notes_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/update_note_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/usecase.dart';
    import 'local_database_provider.dart';

    // Repository
    final noteRepositoryProvider = Provider<NoteRepository>((ref) {
      final db = ref.watch(localDatabaseProvider);
      return IsarNoteRepository(db);
    });

    // Use cases
    final getNotesUseCaseProvider = Provider<GetNotesUseCase>((ref) {
      return GetNotesUseCase(ref.watch(noteRepositoryProvider));
    });

    final getNoteByIdUseCaseProvider = Provider<GetNoteByIdUseCase>((ref) {
      return GetNoteByIdUseCase(ref.watch(noteRepositoryProvider));
    });

    final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
      return CreateNoteUseCase(ref.watch(noteRepositoryProvider));
    });

    final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
      return UpdateNoteUseCase(ref.watch(noteRepositoryProvider));
    });

    final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
      return DeleteNoteUseCase(ref.watch(noteRepositoryProvider));
    });

    final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
      return SearchNotesUseCase(ref.watch(noteRepositoryProvider));
    });

    // Stream provider for reactive updates
    final notesStreamProvider = StreamProvider<List<Note>>((ref) {
      final repository = ref.watch(noteRepositoryProvider);
      return repository.getNotesStream();
    });

    // Current notes (async)
    final notesProvider = FutureProvider<List<Note>>((ref) async {
      final useCase = ref.watch(getNotesUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.value ?? [];
    });

    // Selected note
    final selectedNoteProvider = StateProvider<Note?>((ref) => null);

    // Search query
    final searchQueryProvider = StateProvider<String>((ref) => '');

    // Search results
    final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
      final query = ref.watch(searchQueryProvider);
      if (query.isEmpty) return [];
      
      final useCase = ref.watch(searchNotesUseCaseProvider);
      final result = await useCase(SearchNotesParams(query));
      return result.value ?? [];
    });

    // Notes count
    final notesCountProvider = FutureProvider<int>((ref) async {
      final repository = ref.watch(noteRepositoryProvider);
      final result = await repository.getNotesCount();
      return result.value ?? 0;
    });

    // Loading state for operations
    final noteOperationLoadingProvider = StateProvider<bool>((ref) => false);

    // Error state
    final noteErrorProvider = StateProvider<String?>((ref) => null);
  </write>
</task>

<task>
  <action>Create local database provider</action>
  <write file="lib/presentation/providers/local_database_provider.dart">
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/data/datasources/local_database.dart';

    final localDatabaseProvider = Provider<LocalDatabase>((ref) {
      return LocalDatabase();
    });
  </write>
</task>

<task>
  <action>Update DI providers</action>
  <edit file="lib/core/di/providers.dart">
    // Re-export all providers for clean imports
    export 'package:voiceflow_notes/presentation/providers/auth_provider.dart';
    export 'package:voiceflow_notes/presentation/providers/loading_provider.dart';
    export 'package:voiceflow_notes/presentation/providers/local_database_provider.dart';
    export 'package:voiceflow_notes/presentation/providers/notes_provider.dart';
  </edit>
</task>
```

**Files Modified:**
- `lib/presentation/providers/notes_provider.dart`
- `lib/presentation/providers/local_database_provider.dart`
- `lib/core/di/providers.dart`

**Must Haves for Success:**
- [ ] All providers configured
- [ ] Stream provider for reactive updates
- [ ] Search providers
- [ ] Loading/error states

---

### Plan 04-06: Integrate Note List in Home Page

**Task:** Show real notes in HomePage with list UI

```xml
<task>
  <action>Update HomePage with note list</action>
  <write file="lib/presentation/pages/home_page.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:voiceflow_notes/core/theme/app_theme.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/presentation/providers/notes_provider.dart';
    import 'package:voiceflow_notes/presentation/widgets/app_shell.dart';
    import 'package:voiceflow_notes/presentation/widgets/skeleton.dart';

    class HomePage extends ConsumerWidget {
      const HomePage({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final notesAsync = ref.watch(notesStreamProvider);
        final searchQuery = ref.watch(searchQueryProvider);

        return AppShell(
          currentPath: '/',
          body: Column(
            children: [
              // Search bar
              if (searchQuery.isNotEmpty || notesAsync.value?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                ),

              // Note list
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return const _EmptyState();
                    }
                    return _NoteList(notes: notes);
                  },
                  loading: () => const NoteListSkeleton(),
                  error: (_, __) => const _ErrorState(),
                ),
              ),
            ],
          ),
        );
      }
    }

    class _NoteList extends StatelessWidget {
      final List<Note> notes;

      const _NoteList({required this.notes});

      @override
      Widget build(BuildContext context) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _NoteCard(note: note);
          },
        );
      }
    }

    class _NoteCard extends StatelessWidget {
      final Note note;

      const _NoteCard({required this.note});

      @override
      Widget build(BuildContext context) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go('/note/${note.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    style: AppTheme.noteTitleStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Preview
                  if (note.preview.isNotEmpty)
                    Text(
                      note.preview,
                      style: AppTheme.notePreviewStyle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      String _formatDate(DateTime date) {
        final now = DateTime.now();
        final diff = now.difference(date);
        
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inHours < 1) return '${diff.inMinutes}m ago';
        if (diff.inDays < 1) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        return '${date.day}/${date.month}/${date.year}';
      }
    }

    class _EmptyState extends StatelessWidget {
      const _EmptyState();

      @override
      Widget build(BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notes_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No notes yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the microphone button\nto create your first voice note',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }
    }

    class _ErrorState extends StatelessWidget {
      const _ErrorState();

      @override
      Widget build(BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pull to refresh or restart the app',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/pages/home_page.dart`

**Must Haves for Success:**
- [ ] Note list displays real notes
- [ ] Note cards with title, preview, timestamp
- [ ] Tap to open note editor
- [ ] Empty state
- [ ] Loading skeletons
- [ ] Error state

---

## Wave 4: Note Editor (50 min)

### Plan 04-07: Implement Note Editor with Auto-Save

**Task:** Complete NoteEditorPage with save functionality

```xml
<task>
  <action>Update NoteEditorPage with full functionality</action>
  <write file="lib/presentation/pages/note_editor_page.dart">
    import 'dart:async';
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:voiceflow_notes/core/theme/app_theme.dart';
    import 'package:voiceflow_notes/core/utils/error_handler.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/domain/usecases/create_note_usecase.dart';
    import 'package:voiceflow_notes/domain/usecases/update_note_usecase.dart';
    import 'package:voiceflow_notes/presentation/providers/notes_provider.dart';

    class NoteEditorPage extends ConsumerStatefulWidget {
      final String? noteId;

      const NoteEditorPage({super.key, this.noteId});

      @override
      ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
    }

    class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
      final _titleController = TextEditingController();
      final _contentController = TextEditingController();
      Timer? _debounceTimer;
      bool _isNewNote = true;
      Note? _currentNote;

      @override
      void initState() {
        super.initState();
        _loadNote();
      }

      @override
      void dispose() {
        _titleController.dispose();
        _contentController.dispose();
        _debounceTimer?.cancel();
        super.dispose();
      }

      Future<void> _loadNote() async {
        if (widget.noteId != null) {
          _isNewNote = false;
          final useCase = ref.read(getNoteByIdUseCaseProvider);
          final result = await useCase(GetNoteByIdParams(widget.noteId!));
          
          if (result.isSuccess && result.value != null) {
            setState(() {
              _currentNote = result.value;
              _titleController.text = _currentNote!.title;
              _contentController.text = _currentNote!.content;
            });
          }
        }
      }

      void _onTextChanged() {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          _autoSave();
        });
      }

      Future<void> _autoSave() async {
        final title = _titleController.text.trim();
        final content = _contentController.text.trim();

        if (title.isEmpty && content.isEmpty) return;

        if (_isNewNote) {
          // Create new note
          final useCase = ref.read(createNoteUseCaseProvider);
          final result = await useCase(CreateNoteParams(
            title: title,
            content: content,
          ));

          if (result.isSuccess) {
            setState(() {
              _isNewNote = false;
              _currentNote = result.value;
            });
          } else if (mounted) {
            ErrorHandler.showError(context, result.error!);
          }
        } else if (_currentNote != null) {
          // Update existing note
          final updatedNote = _currentNote!.copyWith(
            title: title,
            content: content,
          );

          final useCase = ref.read(updateNoteUseCaseProvider);
          final result = await useCase(updatedNote);

          if (result.isFailure && mounted) {
            ErrorHandler.showError(context, result.error!);
          }
        }
      }

      Future<void> _onVoiceButtonPressed() async {
        // TODO: Implement voice recording (Phase 5)
        // For now, show placeholder
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Voice Input'),
            content: const Text('Voice recording coming in Phase 5!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
            actions: [
              // Save button (manual save)
              TextButton(
                onPressed: _autoSave,
                child: const Text('Save'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Title field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  style: AppTheme.noteTitleStyle(context),
                  onChanged: (_) => _onTextChanged(),
                ),
              ),
              
              const Divider(),
              
              // Content field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Start typing or tap the mic to record...',
                      border: InputBorder.none,
                    ),
                    style: AppTheme.noteContentStyle(context),
                    maxLines: null,
                    expands: true,
                    onChanged: (_) => _onTextChanged(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: _onVoiceButtonPressed,
            child: const Icon(Icons.mic),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/pages/note_editor_page.dart`

**Must Haves for Success:**
- [ ] Title and content fields
- [ ] Auto-save with 500ms debounce
- [ ] Create new note on first save
- [ ] Update existing note
- [ ] Voice button placeholder
- [ ] Manual save button

---

### Plan 04-08: Add Note Creation Flow

**Task:** Wire up FAB on Home to create notes

```xml
<task>
  <action>Update AppShell FAB behavior</action>
  <edit file="lib/presentation/widgets/app_shell.dart">
    // In AppShell build method, update FAB onPressed:
    
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        if (currentPath == '/') {
          // On Home: create new note
          context.go('/note/new');
        } else {
          // On other pages: navigate home first
          context.go('/note/new');
        }
      },
      icon: const Icon(Icons.mic),
      label: const Text('Voice Note'),
    ),
  </edit>
</task>

<task>
  <action>Test creation flow</action>
  <manual>
    1. Tap FAB on Home
    2. Verify: Opens NoteEditorPage with empty fields
    3. Type title and content
    4. Wait 500ms
    5. Verify: Note auto-saves
    6. Go back to Home
    7. Verify: New note appears in list
  </manual>
</task>
```

**Files Modified:**
- `lib/presentation/widgets/app_shell.dart`

**Must Haves for Success:**
- [ ] FAB creates new note
- [ ] Opens editor
- [ ] Auto-saves after typing
- [ ] Appears in list

---

## Wave 5: Delete & Testing (30 min)

### Plan 04-09: Implement Delete with Confirmation

**Task:** Add swipe-to-delete with confirmation dialog

```xml
<task>
  <action>Add delete functionality to note cards</action>
  <edit file="lib/presentation/pages/home_page.dart">
    // Update _NoteCard to include delete:
    
    class _NoteCard extends ConsumerWidget {
      final Note note;

      const _NoteCard({required this.note});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _showDeleteConfirmation(context),
          onDismissed: (_) => _deleteNote(context, ref),
          child: Card(
            // ... existing card content ...
          ),
        );
      }

      Future<bool> _showDeleteConfirmation(BuildContext context) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ) ?? false;
      }

      Future<void> _deleteNote(BuildContext context, WidgetRef ref) async {
        final useCase = ref.read(deleteNoteUseCaseProvider);
        final result = await useCase(DeleteNoteParams(note.id));

        if (result.isFailure && context.mounted) {
          ErrorHandler.showError(context, result.error!);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  </edit>
</task>
```

**Files Modified:**
- `lib/presentation/pages/home_page.dart`

**Must Haves for Success:**
- [ ] Swipe to delete
- [ ] Confirmation dialog
- [ ] Snackbar confirmation
- [ ] Error handling

---

### Plan 04-10: Add View Deleted Note Detail

**Task:** Allow users to view full content of deleted notes before restoring

```xml
<task>
  <action>Create TrashedNoteDetailPage</action>
  <write file="lib/presentation/pages/trashed_note_detail_page.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:voiceflow_notes/core/theme/app_theme.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';
    import 'package:voiceflow_notes/presentation/providers/notes_provider.dart';

    class TrashedNoteDetailPage extends ConsumerWidget {
      final String noteId;

      const TrashedNoteDetailPage({super.key, required this.noteId});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final noteAsync = ref.watch(trashedNoteByIdProvider(noteId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Deleted Note'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/trash'),
            ),
          ),
          body: noteAsync.when(
            data: (note) => _NoteDetailContent(note: note!),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load note')),
          ),
          bottomNavigationBar: noteAsync.when(
            data: (note) => _ActionBar(note: note!),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        );
      }
    }

    class _NoteDetailContent extends StatelessWidget {
      final Note note;

      const _NoteDetailContent({required this.note});

      @override
      Widget build(BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (read-only)
              Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: AppTheme.noteTitleStyle(context),
              ),
              const SizedBox(height: 16),
              
              // Metadata
              Row(
                children: [
                  Icon(Icons.delete_outline, 
                    size: 16, 
                    color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    'Deleted ${_formatDate(note.deletedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.hourglass_empty, 
                    size: 16, 
                    color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 4),
                  Text(
                    '${note.daysRemainingInTrash} days left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 32),
              
              // Content (read-only)
              Text(
                note.content.isEmpty ? 'No content' : note.content,
                style: AppTheme.noteContentStyle(context),
              ),
            ],
          ),
        );
      }

      String _formatDate(DateTime date) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }

    class _ActionBar extends ConsumerWidget {
      final Note note;

      const _ActionBar({required this.note});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Restore button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _restoreNote(context, ref),
                    icon: const Icon(Icons.restore_from_trash),
                    label: const Text('Restore'),
                  ),
                ),
                const SizedBox(width: 12),
                // Permanent delete button
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () => _permanentlyDelete(context, ref),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Future<void> _restoreNote(BuildContext context, WidgetRef ref) async {
        final useCase = ref.read(restoreFromTrashUseCaseProvider);
        final result = await useCase(RestoreFromTrashParams(note.id));
        
        if (result.isSuccess && context.mounted) {
          context.go('/trash');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note restored')),
          );
        }
      }

      Future<void> _permanentlyDelete(BuildContext context, WidgetRef ref) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permanently Delete?'),
            content: const Text('This note will be permanently deleted and cannot be recovered.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          final useCase = ref.read(permanentlyDeleteNoteUseCaseProvider);
          final result = await useCase(PermanentlyDeleteNoteParams(note.id));
          
          if (result.isSuccess && context.mounted) {
            context.go('/trash');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note permanently deleted')),
            );
          }
        }
      }
    }
  </write>
</task>

<task>
  <action>Add route for trashed note detail</action>
  <edit file="lib/core/navigation/router.dart">
    // Add route:
    GoRoute(
      path: '/trash/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return TrashedNoteDetailPage(noteId: noteId);
      },
    ),
  </edit>
</task>

<task>
  <action>Update TrashPage to support tap navigation</action>
  <edit file="lib/presentation/pages/trash_page.dart">
    // In _TrashedNoteCard, wrap with InkWell:
    InkWell(
      onTap: () => context.go('/trash/${note.id}'),
      child: Card(
        // ... existing card content ...
      ),
    )
  </edit>
</task>

<task>
  <action>Add provider for single trashed note</action>
  <edit file="lib/presentation/providers/notes_provider.dart">
    // Add provider:
    final trashedNoteByIdProvider = FutureProvider.family<Note?, String>((ref, noteId) async {
      final useCase = ref.watch(getTrashedNoteByIdUseCaseProvider);
      final result = await useCase(GetTrashedNoteByIdParams(noteId));
      return result.value;
    });
  </edit>
</task>
```

**Files Modified:**
- `lib/presentation/pages/trashed_note_detail_page.dart` (new)
- `lib/core/navigation/router.dart`
- `lib/presentation/pages/trash_page.dart`
- `lib/presentation/providers/notes_provider.dart`
- `lib/domain/usecases/get_trashed_note_by_id_usecase.dart` (new)

**Must Haves for Success:**
- [ ] Tapping a trashed note opens detail view
- [ ] Shows full title and content
- [ ] Shows deletion date and days remaining
- [ ] Restore button returns note to active
- [ ] Delete button permanently deletes with confirmation
- [ ] Read-only display (no editing)

---

### Plan 04-11: Test CRUD Operations

**Task:** Verify all note operations work

```xml
<task>
  <action>Build and verify compilation</action>
  <commands>
    flutter analyze
    flutter build web
  </commands>
  <verify>No errors</verify>
</task>

<task>
  <action>Test Create</action>
  <manual>
    1. Launch app
    2. Tap FAB (voice note button)
    3. Enter title: "Test Note"
    4. Enter content: "This is test content"
    5. Wait 500ms
    6. Go back
    7. Verify: Note appears in list with correct title/preview
  </manual>
</task>

<task>
  <action>Test Read</action>
  <manual>
    1. Tap on created note
    2. Verify: Opens with correct title and content
    3. Verify: Cursor at end of content
  </manual>
</task>

<task>
  <action>Test Update</action>
  <manual>
    1. Open existing note
    2. Edit title
    3. Edit content
    4. Wait 500ms
    5. Go back
    6. Verify: Changes saved and visible in list
  </manual>
</task>

<task>
  <action>Test Delete</action>
  <manual>
    1. Find note in list
    2. Swipe left
    3. Verify: Confirmation dialog appears
    4. Tap "Delete"
    5. Verify: Note removed from list
    6. Verify: Snackbar shows "Note deleted"
  </manual>
</task>

<task>
  <action>Test Persistence</action>
  <manual>
    1. Create note
    2. Force close app
    3. Reopen app
    4. Verify: Note still exists
  </manual>
</task>

<task>
  <action>Test Offline</action>
  <manual>
    1. Turn off internet
    2. Create note
    3. Edit note
    4. Delete note
    5. Verify: All operations work offline
  </manual>
</task>
```

**Files Modified:** None (testing only)

**Must Haves for Success:**
- [ ] All CRUD operations work
- [ ] Auto-save works
- [ ] Persistence across restarts
- [ ] Works offline
- [ ] Web build succeeds

---

## Verification Criteria

### Phase Success Criteria (from ROADMAP)

- [ ] Note domain model defined with proper fields (id, title, content, timestamps)
- [ ] Repository pattern implemented with clean separation from UI
- [ ] Local data source (Isar) saves notes immediately on any operation
- [ ] Offline mode works fully — all CRUD operations function without network
- [ ] Data persists after app restart and device reboot
- [ ] Repository provides streams/reactive updates for UI consumption

### Technical Verification

- [ ] Isar Note model created with @collection
- [ ] NoteRepository interface defined
- [ ] IsarNoteRepository implements all methods
- [ ] All use cases created (6 total)
- [ ] Riverpod providers configured
- [ ] HomePage shows real notes from database
- [ ] NoteEditorPage auto-saves with debounce
- [ ] Swipe-to-delete with confirmation
- [ ] Works offline
- [ ] Data persists across restarts

---

## Files Created/Modified

### New Files:
- `lib/domain/entities/note.dart` — Note entity
- `lib/data/models/isar_note_model.dart` — Isar model
- `lib/data/models/isar_note_model.g.dart` — Generated
- `lib/domain/repositories/note_repository.dart` — Interface
- `lib/data/repositories/isar_note_repository.dart` — Implementation
- `lib/domain/usecases/get_notes_usecase.dart` — Read all
- `lib/domain/usecases/get_note_by_id_usecase.dart` — Read one
- `lib/domain/usecases/create_note_usecase.dart` — Create
- `lib/domain/usecases/update_note_usecase.dart` — Update
- `lib/domain/usecases/delete_note_usecase.dart` — Delete
- `lib/domain/usecases/search_notes_usecase.dart` — Search
- `lib/presentation/providers/notes_provider.dart` — Providers
- `lib/presentation/providers/local_database_provider.dart` — DB provider

### Modified Files:
- `lib/core/errors/app_exception.dart` — Add NoteException
- `lib/core/di/providers.dart` — Export note providers
- `lib/presentation/pages/home_page.dart` — Show real notes
- `lib/presentation/pages/note_editor_page.dart` — Full CRUD
- `lib/presentation/widgets/app_shell.dart` — FAB behavior

---

## Dependencies

No new dependencies — uses existing:
- `isar: ^3.1.0`
- `isar_flutter_libs: ^3.1.0`
- `flutter_riverpod` (already in Phase 1)

---

## Next Phase

After Phase 4 completes:

**Phase 5: Voice Input**
- Speech-to-text integration
- Recording UI
- Transcription display

---

*Plan created: 2025-02-27*
*Ready for execution*
