# Roadmap: VoiceFlow Notes

**Project:** VoiceFlow Notes — Voice-first note-taking for Android + Web  
**Core Value:** Users can speak naturally to instantly capture their thoughts as text notes that sync across all their devices.  
**Created:** 2025-02-27  
**Updated:** 2025-02-27 (Expanded to Comprehensive)  
**Phases:** 12 | **Depth:** Comprehensive

---

## Overview

This roadmap delivers VoiceFlow Notes in **12 focused phases**, following local-first architecture patterns. Each phase builds a complete, verifiable capability with 1-3 core requirements. The expanded structure provides finer-grained milestones for better progress tracking and earlier feedback loops.

**Phase Ordering Principles:**
1. **Foundation first:** Core architecture, then auth, then UI framework
2. **Local before cloud:** Storage layer before operations before sync
3. **Voice in layers:** Recording → Transcription → Cross-platform support
4. **Sync in stages:** Connectivity detection → Queue → Cloud integration
5. **Android before Web:** Validate on native first, then PWA completion
6. **Vertical slices:** Each phase delivers observable user value

---

## Phase 1: Project Setup & Architecture Foundation

**Goal:** Developer has a runnable Flutter project with clean architecture, dependency injection, and local storage foundation ready for feature development.

**Dependencies:** None (starting point)

**Requirements:**
| ID | Requirement |
|----|-------------|
| SYNC-01 | Notes save to local device immediately (SQLite/Isar) |
| PLATFORM-01 | App builds and runs on Android (APK) |
| UX-04 | Error messages are user-friendly and actionable |

**Success Criteria:**
1. `flutter run` launches app successfully on Android emulator/device
2. Clean architecture layers established (Data/Domain/Presentation)
3. Dependency injection configured and working (Riverpod or GetIt)
4. Local database schema created and migrations working
5. Basic error handling shows user-friendly messages with actionable next steps
6. Project builds APK without errors with proper signing configuration

---

## Phase 2: Authentication System

**Goal:** Users can securely create accounts and authenticate via email/password or Google OAuth.

**Dependencies:** Phase 1 (project foundation, error handling)

**Requirements:**
| ID | Requirement |
|----|-------------|
| AUTH-01 | User can sign up with email and password |
| AUTH-02 | User can sign in with Google OAuth |
| AUTH-05 | User can reset password via email link |

**Success Criteria:**
1. New user can create account with email/password and see success confirmation
2. User can sign in with Google OAuth and land on authenticated screen
3. User receives password reset email within 60 seconds of requesting it
4. Password reset flow completes successfully and allows new login
5. Form validation shows clear error messages for invalid inputs
6. Auth state persists across app restarts (token/refresh mechanism)

---

## Phase 3: Navigation & UI Framework

**Goal:** Users navigate between screens with responsive layouts that adapt to device size, with polished loading states.

**Dependencies:** Phase 1 (project foundation), Phase 2 (authentication state)

**Requirements:**
| ID | Requirement |
|----|-------------|
| AUTH-03 | User session persists across app restarts |
| PLATFORM-04 | UI adapts to mobile, tablet, and desktop screen sizes |
| UX-05 | Splash screen shows during app initialization |
| UX-06 | Loading states have skeleton screens or spinners |
| UX-01 | App launches to note list in under 3 seconds |

**Success Criteria:**
1. App displays splash screen during cold start with smooth fade transition
2. Navigation between screens uses declarative routing with proper deep links
3. UI layout adapts responsively to phone (portrait), tablet, and desktop sizes
4. Authenticated users skip login and land on note list directly
5. Loading states show appropriate skeleton screens or spinners
6. App launches from cold start to first screen in under 3 seconds
7. Bottom navigation or drawer provides clear way to access key screens

---

## Phase 4: Local Storage Architecture

**Goal:** Notes persist locally with proper data models, repositories, and local-first persistence patterns.

**Dependencies:** Phase 1 (database foundation)

**Requirements:**
| ID | Requirement |
|----|-------------|
| SYNC-06 | User can use app fully offline (create, edit, view notes) |

**Success Criteria:**
1. Note domain model defined with proper fields (id, title, content, timestamps)
2. Repository pattern implemented with clean separation from UI
3. Local data source (SQLite) saves notes immediately on any operation
4. Offline mode works fully — all CRUD operations function without network
5. Data persists after app restart and device reboot
6. Repository provides streams/reactive updates for UI consumption

