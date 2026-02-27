# Roadmap: VoiceFlow Notes

**Project:** VoiceFlow Notes — Voice-first note-taking for Android + Web  
**Core Value:** Users can speak naturally to instantly capture their thoughts as text notes that sync across all their devices.  
**Created:** 2025-02-27  
**Phases:** 6 | **Depth:** Standard

---

## Overview

This roadmap delivers VoiceFlow Notes in 6 phases, following a local-first architecture pattern. Each phase builds a complete, verifiable capability that advances toward the core value of frictionless voice capture with cross-device sync.

**Phase Ordering Rationale:**
1. **Foundation before features:** Authentication and core infrastructure first
2. **Local before cloud:** Local-first architecture prevents sync pitfalls
3. **Voice before sync:** Validate core differentiator early
4. **Sync infrastructure before Firebase:** Test sync logic locally before adding cloud complexity
5. **Android before Web:** Validate core features before platform expansion
6. **Core before polish:** Essential features before enhancements

---

## Phase 1: Foundation — Auth & Core UI

**Goal:** Users can securely authenticate and navigate a responsive app shell with polished first-load experience.

**Dependencies:** None (starting point)

**Requirements:**
| ID | Requirement |
|----|-------------|
| AUTH-01 | User can sign up with email and password |
| AUTH-02 | User can sign in with Google OAuth |
| AUTH-03 | User session persists across app restarts |
| AUTH-04 | User can log out from settings |
| AUTH-05 | User can reset password via email link |
| PLATFORM-01 | App builds and runs on Android (APK) |
| PLATFORM-04 | UI adapts to mobile, tablet, and desktop screen sizes |
| UX-01 | App launches to note list in under 3 seconds |
| UX-04 | Error messages are user-friendly and actionable |
| UX-05 | Splash screen shows during app initialization |

**Success Criteria:**
1. New user can create account with email/password and land on note list
2. User can sign in with Google and session persists after app restart
3. User can log out from settings and is returned to sign-in screen
4. User can trigger password reset and receives email within 60 seconds
5. App launches from cold start to note list in under 3 seconds
6. Splash screen displays during initialization with smooth transition
7. Error messages explain what happened and suggest next action
8. UI layout adapts properly to phone, tablet, and desktop screen sizes

---

## Phase 2: Local Notes — Storage & Management

**Goal:** Users can create, manage, and persist notes locally with fast search and editing.

**Dependencies:** Phase 1 (auth shell, navigation, responsive UI)

**Requirements:**
| ID | Requirement |
|----|-------------|
| NOTE-01 | User can create a new text note |
| NOTE-02 | User can edit note title and content |
| NOTE-03 | User can delete a note with confirmation |
| NOTE-04 | User can view list of all notes sorted by last modified |
| NOTE-05 | User can search notes by title or content |
| NOTE-06 | User can view a single note in full-screen editor |
| SYNC-01 | Notes save to local device immediately (SQLite/Isar) |
| SYNC-06 | User can use app fully offline (create, edit, view notes) |
| UX-02 | New note creation flow takes 2 taps maximum |
| UX-06 | Loading states have skeleton screens or spinners |

**Success Criteria:**
1. User can create a new note in 2 taps or fewer from note list
2. Notes appear in list immediately, sorted by last modified date
3. User can tap any note to open full-screen editor and edit content
4. User can search notes and results filter in real-time
5. User can delete a note with confirmation dialog to prevent accidents
6. All notes persist after app restart (local-first storage)
7. Loading states show skeleton screens while content loads
8. App works fully offline — create, edit, view notes without network

---

## Phase 3: Voice Input — Recording & Transcription

**Goal:** Users can capture thoughts instantly with one-tap voice recording and real-time transcription.

**Dependencies:** Phase 2 (note creation, local storage, editor UI)

**Requirements:**
| ID | Requirement |
|----|-------------|
| VOICE-01 | User can start voice recording with one tap |
| VOICE-02 | User sees real-time speech-to-text transcription |
| VOICE-03 | User can pause and resume recording |
| VOICE-04 | User can stop recording and save transcription to note |
| VOICE-05 | Voice input works on Android with native SpeechRecognizer |
| VOICE-06 | Voice input works on Web with Web Speech API (Chrome/Edge) |
| VOICE-07 | Voice recording handles microphone permissions gracefully |
| UX-03 | Voice-to-text conversion shows visual feedback (animated waveform or pulsing indicator) |

**Success Criteria:**
1. User can start voice recording with a single tap from note creation
2. Spoken words appear as text in real-time while speaking (live transcription)
3. User sees visual feedback (pulsing indicator or waveform) during recording
4. User can pause and resume recording to collect thoughts
5. User can stop recording and transcription is saved to the note
6. Voice input works on Android using native SpeechRecognizer
7. Voice input works on Web using Web Speech API (Chrome/Edge)
8. Microphone permissions are requested gracefully with clear explanation
9. Permission denials show helpful guidance on how to enable in settings

---

## Phase 4: Sync Infrastructure — Offline-Online Bridge

**Goal:** Users experience seamless offline-online transitions with automatic sync and conflict resolution.

**Dependencies:** Phase 2 (local storage), Phase 3 (voice capture)

