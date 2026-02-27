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
  - Complete UI integration (Home, Editor, Trash, Settings)

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
    - lib/domain/usecases/permanently_delete_note_usecase.dart - Hard delete
    - lib/presentation/providers/notes_provider.dart - Riverpod providers
    - lib/presentation/providers/local_database_provider.dart - Database provider
    - lib/presentation/pages/trash_page.dart - Trash management UI
    - lib/presentation/pages/home_page.dart - Note list with delete
    - lib/presentation/pages/note_editor_page.dart - Editor with auto-save
    - lib/presentation/pages/settings_page.dart - Settings with trash link
  modified:
    - lib/core/errors/app_exception.dart - Added NoteException
    - lib/core/navigation/router.dart - Added trash route
    - lib/core/di/providers.dart - Exported note providers

duration: 45min
completed: 2025-02-27
---

# Phase 04 Plan 04: Local Storage & Note CRUD Summary

**Complete note CRUD operations with Isar database, soft delete trash bin, and 15-day auto-deletion**

## Performance

- **Duration:** 45 minutes
- **Started:** 2025-02-27T23:13:00Z
- **Completed:** 2025-02-27T23:50:00Z
- **Tasks:** 10/10 completed
- **Files Created:** 20 new files, 4 modified

## Accomplishments

### Data Layer
- **Note Entity** — Complete domain model with trash support (`isDeleted`, `deletedAt`, `daysRemainingInTrash`)
- **Isar Model** — Database entity with @collection annotation and indices
- **Repository Interface** — Abstract contract for all note operations
- **Isar Implementation** — Full CRUD + trash operations with error handling

### Use Cases (11 total)
1. **CreateNote** — Create new note with UUID
2. **UpdateNote** — Save changes with timestamp
3. **DeleteNote** — Soft delete (move to trash)
4. **GetNotes** — Get all active notes
5. **GetNoteById** — Get single note
6. **SearchNotes** — Full-text search
7. **MoveToTrash** — Soft delete with timestamp
8. **RestoreFromTrash** — Restore note to active
9. **GetTrashedNotes** — List trash contents
10. **EmptyTrash** — Delete notes >15 days old
11. **PermanentlyDeleteNote** — Hard delete bypassing trash

### Trash Bin Features
- **Soft Delete** — Notes moved to trash instead of deleted
- **15-Day Auto-Delete** — Notes permanently deleted after 15 days in trash
- **Restore** — Notes can be restored from trash
- **Empty Trash** — Manual cleanup of old items
- **Days Remaining** — UI shows countdown until deletion
- **Trash Count Badge** — Settings shows number of trashed notes

### Providers
- **notesStreamProvider** — Stream of all notes (reactive)
- **trashedNotesStreamProvider** — Stream of trash contents
- **searchResultsProvider** — Search query results
- **notesCountProvider** — Total notes count
- **trashedNotesCountProvider** — Trash count for badge
- **All use case providers** — For dependency injection

### UI Integration
- **HomePage** — Real note list with swipe-to-delete, undo snackbar
- **NoteEditorPage** — Auto-save with 500ms debounce, create/update
- **TrashPage** — Full trash management with restore and permanent delete
- **SettingsPage** — Trash link with count badge, empty trash option

## Technical Decisions

1. **Soft Delete Pattern** — Notes are never immediately deleted, always moved to trash first
2. **15-Day Auto-Delete** — Configurable retention period before permanent deletion
3. **Reactive Streams** — UI auto-updates when data changes via Riverpod streams
4. **Repository Pattern** — Clean separation between UI and database
5. **Use Case Pattern** — Each operation has dedicated use case for testability
6. **Auto-Save** — 500ms debounce for seamless editing experience

## Files Created/Modified

### Domain
- `lib/domain/entities/note.dart` — Note entity with trash fields
- `lib/domain/repositories/note_repository.dart` — Repository interface

### Data
- `lib/data/models/isar_note_model.dart` — Isar model
- `lib/data/repositories/isar_note_repository.dart` — Full CRUD implementation

### Use Cases
- All 11 use cases in `lib/domain/usecases/`

### UI Pages
- `lib/presentation/pages/home_page.dart` — Note list with real data
- `lib/presentation/pages/note_editor_page.dart` — Editor with auto-save
- `lib/presentation/pages/trash_page.dart` — Trash management
- `lib/presentation/pages/settings_page.dart` — Settings with trash link

### Providers
- `lib/presentation/providers/notes_provider.dart` — Note providers
- `lib/presentation/providers/local_database_provider.dart` — Database provider

### Navigation
- `lib/core/navigation/router.dart` — Added trash route

### Errors
- `lib/core/errors/app_exception.dart` — Added NoteException

## Features Delivered

### Core CRUD
✅ Create notes with auto-generated ID
✅ Read notes with reactive streams
✅ Update notes with auto-save (500ms debounce)
✅ Delete notes (soft delete to trash)

### Trash Bin
✅ Soft delete — notes moved to trash
✅ Restore — recover notes from trash
✅ Days remaining — countdown shown in UI
✅ Permanent delete — bypass trash for hard delete
✅ Empty trash — bulk delete old notes
✅ Auto-delete — 15 days countdown, synced

### Search
✅ Full-text search in title and content
✅ Real-time results

### UI/UX
✅ Swipe to delete with confirmation
✅ Undo snackbar after delete
✅ Auto-save while typing
✅ Empty states for no notes/trash
✅ Loading skeletons
✅ Error handling

## Success Criteria (All Met)

- [x] Note domain model defined with proper fields (id, title, content, timestamps, isDeleted, deletedAt)
- [x] Repository pattern implemented with clean separation from UI
- [x] Local data source (Isar) saves notes immediately on any operation
- [x] Offline mode works fully — all CRUD operations function without network
- [x] Data persists after app restart and device reboot
- [x] Repository provides streams/reactive updates for UI consumption
- [x] Trash bin with soft delete
- [x] Auto-delete after 15 days
- [x] Full UI integration (Home, Editor, Trash, Settings)

## Phase 5 Ready

**Next:** Voice Input
- Speech-to-text integration
- Recording UI
- Transcription display
- Insert at cursor position

**Status:** ✅ Phase 4 complete, ready for Phase 5

---
*Phase: 04-local-storage*
*Completed: 2025-02-27*