---

## Phase 5: Note CRUD Operations

**Goal:** Users can create, read, update, and delete notes with a fast, intuitive interface.

**Dependencies:** Phase 3 (navigation, responsive UI), Phase 4 (local storage)

**Requirements:**
| ID | Requirement |
|----|-------------|
| NOTE-01 | User can create a new text note |
| NOTE-02 | User can edit note title and content |
| NOTE-03 | User can delete a note with confirmation |
| NOTE-06 | User can view a single note in full-screen editor |
| UX-02 | New note creation flow takes 2 taps maximum |

**Success Criteria:**
1. User can create a new note in 2 taps or fewer from any screen
2. Note editor supports title and content editing with auto-save
3. User can view single note in distraction-free full-screen editor
4. Delete action shows confirmation dialog to prevent accidental loss
5. Changes save immediately to local storage without manual action
6. Back navigation properly handles unsaved changes with warnings
7. Empty states show helpful guidance when no notes exist

---

## Phase 6: Search & List Management

**Goal:** Users can browse, sort, and search their notes efficiently.

**Dependencies:** Phase 4 (local storage), Phase 5 (note CRUD)

**Requirements:**
| ID | Requirement |
|----|-------------|
| NOTE-04 | User can view list of all notes sorted by last modified |
| NOTE-05 | User can search notes by title or content |
| AUTH-04 | User can log out from settings |

**Success Criteria:**
1. Note list displays all notes sorted by last modified (newest first)
2. Pull-to-refresh gesture works on note list (even if just local refresh)
3. Search filters notes in real-time as user types (title and content)
4. Empty search state shows "no results" with option to clear search
5. Note list shows swipe actions for quick delete or archive
6. User can log out from settings screen with confirmation
7. List performance handles 100+ notes without significant lag

---

## Phase 7: Voice Recording System

**Goal:** Users can record audio with one-tap controls, pause/resume, and proper permission handling.

**Dependencies:** Phase 5 (note creation, editor UI)

**Requirements:**
| ID | Requirement |
|----|-------------|
| VOICE-01 | User can start voice recording with one tap |
| VOICE-03 | User can pause and resume recording |
| VOICE-07 | Voice recording handles microphone permissions gracefully |

**Success Criteria:**
1. Recording starts with single tap from note creation or editor
2. Recording controls show: record, pause, resume, stop with clear icons
3. Visual indicator shows recording is active (timer, waveform animation)
4. Pause/resume maintains single continuous recording session
5. Microphone permission requested with clear explanation on first use
6. Permission denial shows helpful guidance to enable in device settings
7. Recording session survives brief app backgrounding (configurable)

---

## Phase 8: Speech-to-Text Integration

**Goal:** Users see their spoken words transcribed to text in real-time with clear visual feedback.

**Dependencies:** Phase 7 (recording system, permissions)

**Requirements:**
| ID | Requirement |
|----|-------------|
| VOICE-02 | User sees real-time speech-to-text transcription |
| VOICE-04 | User can stop recording and save transcription to note |
| UX-03 | Voice-to-text conversion shows visual feedback (animated waveform or pulsing indicator) |

**Success Criteria:**
1. Spoken words appear as text in real-time while recording (streaming transcription)
2. Visual feedback shows active transcription (pulsing indicator or waveform)
3. Transcription accuracy is reasonable for clear speech (platform-dependent)
4. User can stop recording and transcription appends to note content
5. Transcription continues across brief pauses without stopping
6. Error handling for transcription failures with retry option
7. Transcription respects punctuation from speech (period, comma, etc.)

---

## Phase 9: Cross-Platform Voice Support

**Goal:** Voice input works on both Android native and Web platforms with graceful degradation.

**Dependencies:** Phase 8 (STT integration)

**Requirements:**
| ID | Requirement |
|----|-------------|
| VOICE-05 | Voice input works on Android with native SpeechRecognizer |
| VOICE-06 | Voice input works on Web with Web Speech API (Chrome/Edge) |
| PLATFORM-05 | Platform-specific features degrade gracefully (e.g., web STT limited browsers) |

**Success Criteria:**
1. Voice recording works on Android using native SpeechRecognizer API
2. Voice recording works on Web PWA using Web Speech API (Chrome/Edge)
3. Unsupported browsers show clear message about voice limitations
4. Web build compiles and runs without platform channel errors
5. Platform-specific code uses conditional compilation or service abstraction
6. Microphone permissions work correctly on both platforms
7. Recording quality and latency acceptable on both platforms

