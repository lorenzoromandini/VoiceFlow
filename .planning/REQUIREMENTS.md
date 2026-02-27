# Requirements: VoiceFlow Notes

**Defined:** 2025-02-27
**Core Value:** Users can speak naturally to instantly capture their thoughts as text notes that sync across all their devices.

## v1 Requirements

### Authentication (AUTH)

- [ ] **AUTH-01**: User can sign up with email and password
- [ ] **AUTH-02**: User can sign in with Google OAuth
- [ ] **AUTH-03**: User session persists across app restarts
- [ ] **AUTH-04**: User can log out from settings
- [ ] **AUTH-05**: User can reset password via email link

### Notes Management (NOTE)

- [ ] **NOTE-01**: User can create a new text note
- [ ] **NOTE-02**: User can edit note title and content
- [ ] **NOTE-03**: User can delete a note with confirmation
- [ ] **NOTE-04**: User can view list of all notes sorted by last modified
- [ ] **NOTE-05**: User can search notes by title or content
- [ ] **NOTE-06**: User can view a single note in full-screen editor

### Voice Input (VOICE)

- [ ] **VOICE-01**: User can start voice recording with one tap
- [ ] **VOICE-02**: User sees real-time speech-to-text transcription
- [ ] **VOICE-03**: User can pause and resume recording
- [ ] **VOICE-04**: User can stop recording and save transcription to note
- [ ] **VOICE-05**: Voice input works on Android with native SpeechRecognizer
- [ ] **VOICE-06**: Voice input works on Web with Web Speech API (Chrome/Edge)
- [ ] **VOICE-07**: Voice recording handles microphone permissions gracefully

### Offline & Sync (SYNC)

- [ ] **SYNC-01**: Notes save to local device immediately (SQLite/Isar)
- [ ] **SYNC-02**: App detects online/offline state
- [ ] **SYNC-03**: When online and logged in, notes sync to Firebase Cloud Firestore
- [ ] **SYNC-04**: Sync is bi-directional (local changes upload, cloud changes download)
- [ ] **SYNC-05**: Sync handles conflicts with last-write-wins strategy
- [ ] **SYNC-06**: User can use app fully offline (create, edit, view notes)
- [ ] **SYNC-07**: Unsynced changes queue and sync when connection restored

### Cross-Platform (PLATFORM)

- [ ] **PLATFORM-01**: App builds and runs on Android (APK)
- [ ] **PLATFORM-02**: App builds and runs as Progressive Web App (PWA)
- [ ] **PLATFORM-03**: PWA has install prompt and works offline
- [ ] **PLATFORM-04**: UI adapts to mobile, tablet, and desktop screen sizes
- [ ] **PLATFORM-05**: Platform-specific features degrade gracefully (e.g., web STT limited browsers)

### User Experience (UX)

- [ ] **UX-01**: App launches to note list in under 3 seconds
- [ ] **UX-02**: New note creation flow takes 2 taps maximum
- [ ] **UX-03**: Voice-to-text conversion shows visual feedback (animated waveform or pulsing indicator)
- [ ] **UX-04**: Error messages are user-friendly and actionable
- [ ] **UX-05**: Splash screen shows during app initialization
- [ ] **UX-06**: Loading states have skeleton screens or spinners

## v2 Requirements

### Notes Enhancement

- **NOTE-07**: User can organize notes with tags/categories
- **NOTE-08**: User can pin important notes to top of list
- **NOTE-09**: User can duplicate a note
- **NOTE-10**: User can export notes as text/markdown/PDF

### Voice Enhancement

- **VOICE-08**: Voice commands to format text ("period", "new line", "comma")
- **VOICE-09**: Multiple languages supported for transcription
- **VOICE-10**: Voice input with audio recording backup (save both)

### Sync Enhancement

- **SYNC-08**: Real-time sync (live updates across devices)
- **SYNC-09**: Sync conflict resolution UI (choose which version to keep)
- **SYNC-10**: Background sync when app is closed (via WorkManager)

### Platform

- **PLATFORM-06**: iOS support (iPhone/iPad)
- **PLATFORM-07**: Desktop support (Windows/macOS/Linux via Flutter)

### Collaboration

- **COLLAB-01**: User can share individual notes via public link
- **COLLAB-02**: User can share notes with specific users via email

## Out of Scope

| Feature | Reason |
|---------|--------|
| Rich text formatting (bold, italic, lists) | Adds UI complexity; plain text keeps voice-to-text flow fast and simple |
| Audio recording/playback | Not voice memos app; pure speech-to-text focus per core value |
| End-to-end encryption | Standard Firebase security sufficient for MVP; adds significant complexity |
| Custom ML transcription models | Use platform STT APIs; custom models require massive training data |
| Collaboration/editing between multiple users | Personal notes only; multi-user editing requires complex conflict resolution |
| Folders/hierarchical organization | Tags (v2) preferred for simplicity over nested folders |
| Note templates | Adds UI complexity without clear user benefit for voice capture |
| Handwriting recognition | Out of scope for voice-first app |
| Widget support | Nice-to-have but not critical for MVP |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 1 | Pending |
| AUTH-05 | Phase 1 | Pending |
| NOTE-01 | Phase 2 | Pending |
| NOTE-02 | Phase 2 | Pending |
| NOTE-03 | Phase 2 | Pending |
| NOTE-04 | Phase 2 | Pending |
| NOTE-05 | Phase 2 | Pending |
| NOTE-06 | Phase 2 | Pending |
| VOICE-01 | Phase 3 | Pending |
| VOICE-02 | Phase 3 | Pending |
| VOICE-03 | Phase 3 | Pending |
| VOICE-04 | Phase 3 | Pending |
| VOICE-05 | Phase 3 | Pending |
| VOICE-06 | Phase 3 | Pending |
| VOICE-07 | Phase 3 | Pending |
| SYNC-01 | Phase 2 | Pending |
| SYNC-02 | Phase 4 | Pending |
| SYNC-03 | Phase 4 | Pending |
| SYNC-04 | Phase 4 | Pending |
| SYNC-05 | Phase 4 | Pending |
| SYNC-06 | Phase 2 | Pending |
| SYNC-07 | Phase 4 | Pending |
| PLATFORM-01 | Phase 1 | Pending |
| PLATFORM-02 | Phase 5 | Pending |
| PLATFORM-03 | Phase 5 | Pending |
| PLATFORM-04 | Phase 1 | Pending |
| PLATFORM-05 | Phase 5 | Pending |
| UX-01 | Phase 1 | Pending |
| UX-02 | Phase 2 | Pending |
| UX-03 | Phase 3 | Pending |
| UX-04 | Phase 1 | Pending |
| UX-05 | Phase 1 | Pending |
| UX-06 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 37 total
- Mapped to phases: 37
- Unmapped: 0 ✓

---
*Requirements defined: 2025-02-27*
*Last updated: 2025-02-27 after initial definition*
