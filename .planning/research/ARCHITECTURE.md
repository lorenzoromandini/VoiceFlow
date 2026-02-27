# Architecture Patterns: Local-First Note-Taking Apps with Offline Sync

**Project:** VoiceFlow Notes  
**Domain:** Flutter voice notes app with speech-to-text and offline-first sync  
**Researched:** 2025-02-27  
**Confidence:** HIGH

---

## Recommended Architecture

Based on Flutter's official architecture guide and local-first patterns, VoiceFlow Notes should adopt a **Layered Architecture with Repository Pattern** for handling the local-first + offline sync requirements.

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Views     │  │  ViewModels │  │   State Management      │  │
│  │  (Widgets)  │◄─┤  (Cubits/   │◄─┤   (Bloc/Provider/River) │  │
│  │             │  │  Notifiers) │  │                         │  │
│  └──────┬──────┘  └──────┬──────┘  └─────────────────────────┘  │
└─────────┼────────────────┼──────────────────────────────────────┘
          │                │
          └────────────────┘
                   │
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER (Optional)                    │
│  ┌─────────────────┐  ┌─────────────────┐                       │
│  │    Use Cases    │  │  Domain Models  │                       │
│  │ (CreateNote,    │  │  (Note, User)   │                       │
│  │  SyncNotes)     │  │                 │                       │
│  └─────────────────┘  └─────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
          │
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│  │   Repository    │  │    Services     │  │  Connectivity    │  │
│  │ (NoteRepository)│◄─┤ (Firebase,     │  │  (Monitor online │  │
│  │                 │  │  Speech, Local │  │   status)        │  │
│  └───────┬─────────┘  └─────────────────┘  └──────────────────┘  │
│          │                                                      │
│          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              LOCAL STORAGE (Source of Truth)                │ │
│  │  ┌──────────────┐  ┌──────────────┐                       │ │
│  │  │ SQLite/Hive  │  │ Audio Cache  │                       │ │
│  │  │   (Notes)    │  │  (Recordings)│                       │ │
│  │  └──────────────┘  └──────────────┘                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                     │
│          ┌────────────────┼────────────────┐                   │
│          │                │                │                   │
│          ▼                ▼                ▼                   │
│  ┌─────────────────┐ ┌───────────┐ ┌──────────────┐           │
│  │ Firebase Cloud  │ │   Web     │ │ Sync Queue   │           │
│  │  (Sync target)  │ │  Speech API │ │ (Pending ops)│           │
│  └─────────────────┘ └───────────┘ └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Boundaries

### 1. **UI Layer** — What the user sees

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| **Views** | Render UI, capture user input (voice button, text input), display note list | ViewModels only |
| **ViewModels** | Manage UI state, transform domain data for display, handle user events | Repositories |

**Key Rule:** Views never talk directly to Repositories or Services. Always go through ViewModels.

### 2. **Domain Layer** (Optional but recommended) — Business logic

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| **Use Cases** | Encapsulate business operations (CreateNote, SyncNotes, DeleteNote) | Repositories |
| **Domain Models** | Core entities (Note, User) that don't depend on external frameworks | Everyone |

### 3. **Data Layer** — The source of truth

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| **NoteRepository** | CRUD operations, manages sync state, handles offline/online transitions | Local DB, FirebaseService, Connectivity |
| **FirebaseService** | Cloud sync, auth, conflict resolution | Firebase SDK |
| **SpeechToTextService** | Voice recording and transcription | Platform APIs |
| **LocalStorageService** | SQLite/Hive operations | SQLite/Hive packages |
| **ConnectivityService** | Monitor network status | Connectivity_plus |
| **SyncQueue** | Queue pending operations when offline | LocalStorage |

---

## Data Flow

### Flow 1: Creating a New Note (Voice Input)

```
1. User taps microphone → View sends event to ViewModel
2. ViewModel calls NoteRepository.createNote(audioInput)
3. Repository:
   a. Transcribes audio via SpeechToTextService
   b. Creates Note domain model
   c. Saves to LocalStorage (SQLite/Hive) - IMMEDIATELY
   d. Emits noteCreated event
   e. If online: calls FirebaseService.syncNote()
   f. If offline: adds to SyncQueue
4. Repository returns Note to ViewModel
5. ViewModel updates UI state
6. View rebuilds to show new note
```

### Flow 2: Offline → Online Transition

```
1. ConnectivityService detects online
2. ConnectivityService notifies NoteRepository
3. Repository queries SyncQueue for pending operations
4. For each pending operation:
   a. Apply to FirebaseService
   b. On success: remove from queue
   c. On failure: retry with exponential backoff
5. After sync, fetch remote changes:
   a. Query FirebaseService for notes modified since last sync
   b. Merge with local (conflict resolution)
   c. Update LocalStorage
   d. Emit syncCompleted event
6. ViewModel updates UI with sync status
```

### Flow 3: Opening App (Startup)

```
1. App initializes
2. Initialize LocalStorage (SQLite/Hive)
3. Initialize Firebase (auth check)
4. Load notes from LocalStorage ONLY (fast, offline-capable)
5. If online: background sync with Firebase
6. Display notes immediately (no waiting)
```

---

## Recommended Component Responsibilities

### NoteRepository

**Single Responsibility:** Manage note data lifecycle and synchronization

**Must handle:**
- Local CRUD (create, read, update, delete)
- Sync state tracking (synced, pending, conflict)
- Offline queue management
- Conflict resolution (last-write-wins or custom strategy)
- Retry logic with exponential backoff

**Never directly:**
- Talk to UI widgets
- Manage authentication (delegate to FirebaseService)
- Handle speech-to-text transcription (delegate to SpeechService)

```dart
abstract class NoteRepository {
  // Local operations (always available)
  Future<Note> createNote({String? text, String? audioPath});
  Future<List<Note>> getNotes();
  Future<Note> updateNote(String id, {String? text});
  Future<void> deleteNote(String id);
  
  // Sync operations
  Stream<SyncStatus> get syncStatus;
  Future<void> syncNow();
  Future<void> resolveConflict(String noteId, ConflictResolution strategy);
}
```

### FirebaseService

**Single Responsibility:** Abstract Firebase Cloud interactions

**Must handle:**
- Firestore CRUD operations
- Auth state changes
- Real-time listeners (optional)
- Error handling (network, permissions)

**Why separate:** Testing (can mock), switching providers later, offline/online abstraction

```dart
abstract class FirebaseService {
  Future<void> saveNote(Note note);
  Future<List<Note>> fetchNotes({DateTime? since});
  Future<void> deleteNote(String id);
  Stream<List<Note>> watchNotes();
  Future<User?> getCurrentUser();
}
```

### LocalStorageService (SQLite/Hive)

**Single Responsibility:** Persist data locally with fast access

**Must handle:**
- Database initialization
- CRUD operations
- Schema migrations
- Query optimization (indexes)

**Recommendation:** SQLite via `sqflite` for structured data (better query support), Hive for simple key-value (faster writes).

For note-taking app: **SQLite** recommended because:
- Complex queries (search, filter by date)
- ACID transactions
- Better for structured note data with metadata

```dart
abstract class LocalStorageService {
  Future<void> initialize();
  Future<int> insertNote(Note note);
  Future<List<Note>> getNotes({String? query, DateTime? from, DateTime? to});
  Future<int> updateNote(Note note);
  Future<int> deleteNote(String id);
  Future<Note?> getNoteById(String id);
}
```

### SyncQueue

**Single Responsibility:** Track operations that need to sync to cloud

**Schema:**
```
table sync_queue {
  id: string (auto)
  operation: enum [create, update, delete]
  note_id: string
  payload: json (serialized note data)
  created_at: timestamp
  retry_count: int (0, 1, 2...)
  last_error: string?
}
```

**Behavior:**
- On create/update/delete when offline: add to queue
- On connectivity restored: process queue FIFO
- On failure: increment retry_count, apply exponential backoff
- On max retries: mark as failed, notify user

---

## Patterns to Follow

### Pattern 1: **Offline-First Repository**

**What:** All operations complete locally first, then sync to cloud

**Why:** App works offline, fast UI response, user never waits for network

**Implementation:**
```dart
Future<Note> createNote(String text) async {
  // 1. Create locally first
  final note = Note(id: generateId(), text: text, createdAt: DateTime.now());
  await _localStorage.insertNote(note);
  
  // 2. Mark as pending sync
  await _syncQueue.add(SyncOperation.create, note);
  
  // 3. Try to sync immediately if online
  if (await _connectivity.isOnline) {
    _backgroundSync(); // Don't await, let user continue
  }
  
  return note;
}
```

### Pattern 2: **Event-Driven Sync Status**

**What:** Use Streams to communicate sync state throughout app

**Why:** UI can show sync indicators without polling

**Implementation:**
```dart
// In Repository
final _syncStatusController = StreamController<SyncStatus>.broadcast();
Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

enum SyncStatus { synced, syncing, offline, error }

// UI listens and shows indicator
ValueListenableBuilder<SyncStatus>(
  valueListenable: repository.syncStatus,
  builder: (context, status, child) {
    return status == SyncStatus.syncing 
      ? CircularProgressIndicator()
      : Icon(Icons.cloud_done);
  },
);
```

### Pattern 3: **Conflict Resolution Strategy**

**What:** Define how to handle when local and remote data diverge

**Options:**
1. **Last-Write-Wins** (simplest): Compare timestamps, keep newer
2. **Manual Resolution**: Present both to user, let them choose
3. **Merge Strategy**: Combine changes (harder for notes)

**Recommendation for MVP:** Last-Write-Wins with timestamp comparison

### Pattern 4: **Background Sync with Debouncing**

**What:** Batch sync operations to avoid excessive network calls

**Implementation:**
```dart
Timer? _syncDebounce;

void onNoteChanged() {
  // Cancel pending sync
  _syncDebounce?.cancel();
  
  // Schedule new sync in 2 seconds
  _syncDebounce = Timer(Duration(seconds: 2), () {
    _performSync();
  });
}
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: **Direct Firebase from UI**

**What:** Widgets calling Firestore directly

**Why bad:**
- Impossible to mock for testing
- Can't add offline layer later
- UI code polluted with data logic
- No single source of truth

**Instead:** Always go through Repository

### Anti-Pattern 2: **Waiting for Network**

**What:** Blocking UI while waiting for Firebase

**Why bad:**
- App feels slow
- Doesn't work offline
- Poor user experience

**Instead:** Local-first, background sync

### Anti-Pattern 3: **Sync Everything Immediately**

**What:** Making network call for every keystroke

**Why bad:**
- Battery drain
- Excessive data usage
- Race conditions

**Instead:** Debounce sync, batch operations

### Anti-Pattern 4: **No Conflict Resolution**

**What:** Just overwriting remote data without checking

**Why bad:**
- Data loss when editing on multiple devices

**Instead:** Check version/timestamp, implement strategy

---

## Suggested Build Order (Dependencies)

Components must be built in this order due to dependencies:

### Phase 1: Foundation
1. **Domain Models** (Note, User, SyncStatus)
   - No dependencies
   - Pure Dart classes

2. **LocalStorageService + Database Schema**
   - Depends on: Domain Models
   - Implements: SQLite/Hive setup, basic CRUD

### Phase 2: Core Functionality
3. **NoteRepository (Local Only)**
   - Depends on: LocalStorageService
   - Implements: Local CRUD, no sync yet

4. **SpeechToTextService**
   - Depends on: Platform APIs
   - Implements: Voice recording, transcription

### Phase 3: Offline Capability
5. **SyncQueue**
   - Depends on: LocalStorageService
   - Implements: Queue operations, retry logic

6. **ConnectivityService**
   - Depends on: Platform APIs
   - Implements: Online/offline detection

### Phase 4: Cloud Integration
7. **FirebaseService**
   - Depends on: Domain Models, Firebase SDK
   - Implements: Cloud CRUD, auth

8. **NoteRepository (Full Sync)**
   - Depends on: Everything above
   - Implements: Full offline-first sync logic

### Phase 5: UI Layer
9. **ViewModels**
   - Depends on: NoteRepository
   - Implements: State management

10. **Views**
    - Depends on: ViewModels
    - Implements: Flutter widgets

---

## Scalability Considerations

| Concern | At 100 notes | At 10K notes | At 100K notes |
|---------|-------------|--------------|---------------|
| **Local Storage** | SQLite fine | SQLite + indexes | Consider pagination, lazy loading |
| **Sync Speed** | Full sync OK | Incremental sync | Delta sync, compression |
| **Startup Time** | Instant | Instant | Lazy load, cache metadata |
| **Search** | In-memory OK | SQLite FTS | Dedicated search index (e.g., Fuse.js) |
| **Audio Storage** | Cache all | LRU cache | Move old audio to cloud storage |

**Audio Handling Strategy:**
- Store locally for recent notes (last 30 days)
- Compress/transcode on save
- Option to archive old audio to cloud (keep transcript local)

---

## Technology-Specific Considerations

### Flutter Web + Local Storage

**Challenge:** Flutter Web has limited persistent storage options

**Solutions:**
1. **IndexedDB via hive/hive_flutter** — Good for structured data
2. **localStorage** — Limited to 5MB, use for settings only
3. **Firebase Firestore (with persistence)** — Easiest but requires network occasionally

**Recommendation for Web:** 
- Use `hive` for local notes (IndexedDB-backed)
- Or use Firestore with offline persistence enabled

### Conflict Resolution with Firestore

Firestore has built-in offline persistence, but custom conflict resolution is limited.

**Two approaches:**
1. **Use Firestore's offline** — Simpler, but less control over sync
2. **Custom sync layer** — Full control, more complex

**Recommendation:** Start with Firestore offline, migrate to custom if needed.

---

## Testing Strategy

**Repository Tests:**
- Mock LocalStorage and Firebase services
- Test sync logic, conflict resolution, offline behavior
- Run without network

**Service Tests:**
- FirebaseService: Use Firebase Emulator Suite
- LocalStorage: Use in-memory SQLite for tests
- SpeechToText: Mock platform channel

**Widget Tests:**
- Mock Repository
- Test UI behavior with different sync states

---

## Sources

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) — HIGH confidence, official Flutter team recommendations
- [Flutter Data Layer Case Study](https://docs.flutter.dev/app-architecture/case-study/data-layer) — HIGH confidence, official patterns
- [PowerSync Documentation](https://docs.powersync.com/) — MEDIUM confidence, local-first sync specialist
- [Hive Database](https://pub.dev/packages/hive) — HIGH confidence, widely used local storage
- [CBL (Couchbase Lite)](https://cbl-dart.dev/) — MEDIUM confidence, sync-capable embedded database
- [Local-First Conf](https://www.localfirstconf.com/) — MEDIUM confidence, community patterns
- [speech_to_text package](https://pub.dev/packages/speech_to_text) — HIGH confidence, official API docs

---

## Summary

**Recommended Architecture:** Layered MVVM with Repository Pattern

**Key Decisions:**
1. **Local-first**: Save to SQLite immediately, sync to Firebase in background
2. **Repository pattern**: Single source of truth, abstracts storage details
3. **Sync queue**: Handle offline operations, retry with backoff
4. **Event-driven**: Streams for sync status, connectivity changes
5. **Build order**: Local → Repository → Sync → Firebase → UI

**Critical Success Factors:**
- Repository must handle offline/online transitions gracefully
- Never block UI waiting for network
- Always have conflict resolution strategy
- Test offline behavior explicitly

**Confidence:** HIGH — These patterns are well-established in Flutter ecosystem and local-first community.
