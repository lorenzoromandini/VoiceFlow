# Feature Landscape

**Domain:** Voice-first note-taking app (Android + Web PWA)
**Researched:** 2026-02-27
**Confidence:** HIGH

## Table Stakes

Features users expect. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **One-tap recording** | Core voice capture experience | LOW | Primary CTA must be instantly accessible |
| **Real-time transcription** | Live text feedback while speaking | MEDIUM | Uses platform speech-to-text APIs (Android SpeechRecognizer, Web Speech API) |
| **Note list view** | Browse and access saved notes | LOW | Chronological with search/filter |
| **Edit transcription** | Fix recognition errors | LOW | Essential for accuracy |
| **Delete notes** | Manage storage and mistakes | LOW | With confirmation to prevent accidents |
| **Local persistence** | Notes survive app restart | LOW | sqflite (Android) + localStorage/indexedDB (Web) |
| **Audio playback** | Listen to original recording | MEDIUM | Critical for verification and context |
| **Timestamp display** | Know when note was created | LOW | Essential for organization |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Cross-platform sync** | Seamless Android ↔ Web experience | MEDIUM | Cloud sync when logged in, offline-first |
| **PWA desktop support** | Use on desktop without install | MEDIUM | Web app as installable PWA |
| **Minimalist UX** | Zero friction, no cognitive load | LOW | Clean UI, gesture-based interactions |
| **Quick capture widget/shortcut** | Capture without opening full app | MEDIUM | Android home screen widget, Web shortcut |
| **Search within transcriptions** | Find old notes by content | MEDIUM | Full-text search across all notes |
| **Auto-save drafts** | Never lose partial recordings | LOW | Save on interrupt, background, or timeout |
| **Dark/light theme** | Comfortable in any lighting | LOW | System-aware theme switching |
| **Export (txt/md)** | Portability of notes | LOW | Share as text or markdown |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Rich text formatting** | Adds complexity, voice notes are quick thoughts | Plain text with optional markdown export |
| **Collaboration/sharing** | Not core use case, adds auth complexity | Export to share externally |
| **Tags/folders** | Over-engineering for MVP; search is sufficient | Flat list with search; add later if needed |
| **Video recording** | Scope creep, different product | Audio-only focus |
| **In-app purchases** | Open source, no monetization | Optional cloud sync via self-hosted or free tier |
| **Real-time collaboration** | Massive complexity, not needed | Individual notes with export |
| **Custom ML transcription** | Too expensive, platform APIs are good enough | Use built-in platform STT |
| **Audio effects/filters** | Not a voice memo app | Raw audio preservation |

## Feature Dependencies

```
Core Recording
    └──requires──> Audio Permission
    └──requires──> Microphone Access
    └──requires──> Local Storage

Real-time Transcription
    └──requires──> Core Recording
    └──requires──> Speech Recognition (Platform API)

Cloud Sync
    └──requires──> User Authentication
    └──requires──> Core Recording
    └──requires──> Local Storage (offline-first)

Search
    └──requires──> Local Storage
    └──enhances──> Real-time Transcription

Cross-Platform
    └──requires──> Cloud Sync
    └──requires──> Consistent Data Format
```

### Dependency Notes

- **Speech Recognition requires Core Recording:** Cannot transcribe without audio input
- **Cloud Sync requires Auth:** Need user identity for cloud storage
- **Search enhances Transcription:** Only useful if text is captured
- **Cross-Platform requires Sync:** Data must sync between Android and Web

## MVP Recommendation

### Phase 1: Core Experience (Table Stakes)

**Prioritize:**
1. **One-tap recording** — Essential for voice-first experience
2. **Real-time transcription** — Differentiator from basic voice memos
3. **Local persistence** — Notes must survive app restarts
4. **Note list + basic management** — View, edit, delete
5. **Audio playback** — Critical for transcription verification

**Defer:**
- Cloud sync: Add after local experience is solid
- PWA desktop: Web support is secondary to Android
- Advanced search: Flat list works for initial launch
- Export: Not needed for MVP validation

### Phase 2: Cross-Platform (Differentiators)

**Add after validation:**
1. **Cloud sync** — Enable Web ↔ Android flow
2. **User authentication** — Google Sign-In (simplest for Flutter)
3. **PWA install** — Desktop access
4. **Search** — Full-text across transcriptions

### Phase 3: Polish

**Future consideration:**
- Quick capture widget
- Export functionality
- Themes beyond system default
- Auto-save drafts refinements

## Complexity Assessment

| Feature | Android | Web | Sync Complexity |
|---------|---------|-----|-----------------|
| Recording | LOW | MEDIUM (Web APIs) | N/A |
| Transcription | LOW (STT built-in) | MEDIUM (Web Speech API) | N/A |
| Local Storage | LOW (sqflite) | LOW (localStorage/IndexedDB) | HIGH |
| Auth | LOW (google_sign_in) | LOW (Firebase Auth) | MEDIUM |
| Cloud Sync | MEDIUM (Firebase) | MEDIUM (Firestore) | HIGH |
| PWA | N/A | MEDIUM | N/A |

**Highest Complexity:**
- Cross-platform data synchronization
- Offline-first architecture (sync when online)
- Web Speech API browser compatibility (Chrome/Edge only)

## Sources

- [Otter.ai Features](https://otter.ai/features) — Professional transcription app features
- [Apple Voice Memos](https://support.apple.com/guide/voice-memos/) — Native voice memo baseline
- [Flutter speech_to_text package](https://pub.dev/packages/speech_to_text) — Flutter STT capabilities
- [sqflite package](https://pub.dev/packages/sqflite) — Local database for Android
- [Hive package](https://pub.dev/packages/hive) — Lightweight local storage alternative
- [Drift package](https://pub.dev/packages/drift) — Cross-platform persistence
- [Flutter Multi-platform](https://flutter.dev/multi-platform) — Platform capabilities
- [Google Sign-In](https://pub.dev/packages/google_sign_in) — Auth implementation
- [Firebase Core](https://pub.dev/packages/firebase_core) — Cloud sync infrastructure

---
*Feature research for: VoiceFlow Notes — Flutter voice note-taking app*
*Researched: 2026-02-27*