**Requirements:**
| ID | Requirement |
|----|-------------|
| SYNC-02 | App detects online/offline state |
| SYNC-03 | When online and logged in, notes sync to Firebase Cloud Firestore |
| SYNC-04 | Sync is bi-directional (local changes upload, cloud changes download) |
| SYNC-05 | Sync handles conflicts with last-write-wins strategy |
| SYNC-07 | Unsynced changes queue and sync when connection restored |
| PLATFORM-05 | Platform-specific features degrade gracefully (e.g., web STT limited browsers) |

**Success Criteria:**
1. User sees visual indicator showing online/offline status
2. When online and logged in, notes sync automatically to cloud
3. Changes made on device A appear on device B after sync
4. Sync works in both directions — local edits upload, cloud edits download
5. Conflicts resolve with last-write-wins (newest version kept)
6. Unsynced changes queue and sync automatically when connection restored
7. Platform features degrade gracefully (e.g., web shows STT browser limitations)

---

## Phase 5: Web/PWA — Cross-Platform Completion

**Goal:** Users can install and use VoiceFlow Notes as a Progressive Web App on desktop with full offline support.

**Dependencies:** Phase 1 (responsive UI), Phase 2 (offline support), Phase 3 (voice), Phase 4 (sync)

**Requirements:**
| ID | Requirement |
|----|-------------|
| PLATFORM-02 | App builds and runs as Progressive Web App (PWA) |
| PLATFORM-03 | PWA has install prompt and works offline |
| PLATFORM-05 | Platform-specific features degrade gracefully (e.g., web STT limited browsers) |

**Success Criteria:**
1. App builds and runs successfully as PWA in Chrome/Edge
2. Browser shows install prompt allowing user to "Add to Home Screen"
3. PWA installs successfully and launches with app icon
4. PWA works offline — all features functional without network
5. Service worker handles caching properly for fast repeat visits
6. PWA detects and prompts for updates when new version deployed
7. Web-specific limitations (STT browser support) are communicated clearly

---

## Phase 6: Polish — Enhancements & UX Refinement

**Goal:** Users enjoy a refined experience with search, organization, and export capabilities.

**Dependencies:** Phase 2 (local notes), Phase 4 (sync infrastructure)

**Requirements:**
*No additional v1 requirements — this phase captures deferred nice-to-haves from earlier phases if time permits, or rolls to v2*

**Success Criteria:**
1. *Placeholder: Full-text search across all note content (if deferred from Phase 2)*
2. *Placeholder: Note export to txt/markdown (if time permits)*
3. *Placeholder: Theme switching (dark/light mode)*

**Note:** Phase 6 is intentionally flexible. Requirements may be pulled forward from deferred items, or this phase may be truncated to focus on core product stability.

---

## Progress Tracker

| Phase | Goal | Requirements | Status | Started | Completed |
|-------|------|--------------|--------|---------|-----------|
| 1 | Foundation — Auth & Core UI | 10 | ⏸️ Pending | — | — |
| 2 | Local Notes — Storage & Management | 10 | ⏸️ Pending | — | — |
| 3 | Voice Input — Recording & Transcription | 9 | ⏸️ Pending | — | — |
| 4 | Sync Infrastructure — Offline-Online Bridge | 6 | ⏸️ Pending | — | — |
| 5 | Web/PWA — Cross-Platform Completion | 3 | ⏸️ Pending | — | — |
| 6 | Polish — Enhancements & UX Refinement | 0* | ⏸️ Pending | — | — |

*Phase 6 has no hard requirements; flexible scope based on remaining time

**Overall Progress:** 0/37 v1 requirements delivered

---

## Dependency Map

```
Phase 1 (Foundation)
  └── Auth, responsive UI, fast launch
      │
      ├──→ Phase 2 (Local Notes)
      │      └── Create/edit/delete/search notes
      │          │
      │          ├──→ Phase 3 (Voice)
      │          │      └── Recording + transcription
      │          │          │
      │          │          └──→ Phase 4 (Sync)
      │          │                 └── Online/offline sync
      │          │                     │
      │          │                     ├──→ Phase 5 (Web/PWA)
      │          │                     │      └── PWA install & offline
      │          │                     │
      │          └────────────────────────→ Phase 5 (depends on local)
      │
      └──→ Phase 5 (PWA needs responsive UI from Phase 1)

Phase 6 (Polish) depends on Phase 2 & 4
```

---

## Coverage Summary

**v1 Requirements:** 37 total
- **Phase 1:** 10 requirements
- **Phase 2:** 10 requirements
- **Phase 3:** 9 requirements
- **Phase 4:** 6 requirements
- **Phase 5:** 3 requirements
- **Phase 6:** 0 requirements (flexible)

**Coverage Status:** ✓ 37/37 requirements mapped (100%)

---

## Success Criteria Quality Check

| Phase | Criteria Count | Observable Behaviors | Validated |
|-------|----------------|----------------------|-----------|
| 1 | 8 | All user-observable | ✓ |
| 2 | 8 | All user-observable | ✓ |
| 3 | 9 | All user-observable | ✓ |
| 4 | 7 | All user-observable | ✓ |
| 5 | 7 | All user-observable | ✓ |
| 6 | 3 | User-observable (flexible) | ✓ |

**All success criteria describe observable user behaviors, not implementation tasks.**

---

## Change Log

| Date | Change |
|------|--------|
| 2025-02-27 | Initial roadmap created with 6 phases |

---

*Roadmap created by GSD Roadmapper. Update via `/gsd-plan-phase` to mark progress.*