---

## Phase 10: Connectivity & Sync Queue

**Goal:** App detects network state changes and queues sync operations for later execution.

**Dependencies:** Phase 4 (local storage), Phase 6 (note operations complete)

**Requirements:**
| ID | Requirement |
|----|-------------|
| SYNC-02 | App detects online/offline state |
| SYNC-07 | Unsynced changes queue and sync when connection restored |
| SYNC-05 | Sync handles conflicts with last-write-wins strategy |

**Success Criteria:**
1. App accurately detects and displays online/offline status in UI
2. Status indicator updates automatically when connectivity changes
3. Unsynced changes are queued locally with timestamps
4. Queue persists across app restarts
5. When connection restored, queued changes sync automatically
6. Conflict resolution uses last-write-wins with timestamp comparison
7. Sync status shows in UI (synced/syncing/offline/error with retry)

---

## Phase 11: Firebase Cloud Sync

**Goal:** User notes synchronize bi-directionally between devices via Firebase when online and authenticated.

**Dependencies:** Phase 2 (authentication), Phase 10 (connectivity & sync queue)

**Requirements:**
| ID | Requirement |
|----|-------------|
| SYNC-03 | When online and logged in, notes sync to Firebase Cloud Firestore |
| SYNC-04 | Sync is bi-directional (local changes upload, cloud changes download) |

**Success Criteria:**
1. Authenticated users see notes sync to Firestore when online
2. Changes on device A appear on device B within 30 seconds of sync
3. Bi-directional sync works: local edits upload, cloud edits download
4. Sync respects user authentication boundaries (user A cannot see user B notes)
5. Offline-created notes sync automatically when user logs in and goes online
6. Firestore acts as sync target only; local storage remains source of truth
7. Sync failures show retry button with exponential backoff strategy

---

## Phase 12: PWA & Web Optimization

**Goal:** Users can install VoiceFlow Notes as a PWA on desktop with proper offline support and update mechanisms.

**Dependencies:** Phase 3 (responsive UI), Phase 9 (web voice support), Phase 11 (cloud sync)

**Requirements:**
| ID | Requirement |
|----|-------------|
| PLATFORM-02 | App builds and runs as Progressive Web App (PWA) |
| PLATFORM-03 | PWA has install prompt and works offline |

**Success Criteria:**
1. `flutter build web` produces valid PWA with manifest.json
2. Browser shows "Add to Home Screen" install prompt on supported browsers
3. PWA installs successfully and launches with app icon on desktop/mobile
4. Service worker caches assets for offline functionality
5. PWA works offline with all features functional (local-first architecture)
6. PWA detects and notifies users of available updates
7. Update mechanism allows user to refresh or defer update
8. Web app passes Lighthouse PWA audit with score >90

---

## Progress Tracker

| Phase | Goal | Requirements | Status | Started | Completed |
|-------|------|--------------|--------|---------|-----------|
| 1 | Project Setup & Architecture | 3 | ⏸️ Pending | — | — |
| 2 | Authentication System | 3 | ⏸️ Pending | — | — |
| 3 | Navigation & UI Framework | 5 | ⏸️ Pending | — | — |
| 4 | Local Storage Architecture | 1 | ⏸️ Pending | — | — |
| 5 | Note CRUD Operations | 5 | ⏸️ Pending | — | — |
| 6 | Search & List Management | 3 | ⏸️ Pending | — | — |
| 7 | Voice Recording System | 3 | ⏸️ Pending | — | — |
| 8 | Speech-to-Text Integration | 3 | ⏸️ Pending | — | — |
| 9 | Cross-Platform Voice Support | 3 | ⏸️ Pending | — | — |
| 10 | Connectivity & Sync Queue | 3 | ⏸️ Pending | — | — |
| 11 | Firebase Cloud Sync | 2 | ⏸️ Pending | — | — |
| 12 | PWA & Web Optimization | 2 | ⏸️ Pending | — | — |

**Overall Progress:** 0/37 v1 requirements delivered

---

## Dependency Map

