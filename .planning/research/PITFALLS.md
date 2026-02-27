# Domain Pitfalls: Flutter Offline-First Voice Notes App

**Domain:** Flutter + Firebase offline-first note-taking with speech-to-text
**Researched:** 2026-02-27
**Overall confidence:** MEDIUM

## Critical Pitfalls

Mistakes that cause rewrites or major issues.

### Pitfall 1: Firebase Firestore as Primary Offline Storage

**What goes wrong:**
Developers assume Firestore's offline persistence is sufficient for local-first note storage. When the app goes offline, notes appear to save but sync conflicts arise when connectivity returns, causing data loss or duplication. The 1MB document size limit also causes crashes when embedding audio metadata.

**Why it happens:**
- Firestore offline persistence is a cache, not primary storage
- Default Firestore SDK behavior auto-syncs on reconnect, conflicting with custom sync logic
- Document size limits are hit with rich note content (images, audio transcripts)
- Firestore doesn't handle offline-first CRDTs (Conflict-free Replicated Data Types) natively

**How to avoid:**
- Use a local database (hive, sqflite, or objectbox) as source of truth
- Treat Firestore as sync target, not primary store
- Implement explicit sync layer with conflict resolution (last-write-wins or custom merge)
- Keep Firestore documents small; store audio references, not base64 content
- Use `enablePersistence()` with `synchronizeTabs: true` for web, but don't rely on it for critical data

**Warning signs:**
- Notes disappearing after reconnection
- Duplicate entries appearing after offline usage
- "Maximum document size exceeded" errors in production
- Users reporting inconsistent data between devices

**Phase to address:** Phase 1 (Architecture & Storage)

---

### Pitfall 2: Assuming Speech-to-Text Works Offline

**What goes wrong:**
The `speech_to_text` package requires internet connectivity on most platforms. When users try to dictate notes offline, recognition fails silently or returns errors. Android has limited offline speech recognition that varies by device, while iOS and web require network.

**Why it happens:**
- `speech_to_text` uses platform APIs (Android SpeechRecognizer, iOS SFSpeechRecognizer, Web Speech API)
- These APIs delegate to cloud services by default
- Android offline models vary by manufacturer and OS version
- No cross-platform offline speech recognition solution exists in Flutter ecosystem

**How to avoid:**
- Check connectivity before enabling speech-to-text
- Provide clear UI feedback: "Speech recognition requires internet"
- On Android, detect and prompt users to install offline language packs
- Consider alternative: record audio locally, transcribe when online (with `record` + Whisper API)
- Implement fallback: allow recording without transcription, process later

**Warning signs:**
- "Speech recognition unavailable" errors on certain devices
- Silent failures during dictation
- Users reporting speech works on WiFi but not mobile data (carrier blocking)

**Phase to address:** Phase 2 (Voice Input)

---

### Pitfall 3: Platform Channel Dependencies Breaking Web Build

**What goes wrong:**
Many Flutter plugins use platform channels (Android/iOS native code) and fail to compile for web. The speech-to-text plugin works on web but requires different initialization. Audio recording plugins often don't support web at all.

**Why it happens:**
- Flutter web uses different architecture (no platform channels to native code)
- Plugins must explicitly implement web support using dart:html or package:web
- Conditional imports (`dart.library.html`) required for web-specific code
- Plugin availability varies: some features work on mobile only

**How to avoid:**
- Check plugin pub.dev page for web support before adoption
- Use conditional imports and stub implementations for web
- Test web build early and continuously (`flutter build web`)
- Prefer pure-Dart plugins where possible
- Maintain platform-specific service layers with common interface

**Warning signs:**
- Build errors like "MissingPluginException" when running on web
- Plugins listed as "unavailable" in pubspec.lock for web
- Import errors for dart:io in web builds

**Phase to address:** Phase 0 (Setup & Architecture)

---

### Pitfall 4: PWA Service Worker Cache Breaking Updates

**What goes wrong:**
Flutter web PWA caches aggressively. Users see old versions of the app even after deployment. New features don't appear, or worse, cached code tries to access new API endpoints causing errors.

**Why it happens:**
- Flutter's service worker precaches all assets by default
- Browsers cache service workers themselves
- Cache-first strategy means old versions persist
- No automatic cache invalidation on new builds

