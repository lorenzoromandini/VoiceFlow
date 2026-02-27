# Project Research Summary

**Project:** VoiceFlow Notes
**Domain:** Flutter cross-platform voice-first note-taking app (Android + Web PWA)
**Researched:** 2026-02-27
**Confidence:** HIGH

## Executive Summary

VoiceFlow Notes is a voice-first note-taking application targeting Android and Web PWA platforms. Research confirms Flutter is the optimal choice for this cross-platform requirement, offering mature web support via WebAssembly and a robust ecosystem for voice interaction. The recommended approach follows **local-first architecture** patterns: notes save immediately to local SQLite storage, then sync to Firebase Firestore in the background. This ensures offline functionality (critical for note-taking) while enabling cross-platform synchronization.

The key technical differentiator is real-time speech-to-text transcription using platform APIs (Android SpeechRecognizer, Web Speech API). However, research reveals a critical constraint: speech recognition requires internet connectivity on most platforms. The solution is designing for online transcription with audio recording fallback—capture audio locally, transcribe when connected, or allow manual transcription entry. This graceful degradation ensures the app works offline while maximizing the voice-first experience when connected.

The primary risks center on sync architecture and platform compatibility. Firebase Firestore must NOT be used as primary storage—it's a sync target only, with local SQLite as the source of truth. Additionally, web builds require careful plugin selection since many Flutter plugins lack web support, and PWA service workers need explicit cache invalidation strategies to prevent stale deployments.

## Key Findings

### Recommended Stack

Research confirms Flutter 3.41.x with Dart 3.6.x as the optimal foundation for cross-platform voice notes. Firebase provides the backend infrastructure (Auth, Firestore, Analytics), while `speech_to_text` ^7.3.0 handles voice capture across platforms. State management uses Riverpod ^3.2.1 (official Provider successor) with code generation for type-safe async handling.

**Core technologies:**
- **Flutter 3.41.x + Dart 3.6.x**: Cross-platform UI with WebAssembly support, Impeller rendering, mature ecosystem
- **Firebase (Cloud Firestore, Auth, Analytics)**: Cloud sync, anonymous auth for guests, usage tracking
- **speech_to_text ^7.3.0**: Real-time transcription across Android/iOS/Web/macOS (1500+ likes, verified publisher)
- **flutter_riverpod ^3.2.1**: Compile-safe state management with built-in async handling
- **go_router ^17.1.0**: Declarative routing with deep linking, URL-based navigation for web
- **sqflite ^2.4.2**: SQLite local database with transactions, migrations, complex queries
- **connectivity_plus ^7.0.0 + workmanager ^0.9.0+3**: Network detection and background sync scheduling

**What to avoid**: Hive (unmaintained, 3 years stale), GetX (anti-patterns, not recommended by Flutter team), Firestore as primary storage (cache only, not source of truth), direct Firebase calls from UI (untestable, tight coupling).

### Expected Features

The voice-first note domain has clear user expectations. Table stakes features must be present for the product to feel viable, while differentiators provide competitive advantage without scope creep.

**Must have (table stakes):**
- One-tap recording — Primary CTA must be instantly accessible
- Real-time transcription — Live text feedback differentiates from basic voice memos
- Note list view with search/filter — Chronological browsing essential
- Edit transcription — Users must fix recognition errors
- Local persistence — Notes survive app restart (sqflite + localStorage)
- Audio playback — Critical for verification and context
- Delete with confirmation — Prevent accidental data loss

**Should have (differentiators):**
- Cross-platform sync — Seamless Android ↔ Web experience (Firebase)
- PWA desktop support — Installable web app for desktop use
- Minimalist UX — Zero friction, gesture-based interactions
- Quick capture widget — Android home screen shortcut
- Auto-save drafts — Never lose partial recordings
- Dark/light theme — System-aware theme switching
- Export (txt/md) — Portability without in-app sharing complexity

**Defer to v2+:**
- Tags/folders — Flat list with search sufficient for MVP
- Collaboration/sharing — Adds auth complexity, export covers basic needs
- Rich text formatting — Voice notes are quick thoughts, plain text preferred
- Custom ML transcription — Platform APIs are good enough

### Architecture Approach

**Recommended: Layered MVVM with Repository Pattern**

The architecture follows local-first principles: all operations complete locally first, then sync to cloud. This provides offline capability, fast UI response, and clear separation of concerns.

```
UI Layer (Widgets) → ViewModels → Repository → Local Storage (Source of Truth)
                                              ↓
                                       Firebase (Sync Target)
```

