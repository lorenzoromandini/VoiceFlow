# Phase 4 Research: Local Storage & Note CRUD

## Research Date
2025-02-27

## Phase Goal
Notes persist locally with proper data models, repositories, and local-first persistence patterns.

---

## Key Research Findings

### 1. Isar Database Overview

**What Isar Provides:**
- ✅ **Type-safe** — Compile-time type checking
- ✅ **Fast** — Written in C, native performance
- ✅ **Full-text search** — Built-in FTS for note searching
- ✅ **Reactive** — Stream-based queries
- ✅ **Web support** — Works via IndexedDB on web
- ✅ **No SQL** — Clean Dart API

**Key Concepts:**
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;  // Primary key
  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

---

### 2. Repository Pattern

**Architecture:**
```
UI Layer (Widgets)
    ↓
Riverpod Providers
    ↓
Use Cases (business logic)
    ↓
Repository Interface (abstract)
    ↓
Repository Implementation
    ↓
Data Source (Isar)
```

**Benefits:**
- **Testable** — Mock repository for testing
- **Swappable** — Can swap Isar for another database later
- **Clean** — UI doesn't know about database

---

### 3. Reactive Data with Streams

**Pattern:**
```dart
// Repository provides stream
Stream<List<Note>> getNotesStream() {
  return isar.notes.where().sortByUpdatedAtDesc().watch(fireImmediately: true);
}

// UI watches with Riverpod
final notesProvider = StreamProvider<List<Note>>((ref) {
  return repository.getNotesStream();
});

// Widget rebuilds automatically when data changes
Consumer(builder: (context, ref, child) {
  final notes = ref.watch(notesProvider);
  return notes.when(
    data: (list) => NoteList(notes: list),
    loading: () => Skeleton(),
    error: (_, __) => ErrorWidget(),
  );
});
```

**Advantages:**
- Auto-update UI when notes change
- No manual refresh needed
- Real-time sync ready for Phase 11

---

### 4. CRUD Operations

**Create:**
```dart
Future<Note> createNote(String title, String content) async {
  final note = Note()
    ..title = title
    ..content = content
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();
  
  await isar.writeTxn(() async {
    await isar.notes.put(note);
  });
  
  return note;
}
```

**Read:**
```dart
// Get all notes sorted
Future<List<Note>> getAllNotes() async {
  return await isar.notes
    .where()
    .sortByUpdatedAtDesc()
    .findAll();
}

// Get single note
Future<Note?> getNoteById(int id) async {
  return await isar.notes.get(id);
}
```

**Update:**
```dart
Future<void> updateNote(Note note) async {
  note.updatedAt = DateTime.now();
  await isar.writeTxn(() async {
    await isar.notes.put(note);  // put = update if exists
  });
}
```

**Delete:**
```dart
Future<void> deleteNote(int id) async {
  await isar.writeTxn(() async {
    await isar.notes.delete(id);
  });
}
```

---

### 5. Note Data Model

**Fields Needed:**
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;
  
  late String title;           // Note title
  late String content;         // Note body (transcribed text)
  
  @Index()  // For sorting
  late DateTime createdAt;      // When created
  
  @Index()  // For sorting
  late DateTime updatedAt;      // When last modified
  
  bool isSynced = false;       // Sync status (for Phase 11)
  
  String? userId;              // Owner (null = local only)
  
  // For future: tags, folder, color, etc.
}
```

---

### 6. Web vs Mobile Compatibility

**Issue:** Isar uses native code on mobile, IndexedDB on web

**Solution from Phase 1:**
```dart
// Platform-specific initialization
// Android/iOS: Isar with SQLite
// Web: Isar with IndexedDB (automatic)
```

**Already handled in Phase 1** — just need to complete repository implementation

---

### 7. Auto-Save Strategy

**Option A: Debounced Save (Recommended)**
```dart
// Wait 500ms after user stops typing, then save
// Prevents excessive writes while typing
```

**Option B: Immediate Save**
```dart
// Save on every keystroke
// Simpler but more writes
```

**Option C: Manual Save**
```dart
// User presses save button
// Old-school, not "flow" friendly
```

**Decision:** Debounced auto-save (500ms delay)

---

### 8. Error Handling

**Database Errors:**
```dart
try {
  await isar.writeTxn(() async {
    await isar.notes.put(note);
  });
} on IsarError catch (e) {
  throw DatabaseException('Failed to save note: ${e.message}');
}
```

**Already have error infrastructure from Phase 1** — just extend for database

---

## Technical Decisions

### Locked Decisions

1. **Isar 3.x** — Already chosen in Phase 1
2. **Repository Pattern** — Clean architecture from Phase 1
3. **Reactive Streams** — UI auto-updates with Riverpod
4. **Debounced Auto-Save** — 500ms delay

### Claude's Discretion

1. **Soft Delete vs Hard Delete?**
   - *Recommendation:* Hard delete for MVP (simpler)
   - *Alternative:* Soft delete (isDeleted flag) for "recently deleted" folder
   - **Decision:** Hard delete

2. **Note ID Type?**
   - *Option:* Auto-increment int (Isar default)
   - *Alternative:* UUID string
   - **Decision:** Auto-increment int (simpler, faster)

3. **Content Length Limit?**
   - *Option:* Unlimited
   - *Alternative:* Max 10,000 chars
   - **Decision:** Unlimited (for now)

---

## Dependencies

Already present from Phase 1:
- `isar: ^3.1.0`
- `isar_flutter_libs: ^3.1.0`

No new dependencies needed.

---

## Files to Create/Modify

### New:
- `lib/data/models/isar_note_model.dart` — Isar entity
- `lib/domain/repositories/note_repository.dart` — Interface
- `lib/data/repositories/isar_note_repository.dart` — Implementation
- `lib/domain/usecases/create_note_usecase.dart` — Create
- `lib/domain/usecases/get_notes_usecase.dart` — Read all
- `lib/domain/usecases/get_note_usecase.dart` — Read single
- `lib/domain/usecases/update_note_usecase.dart` — Update
- `lib/domain/usecases/delete_note_usecase.dart` — Delete
- `lib/presentation/providers/notes_provider.dart` — Riverpod providers

### Modify:
- `lib/data/datasources/local_database.dart` — Complete Isar setup
- `lib/core/di/providers.dart` — Add note providers
- `lib/presentation/pages/home_page.dart` — Show real notes
- `lib/presentation/pages/note_editor_page.dart` — Save/edit notes

---

## Open Questions

1. **Initial Content:** Empty note or template?
   - *Recommendation:* Empty with placeholder text

2. **Default Title:** If user doesn't add title?
   - *Recommendation:* First line of content or "Untitled Note"

3. **Confirm Delete:** Always or only if has content?
   - *Recommendation:* Always confirm (safety)

---

## References

- [Isar Documentation](https://isar.dev/)
- [Isar Queries](https://isar.dev/queries.html)
- [Isar Collections](https://isar.dev/collections.html)

---

*Research completed: 2025-02-27*
*Ready for planning*