**How to avoid:**
- Configure `flutter_service_worker.js` with proper cache strategies
- Use versioned URLs for main.dart.js (via build config)
- Implement manual update check with `flutter update` pattern
- Consider skipWaiting in service worker for immediate activation
- Add "Update Available" UI with force refresh option

**Warning signs:**
- Users reporting old UI after "update"
- JavaScript errors from version mismatches
- Staging changes appearing in production

**Phase to address:** Phase 4 (Web/PWA Deployment)

---

### Pitfall 5: Real-time Sync Without Conflict Resolution

**What goes wrong:**
Using Firestore's real-time listeners without handling concurrent edits causes last-write-wins behavior, silently discarding user changes. When user edits same note on two devices, one edit disappears.

**Why it happens:**
- Firestore `onSnapshot` listeners receive updates automatically
- No built-in conflict detection in standard Firestore usage
- Local state can be overwritten by remote changes mid-edit
- No operational transform or CRDT implementation by default

**How to avoid:**
- Implement local-first architecture: edit local copy, sync explicitly
- Use Firestore transactions for atomic updates with version checks
- Implement custom merge strategies for specific fields
- Disable real-time sync during active editing (manual sync on save)
- Consider operational transform libraries for collaborative features

**Warning signs:**
- Edits "reverting" while typing
- Notes losing content when switching devices
- Concurrent modification exceptions in logs

**Phase to address:** Phase 3 (Sync Implementation)

---

### Pitfall 6: Audio Permission Handling Across Platforms

**What goes wrong:**
Speech-to-text and audio recording require microphone permissions. Handling these inconsistently across Android, iOS, and web leads to app crashes or silent failures. Web permission model is async and browser-dependent.

**Why it happens:**
- Android: `RECORD_AUDIO`, `INTERNET`, `BLUETOOTH` permissions required
- iOS: `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription` in Info.plist
- Web: getUserMedia API requires secure context (HTTPS) and user gesture
- Permission status queries work differently per platform

**How to avoid:**
- Use `permission_handler` plugin for unified permission API
- Always check permission before initializing speech/recording
- Handle permission denied gracefully with explanatory UI
- On web, ensure HTTPS and trigger permission from user action
- Test permission flows on physical devices (simulators behave differently)

**Warning signs:**
- App crashes on first launch on iOS
- Black screen when starting recording on web
- "Permission denied" in logs without UI handling