**Major components:**
1. **UI Layer** — Views (Widgets) render UI, ViewModels manage state and transform data
2. **Domain Layer** — Use cases (CreateNote, SyncNotes), domain models (Note, User)
3. **Data Layer** — NoteRepository manages CRUD and sync state, services abstract Firebase/Speech/Storage
4. **Local Storage** — SQLite (structured data), audio cache (recordings)
5. **Sync Queue** — Tracks pending operations when offline, retries with exponential backoff

**Key patterns:**
- Offline-first: Save to SQLite immediately, emit event, sync in background
- Event-driven sync: Streams communicate sync status (synced/syncing/offline/error)
- Conflict resolution: Last-write-wins with timestamp comparison for MVP
- Background sync: Debounced batch operations to avoid excessive network calls

### Critical Pitfalls

Research identified six critical pitfalls that can cause rewrites or major issues:

1. **Using Firestore as primary offline storage** — Firestore's offline persistence is a cache, not primary storage. Sync conflicts cause data loss. **Avoid by:** Using local database (sqflite) as source of truth, treating Firestore as sync target only, implementing explicit sync layer with conflict resolution.

2. **Assuming speech-to-text works offline** — `speech_to_text` requires internet on most platforms. Android offline models vary by device; iOS and web require network. **Avoid by:** Checking connectivity before enabling STT, providing clear "requires internet" feedback, implementing audio recording fallback (record locally, transcribe later).

3. **Platform channel dependencies breaking web build** — Many Flutter plugins use native code and fail on web. **Avoid by:** Checking pub.dev for web support before adoption, using conditional imports, testing web build early (`flutter build web`), maintaining platform-specific service layers.

4. **PWA service worker cache breaking updates** — Flutter web PWA caches aggressively; users see old versions after deployment. **Avoid by:** Configuring `flutter_service_worker.js` with proper strategies, using versioned URLs, implementing manual update check with "Update Available" UI.

5. **Real-time sync without conflict resolution** — Firestore `onSnapshot` listeners cause last-write-wins, silently discarding concurrent edits. **Avoid by:** Local-first architecture (edit local, sync explicitly), using Firestore transactions with version checks, disabling real-time sync during active editing.

6. **Audio permission handling across platforms** — Microphone permissions vary significantly (Android manifest, iOS Info.plist, web HTTPS/gesture requirements). **Avoid by:** Using `permission_handler` plugin, checking permissions before initialization, handling denial gracefully with explanatory UI.

## Implications for Roadmap

Based on research, the following phase structure is recommended to manage dependencies and avoid critical pitfalls:

### Phase 1: Foundation — Local Storage & Core UI
**Rationale:** Must establish local-first architecture before any cloud features. Foundation prevents the #1 critical pitfall (Firestore as primary storage).
**Delivers:** Working local note CRUD, SQLite schema, basic UI, domain models
**Addresses:** Local persistence, note list view, basic management (edit, delete)
**Uses:** sqflite, shared_preferences, Riverpod, go_router
**Implements:** Domain models, LocalStorageService, basic Repository (local-only)
**Avoids:** Firestore dependency, premature optimization

### Phase 2: Voice Input — Recording & Transcription
**Rationale:** Core differentiator; must validate platform STT capabilities and web compatibility early.
**Delivers:** One-tap recording, real-time transcription (when online), audio playback, permission handling
**Addresses:** One-tap recording, real-time transcription, audio playback
**Uses:** speech_to_text, permission_handler
**Implements:** SpeechToTextService, permission handling
**Avoids:** Assuming offline STT works, web build breakage (must test `flutter build web`)

### Phase 3: Sync Infrastructure — Offline-Online Bridge
**Rationale:** Complex sync logic requires solid foundation from Phases 1-2. Must implement before cloud integration.
**Delivers:** Connectivity monitoring, sync queue, conflict resolution (last-write-wins), offline indicators
**Addresses:** Auto-save drafts, offline indicators, sync status
**Uses:** connectivity_plus, workmanager
**Implements:** ConnectivityService, SyncQueue, sync status streams
**Avoids:** Real-time sync conflicts, sync without conflict resolution

### Phase 4: Cloud Integration — Firebase & Cross-Platform
**Rationale:** Only after local-first architecture is proven. Firebase is sync target, not primary storage.
**Delivers:** User authentication (Google Sign-In), Firestore sync, background sync scheduling
**Addresses:** Cross-platform sync, user authentication
**Uses:** firebase_core, cloud_firestore, firebase_auth, google_sign_in
**Implements:** FirebaseService, full NoteRepository with sync logic
**Avoids:** Direct Firebase from UI, Firestore as primary storage

