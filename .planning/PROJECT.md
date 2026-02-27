# VoiceFlow Notes

## What This Is

VoiceFlow Notes is an open-source note-taking app for Android and Web that emphasizes voice-first input. Users speak naturally and see their words transcribed in real-time to text notes. Notes sync across devices via cloud authentication, with offline support for uninterrupted capture anywhere. Target users are people who want to quickly capture ideas by speaking without typing, and have notes available everywhere.

## Core Value

Users can speak naturally to instantly capture their thoughts as text notes that sync across all their devices.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Users can create, edit, and delete text notes
- [ ] Real-time speech-to-text input with continuous listening
- [ ] Email/password and Google authentication
- [ ] Cloud sync when logged in and online
- [ ] Local-first storage with offline support
- [ ] Cross-platform: Android native app + PWA for web
- [ ] Minimalist, fast, uncluttered UX

### Out of Scope

- Audio recording/playback (not voice memos — pure speech-to-text)
- iOS support (Android + Web only for MVP)
- Native desktop apps (PWA covers PC use)
- Rich text formatting (plain text only for simplicity)
- Collaboration/sharing between users (personal notes only)
- End-to-end encryption (standard Firebase security for MVP)
- Voice commands/control (dictation only, not app control)

## Context

**Tech Stack Considerations:**
- Flutter 3.x for cross-platform Android + Web from single codebase
- Firebase for auth, database, and cloud sync
- Speech-to-text integration critical for core value
- PWA requirements: service worker, manifest, offline caching

**User Context:**
- Primary use case: quick idea capture while on-the-go
- Secondary use case: reviewing and organizing notes on desktop
- Expectation: zero friction from thought to saved note

**Known Challenges:**
- Android speech recognition permissions and background handling
- Offline/online state transitions and conflict resolution
- Web speech API vs native Android speech recognition
- PWA vs native app capability differences

## Constraints

- **Tech**: Flutter 3.x with Firebase backend — proven stack for rapid development
- **Timeline**: Single developer MVP — scope aggressively
- **Auth**: Firebase Auth only (no custom backend for v1)
- **Storage**: Firebase Cloud Firestore + local SQLite/Hive
- **Speech**: Device-native APIs (Android SpeechRecognizer, Web Speech API)
- **Offline**: Notes must save locally first, sync opportunistically

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter + Firebase | Single codebase for Android + Web, rapid development | — Pending |
| Local-first architecture | Core value requires offline functionality | — Pending |
| Plain text only | Speed and simplicity over formatting complexity | — Pending |
| PWA for desktop | Cross-platform web instead of separate desktop app | — Pending |

---
*Last updated: 2025-02-27 after initialization*