**Phase to address:** Phase 2 (Voice Input)

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Using Firestore directly in UI widgets | Faster development, real-time updates | Tight coupling, impossible to unit test, sync logic scattered | Never for production; use repository pattern |
| Storing audio as base64 in Firestore | Simple sync | Hits 1MB limit, massive bandwidth usage, slow sync | Never; use Firebase Storage with references |
| `setState` for app-wide state | No dependencies | Rebuilds entire widget tree, performance issues, state loss on navigation | Only for ephemeral widget state |
| Skipping web testing | Faster iteration | Plugins incompatible, PWA issues discovered late | Never; test web from day 1 |
| Platform-specific code without abstraction | Direct native API access | Code duplication, testing nightmare, maintenance burden | Only when absolutely necessary |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Firebase Auth | Using anonymous auth without linking | Always link anonymous to permanent account before critical data |
| Firestore | Listening to entire collections | Query with limits, use pagination, unsubscribe when not needed |
| Speech-to-text | Not handling "not listening" state | Check `isNotListening` before calling listen() again |
| Firebase Storage | Storing files in root | Use user-scoped paths (e.g., `/users/{uid}/audio/{file}`) |
| Flutter Web | Using dart:io imports | Use conditional imports: `dart.library.io` vs `dart.library.html` |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading all notes into memory | App freezes, OOM crashes | Pagination, lazy loading, local database indexing | >100 notes |
| Rebuilding entire list on single note change | Jank, battery drain | Use `ListView.builder`, key widgets properly, diff algorithms | >50 notes |
| Synchronous Firestore writes | UI freezes | Use transactions with `await`, show loading states | Any network latency |
| No audio compression | Slow uploads, storage bloat | Compress to AAC/Opus before upload, limit duration | First audio note |
| Querying without Firestore indexes | Slow queries, timeout errors | Create composite indexes in Firebase Console | Complex queries |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Client-side Firestore rules only | Data breaches, unauthorized access | Always validate in Security Rules, use request.auth |
| Storing user data by device ID | Data loss on reinstall, no cross-device sync | Use Firebase Auth UID as document key |
| Not validating audio file types | Malware upload, storage abuse | Validate MIME types, scan uploads, size limits |
| Exposing Firestore API keys | Abuse, quota exhaustion | API keys are public by design; use App Check, rate limits |
| Storing sensitive notes unencrypted | Privacy violation | Encrypt sensitive content client-side before Firestore |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No offline indicator | User thinks app is broken when offline | Clear connectivity status, queue actions visibly |
| Speech timeout too short | Frustrating restarts during pauses | Configure listen duration, show visual feedback |
| Auto-sync without user control | Data surprises, overwrites | Manual sync button, sync status indicator, conflict resolution UI |
| No audio playback in transcript | Can't verify dictation accuracy | Inline audio player per note segment |
| Lost work on app background | Frustration, data loss | Auto-save drafts, restore on resume |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Offline notes:** Can users create, edit, and view notes without connectivity? — Test with airplane mode
- [ ] **Sync conflict handling:** What happens when same note edited on two devices? — Verify merge strategy
- [ ] **Speech error handling:** Does app recover gracefully from "Speech recognition unavailable"? — Test on devices without Google app
- [ ] **Web microphone permissions:** Does web version request mic access properly? — Requires HTTPS and user gesture
- [ ] **PWA install:** Can users add to home screen and launch offline? — Test "Add to Home Screen" flow
- [ ] **Audio storage cleanup:** Are orphaned audio files deleted when notes are deleted? — Check Firebase Storage
- [ ] **Cross-platform sync:** Do notes created on Android appear on web? — Test device switching
- [ ] **Large note handling:** Does app handle 10-minute dictation without freezing? — Test performance
- [ ] **Background audio:** Does recording continue if user switches apps? — Test on iOS (requires background mode)
- [ ] **Accessibility:** Are all features usable with screen readers? — Test with TalkBack/VoiceOver

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Firestore data corruption | HIGH | Export affected collections, write merge script, restore from backup |
| Web build broken by plugin | MEDIUM | Find alternative plugin, fork and fix, or stub the feature on web |
| PWA cache issues | LOW | Clear site data in browser, update service worker with skipWaiting |
| Sync conflicts in production | MEDIUM | Implement server-side reconciliation, notify affected users |
| Permission denial pattern | LOW | Add in-app guidance, deep link to system settings |

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Phase 0: Setup | Plugin web compatibility | Test `flutter build web` immediately after adding each plugin |
| Phase 1: Local Storage | Using Firestore directly | Implement repository pattern with local DB first |
| Phase 2: Voice Input | Assuming offline STT | Design for online-only STT with audio recording fallback |
| Phase 3: Sync | Last-write-wins conflicts | Implement version vectors or timestamps with conflict UI |
| Phase 4: Web/PWA | Service worker caching | Configure cache strategy, implement update mechanism |
| Phase 5: Polish | Missing accessibility | Test with screen readers from beginning |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Firestore as primary storage | Phase 1 | Verify notes exist after app reinstall, offline creation works |
| Speech offline assumption | Phase 2 | Test airplane mode dictation, verify audio fallback |
| Platform channel web breakage | Phase 0 | `flutter build web` succeeds, features work in browser |
| PWA cache issues | Phase 4 | Deploy update, verify new version loads, check service worker |
| Real-time sync conflicts | Phase 3 | Concurrent editing test, verify merge or conflict UI |
| Audio permissions | Phase 2 | Deny permission during testing, verify graceful degradation |

## Sources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices) - Official Flutter documentation
- [speech_to_text Package Documentation](https://pub.dev/packages/speech_to_text) - Pub.dev package info and troubleshooting
- [Firebase Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices) - Official Firebase documentation
- [Firebase Firestore Offline Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline) - Firebase official docs
- [Flutter Web Building Guide](https://docs.flutter.dev/platform-integration/web/building) - Official Flutter web docs
- [Flutter State Management Options](https://docs.flutter.dev/data-and-backend/state-mgmt/options) - Official Flutter architecture guidance
- [Add Firebase to Flutter App](https://firebase.google.com/docs/flutter/setup) - Firebase official setup guide

---
*Pitfalls research for: VoiceFlow Notes — Flutter offline-first voice note-taking app*
*Researched: 2026-02-27*
*Confidence: MEDIUM — Based on official documentation and package READMEs. WebSearch validation recommended for community-reported edge cases.*