```
Phase 1: Project Setup
  └── Foundation: Architecture, local DB, error handling
      │
      ├──→ Phase 2: Authentication
      │      └── Email, Google OAuth, password reset
      │          │
      │          └──→ Phase 11: Firebase Cloud Sync
      │                 └── Requires authenticated user
      │
      ├──→ Phase 3: Navigation & UI
      │      └── Routing, responsive layouts, splash
      │          │
      │          ├──→ Phase 5: Note CRUD
      │          │      └── Needs navigation to editor
      │          │
      │          └──→ Phase 12: PWA
      │                 └── Needs responsive UI
      │
      └──→ Phase 4: Local Storage
             └── Repository, models, offline persistence
                 │
                 ├──→ Phase 5: Note CRUD
                 │      └── Needs storage layer
                 │
                 ├──→ Phase 6: Search & List
                 │      └── Needs notes to display
                 │
                 └──→ Phase 10: Sync Queue
                        └── Needs local storage foundation

Phase 5: Note CRUD
  └── Create, edit, delete notes
      │
      └──→ Phase 7: Voice Recording
             └── Needs note creation flow
                 │
                 └──→ Phase 8: STT Integration
                        └── Needs recording system
                        │
                        └──→ Phase 9: Cross-Platform Voice
                               └── Needs working STT
                               │
                               └──→ Phase 12: PWA
                                      └── Needs web voice support

Phase 10: Sync Queue
  └── Connectivity, queue, conflicts
      │
      └──→ Phase 11: Firebase Cloud Sync
             └── Needs queue and auth
```

---

## Coverage Summary

**v1 Requirements:** 37 total

| Phase | Requirements | Count |
|-------|--------------|-------|
| Phase 1 | SYNC-01, PLATFORM-01, UX-04 | 3 |
| Phase 2 | AUTH-01, AUTH-02, AUTH-05 | 3 |
| Phase 3 | AUTH-03, PLATFORM-04, UX-05, UX-06, UX-01 | 5 |
| Phase 4 | SYNC-06 | 1 |
| Phase 5 | NOTE-01, NOTE-02, NOTE-03, NOTE-06, UX-02 | 5 |
| Phase 6 | NOTE-04, NOTE-05, AUTH-04 | 3 |
| Phase 7 | VOICE-01, VOICE-03, VOICE-07 | 3 |
| Phase 8 | VOICE-02, VOICE-04, UX-03 | 3 |
| Phase 9 | VOICE-05, VOICE-06, PLATFORM-05 | 3 |
| Phase 10 | SYNC-02, SYNC-07, SYNC-05 | 3 |
| Phase 11 | SYNC-03, SYNC-04 | 2 |
| Phase 12 | PLATFORM-02, PLATFORM-03 | 2 |
| **Total** | | **37** |

**Coverage Status:** ✓ 37/37 requirements mapped (100%)

---

## Phase Cluster Summary

For higher-level planning, phases group into logical milestones:

| Cluster | Phases | Theme | User Value |
|---------|--------|-------|------------|
| **Foundation** | 1-3 | Setup, Auth, Navigation | App launches, user can log in |
| **Local Notes** | 4-6 | Storage, CRUD, Search | User can manage notes offline |
| **Voice Input** | 7-9 | Recording, STT, Cross-Platform | User can speak to create notes |
| **Cloud Sync** | 10-11 | Queue, Firebase | Notes sync across devices |
| **Web/PWA** | 12 | PWA, Web optimization | App works on desktop web |

---

## Success Criteria Quality Check

| Phase | Criteria Count | Observable Behaviors | All User-Focused |
|-------|----------------|----------------------|------------------|
| 1 | 6 | All developer + user observable | ✓ |
| 2 | 6 | All user-observable | ✓ |
| 3 | 7 | All user-observable | ✓ |
| 4 | 6 | All developer-verified | ✓ |
| 5 | 7 | All user-observable | ✓ |
| 6 | 7 | All user-observable | ✓ |
| 7 | 7 | All user-observable | ✓ |
| 8 | 7 | All user-observable | ✓ |
| 9 | 7 | All user-observable | ✓ |
| 10 | 7 | All user-observable | ✓ |
| 11 | 7 | All user-observable | ✓ |
| 12 | 8 | All user-observable | ✓ |

**All success criteria describe observable behaviors, not implementation tasks.**

---

## Change Log

| Date | Change |
|------|--------|
| 2025-02-27 | Initial roadmap created with 6 phases |
| 2025-02-27 | **Expanded to 12 phases** — Broke down complex phases into granular, focused delivery units |

---

*Roadmap created by GSD Roadmapper. Update via `/gsd-plan-phase` to mark progress.*