### Phase 5: Web/PWA — Platform Completion
**Rationale:** Web-specific features require dedicated phase after core functionality works on Android.
**Delivers:** PWA install support, service worker configuration, web-specific optimizations
**Addresses:** PWA desktop support, web deployment
**Uses:** flutter_web_plugins, service worker configuration
**Implements:** PWA manifest, update mechanism, web-specific UI adaptations
**Avoids:** PWA cache issues, stale deployments

### Phase 6: Polish — Enhancements & Export
**Rationale:** Nice-to-have features after core product is solid.
**Delivers:** Search, themes, export functionality, quick capture widget
**Addresses:** Search within transcriptions, dark/light theme, export (txt/md), quick capture widget
**Implements:** Full-text search, theme switching, share functionality

### Phase Ordering Rationale

1. **Local before cloud:** Research shows Firestore as primary storage is the #1 pitfall. Local-first architecture (Phase 1) prevents this entirely.

2. **Voice before sync:** Speech recognition has platform-specific constraints (web compatibility, offline limitations). Validating voice features (Phase 2) before building sync (Phase 3-4) ensures the core experience works.

3. **Sync infrastructure before Firebase:** Sync queue and conflict resolution are complex. Building these with local-only data (Phase 3) allows testing without Firebase complexity, then adding Firebase (Phase 4) is a service swap.

4. **Android before web:** Web has additional constraints (PWA, service workers, plugin compatibility). Getting Android working first provides validation before tackling web-specific issues.

5. **Core before polish:** Features like search, themes, and export are valuable but not launch-blockers. Phase 6 can be truncated if time pressure exists.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Voice Input):** Web Speech API browser compatibility, Android offline language pack detection
- **Phase 3 (Sync Infrastructure):** Conflict resolution strategy refinement, exponential backoff tuning
- **Phase 5 (Web/PWA):** Service worker configuration, PWA best practices, IndexedDB limitations

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Well-documented Flutter patterns (sqflite, Riverpod)
- **Phase 4 (Cloud Integration):** Firebase Flutter SDK has extensive documentation and examples
- **Phase 6 (Polish):** Standard Flutter features (theming, search, share)

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All versions verified from official sources (Flutter 3.41, Firebase packages, speech_to_text). Clear upgrade paths documented. |
| Features | HIGH | Domain well-understood (voice notes), clear table stakes vs differentiators from competitor analysis (Otter.ai, Apple Voice Memos). |
| Architecture | HIGH | Repository pattern is standard for Flutter/Firebase. Local-first patterns well-documented (Flutter Architecture Guide, PowerSync docs). |
| Pitfalls | MEDIUM | Based on official docs and package READMEs. WebSearch validation recommended for community-reported edge cases. Some platform-specific issues may emerge during implementation. |

**Overall confidence:** HIGH

### Gaps to Address

- **Web Speech API compatibility:** Chrome/Edge support confirmed, but Safari behavior needs validation during Phase 2 development
- **Offline STT on Android:** Device-specific language pack availability requires runtime detection (documented in Phase 2)
- **Conflict resolution strategy:** Last-write-wins chosen for MVP; user testing may reveal need for manual merge UI (defer to v2)
- **Audio compression:** Optimal format (AAC vs Opus) for upload size vs quality tradeoff needs empirical testing
- **PWA update UX:** Best pattern for "Update Available" notification requires user testing

## Sources

### Primary (HIGH confidence)
- [Flutter 3.41 Release Notes](https://docs.flutter.dev/release/whats-new) — Latest stable with WebAssembly, Impeller rendering
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) — Official layered architecture recommendations
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup) — Official integration documentation
- [speech_to_text 7.3.0](https://pub.dev/packages/speech_to_text) — Verified publisher, 1500+ likes, platform capability docs
- [Riverpod 3.2.1](https://pub.dev/packages/riverpod) — Flutter Favorite, official Provider successor
- [sqflite 2.4.2](https://pub.dev/packages/sqflite) — Flutter Favorite, SQLite implementation details

### Secondary (MEDIUM confidence)
- [Otter.ai Features](https://otter.ai/features) — Professional transcription app feature analysis
- [PowerSync Documentation](https://docs.powersync.com/) — Local-first sync patterns and strategies
- [Local-First Conf](https://www.localfirstconf.com/) — Community patterns for offline-first architecture
- [Firebase Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices) — Document limits, query optimization

### Tertiary (LOW confidence — needs validation)
- [Hive Status](https://pub.dev/packages/hive) — Package deprecation status (confirmed unmaintained)
- [Flutter Web Building Guide](https://docs.flutter.dev/platform-integration/web/building) — Web-specific build configuration (may need updating for WASM)
- Community-reported edge cases in speech_to_text (WebSearch recommended)

---
*Research completed: 2026-02-27*
*Ready for roadmap: yes*
