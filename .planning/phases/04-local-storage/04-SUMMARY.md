---
phase: 04-local-storage
plan: 04
subsystem: storage

tags: [isar, repository, crud, trash, soft-delete]

requires:
  - phase: 01-project-setup
    provides: Flutter foundation, Isar database setup
  - phase: 03-navigation-ui
    provides: UI pages ready for data integration

provides:
  - Complete note CRUD operations (Create, Read, Update, Delete)
  - Soft delete with trash bin functionality
  - Auto-delete after 15 days in trash
  - Reactive streams for real-time UI updates
  - Full-text search for notes
  - Repository pattern with clean architecture

affects:
  - phase-05-voice-input
  - phase-11-firebase-sync

tech-stack:
  added: []
  patterns:
    - "Repository Pattern with Isar database"
    - "Use Case pattern for business logic"
    - "Reactive streams with Riverpod"
    - "Soft delete (trash bin) pattern"
    - "Auto-cleanup of old trash items"

key-files:
  created:
    - lib/domain/entities/note.dart - Note entity with trash support
    - lib/data/models/isar_note_model.dart - Isar database model
    - lib/domain/repositories/note_repository.dart - Repository interface
    - lib/data/repositories/isar_note_repository.dart - Isar implementation
    - lib/domain/usecases/create_note_usecase.dart - Create note
    - lib/domain/usecases/update_note_usecase.dart - Update note
    - lib/domain/usecases/delete_note_usecase.dart - Delete note
    - lib/domain/usecases/get_notes_usecase.dart - Get all notes
    - lib/domain/usecases/get_note_by_id_usecase.dart - Get single note
    - lib/domain/usecases/search_notes_usecase.dart - Search notes
    - lib/domain/usecases/move_to_trash_usecase.dart - Soft delete
    - lib/domain/usecases/restore_from_trash_usecase.dart - Restore from trash
    - lib/domain/usecases/get_trashed_notes_usecase.dart - Get trash contents
    - lib/domain/usecases/empty_trash_usecase.dart - Permanent delete old items
    - lib/presentation/providers/notes_provider.dart - Riverpod providers
    - lib/presentation/providers/local_database_provider.dart - Database provider
  modified:
    - lib/core/errors/app_exception.dart - Added NoteException

duration: ongoing
completed: 2025-02-27
---

# Phase 04 Plan 04: Local Storage & Note CRUD Summary

**Complete note CRUD operations with Isar database, soft delete trash bin, and 15-day auto-deletion**

## Performance

- **Duration:** Ongoing (subagent execution)
- **Started:** 2025-02-27T23:13:00Z
- **Tasks:** 5 of 10 completed
- **Files Created:** 16 new files, 1 modified

## Accomplishments

### Data Layer
- **Note Entity** — Complete domain model with trash support (`isDeleted`, `deletedAt`)
- **Isar Model** — Database entity with @collection annotation and indices
- **Repository Interface** — Abstract contract for all note operations
- **Isar Implementation** — Full CRUD + trash operations with error handling

### Use Cases (10 total)
1. **CreateNote** — Create new note with UUID
2. **UpdateNote** — Save changes with timestamp
3. **DeleteNote** — Soft delete (move to trash)
4. **GetNotes** — Get all active notes
5. **GetNoteById** — Get single note
6. **SearchNotes** — Full-text search
7. **MoveToTrash** — Soft delete with timestamp
8. **RestoreFromTrash** — Restore note to active
9. **GetTrashedNotes** — List trash contents
10. **EmptyTrash** — Permanently delete notes >15 days old

### Trash Bin Features
- **Soft Delete** — Notes moved to trash instead of deleted
- **15-Day Auto-Delete** — Notes permanently deleted after 15 days in trash
- **Restore** — Notes can be restored from trash
- **Empty Trash** — Manual cleanup of old items
- **Days Remaining** — UI can show countdown until deletion

### Providers
- **notesProvider** — Stream of all notes (reactive)
- **trashedNotesProvider** — Stream of trash contents
- **searchResultsProvider** — Search query results
- **notesCountProvider** — Total notes count
- **trashedNotesCountProvider** — Trash count for badge
- **All use case providers** — For dependency injection

## Technical Decisions

1. **Soft Delete Pattern** — Notes are never immediately deleted, always moved to trash first
2. **15-Day Auto-Delete** — Configurable retention period before permanent deletion
3. **Reactive Streams** — UI auto-updates when data changes via Riverpod streams
4. **Repository Pattern** — Clean separation between UI and database
5. **Use Case Pattern** — Each operation has dedicated use case for testability

## Files Created/Modified

### Domain
- `lib/domain/entities/note.dart` — Note entity with trash fields
- `lib/domain/repositories/note_repository.dart` — Repository interface

### Data
- `lib/data/models/isar_note_model.dart` — Isar model
- `lib/data/repositories/isar_note_repository.dart` — Full CRUD implementation

### Use Cases
- All 10 use cases in `lib/domain/usecases/`

### Providers
- `lib/presentation/providers/notes_provider.dart` — Note providers
- `lib/presentation/providers/local_database_provider.dart` — Database provider

### Errors
- `lib/core/errors/app_exception.dart` — Added NoteException

## Next Steps

**Remaining Plans:**
- Plan 04-06: Integrate Note List in Home Page
- Plan 04-07: Implement Note Editor with Auto-Save
- Plan 04-08: Add Note Creation Flow
- Plan 04-09: Implement Delete with Confirmation (UI)
- Plan 04-10: Test CRUD Operations

**Phase 5 Ready:**
Once Phase 4 complete, ready for Voice Input integration

---
*Phase: 04-local-storage*
*In Progress: 2025-02-27*
