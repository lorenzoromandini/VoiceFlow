# Technology Stack

**Project:** VoiceFlow Notes
**Domain:** Flutter cross-platform voice-first note-taking app (Android + Web)
**Researched:** 2025-02-27
**Overall Confidence:** HIGH

## Recommended Stack

### Core Framework

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter | 3.41.x | Cross-platform UI framework | Latest stable with full web support via WebAssembly, Impeller rendering engine, mature ecosystem |
| Dart | 3.6.x | Programming language | Required for Flutter 3.41, supports pattern matching, records, sealed classes |

### Firebase Backend

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| firebase_core | ^3.12.0 | Firebase SDK core | Required for all Firebase services, handles initialization |
| cloud_firestore | ^6.1.2 | Cloud database with sync | Native offline persistence on mobile, real-time sync, automatic conflict resolution |
| firebase_auth | ^6.1.4 | User authentication | Anonymous auth for guest users, social providers, email/password |
| firebase_analytics | ^4.0.5 | Usage analytics | Track voice recording usage, note creation patterns |

### Speech Recognition

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| speech_to_text | ^7.3.0 | Speech-to-text | Best Flutter STT plugin, supports Android/iOS/Web/macOS, real-time transcription, 1500+ likes |

### State Management

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| flutter_riverpod | ^3.2.1 | State management | Official successor to Provider, compile-safe, built-in async handling, Flutter Favorite |
| riverpod_annotation | ^3.2.1 | Code generation | Enables @riverpod decorators for cleaner syntax |

### Navigation

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| go_router | ^17.1.0 | Declarative routing | Official Flutter router, deep linking support, URL-based navigation for web, ShellRoute support |

### Local Storage

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| shared_preferences | ^2.5.4 | Simple settings | Flutter team maintained, async API with caching, perfect for user preferences |
| sqflite | ^2.4.2 | Complex local data | SQLite for Flutter, supports Android/iOS/macOS, transactions, migrations |

### Connectivity & Background Tasks

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| connectivity_plus | ^7.0.0 | Network state | Detect online/offline status, all platforms supported, Flutter Community maintained |
| workmanager | ^0.9.0+3 | Background sync | Schedule background tasks for sync when app closed, Android WorkManager + iOS BG Tasks |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| uuid | ^4.5.1 | UUID generation | Generate unique note IDs |
| intl | ^0.20.2 | Internationalization | Date formatting, relative time ("2 hours ago") |
| freezed_annotation | ^3.0.0 | Immutable models | Generate copyWith, toJson, fromJson |
| json_annotation | ^4.9.0 | JSON serialization | Type-safe JSON parsing |
| equatable | ^2.0.7 | Value equality | Compare objects by value not reference |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| flutter_lints | Linting | Official Flutter lint rules, enable in analysis_options.yaml |
| build_runner | Code generation | Required for Riverpod, Freezed code generation |
| flutterfire_cli | Firebase setup | `dart pub global activate flutterfire_cli` for project configuration |

## Installation

```bash
# Core dependencies
flutter pub add firebase_core cloud_firestore firebase_auth firebase_analytics

# Speech and UI
flutter pub add speech_to_text

# State management
flutter pub add flutter_riverpod riverpod_annotation

# Navigation
flutter pub add go_router

# Storage
flutter pub add shared_preferences sqflite

# Connectivity & background
flutter pub add connectivity_plus workmanager

# Utilities
flutter pub add uuid intl equatable json_annotation freezed_annotation

# Dev dependencies
flutter pub add --dev build_runner freezed riverpod_generator json_serializable flutter_lints
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| State Management | Riverpod | Bloc | Bloc requires more boilerplate; Riverpod has better async handling |
| State Management | Riverpod | Provider | Provider is legacy; Riverpod is compile-safe and more powerful |
| Local DB | sqflite | Hive | Hive is unmaintained (3 years since update), replaced by Isar; sqflite is Flutter Favorite |
| Local DB | sqflite | Isar | Isar is powerful but adds complexity; sqflite sufficient for notes app |
| Navigation | go_router | Navigator 1.0 | Navigator is imperative and harder to maintain; go_router supports deep links |
| Backend | Firebase | Supabase | Supabase is promising but Firebase has better offline support, more mature Flutter SDK |
| Auth | Firebase Auth | Auth0 | Firebase Auth has better offline handling and is free for basic usage |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **hive** (v2.2.3) | Last updated 3 years ago, superseded by Isar, no maintenance | sqflite for relational data, shared_preferences for simple settings |
| **flutter_bluetooth_serial** | Unmaintained, permission complexity | Not needed for this app |
| **moor/drift** | Overkill for simple note storage, adds complexity | sqflite is sufficient |
| **realtime_database** (Firebase) | Firestore has better querying, offline support, and is the modern choice | cloud_firestore |
| **GetX** | Not recommended by Flutter team, anti-patterns | Riverpod or Bloc |
| **Navigator 1.0** | Imperative API, hard to maintain | go_router (declarative) |

## Platform-Specific Considerations

### Android
- **Minimum SDK**: 21 (Android 5.0) - Required by speech_to_text
- **Target SDK**: 35 (Android 15)
- **Permissions**: RECORD_AUDIO, INTERNET, BLUETOOTH (for headset support)

### Web (PWA)
- **Compiler**: dart2wasm (WebAssembly) for production builds
- **Renderer**: Canvaskit for consistent rendering
- **STT Support**: Chrome, Edge, Safari (uses Web Speech API)
- **Offline**: Service worker for PWA, IndexedDB for local storage

### Desktop (Future)
- Windows and macOS supported via Flutter
- Speech recognition on Windows is in beta (speech_to_text 7.3.0+)

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| firebase_core ^3.12.0 | cloud_firestore ^6.x, firebase_auth ^6.x | Use FlutterFire CLI to keep versions aligned |
| flutter_riverpod ^3.2.1 | Dart ^3.0 | Requires Dart 3 for pattern matching |
| speech_to_text ^7.3.0 | Flutter ^3.10 | WASM support added in v7.0.0 |
| go_router ^17.1.0 | Flutter ^3.16 | Uses Router API (Navigation 2.0) |

## Architecture Pattern

**Recommended: Repository Pattern with Riverpod**

```
UI Layer (Widgets)
    ↕
State Layer (Riverpod Providers)
    ↕
Repository Layer (abstracts data sources)
    ↕
Data Sources (Firestore, Local DB, Cache)
```

This provides:
- Clear separation of concerns
- Testable architecture
- Easy to swap data sources
- Offline-first support via repository pattern

## Sources

- [Flutter 3.41 Release Notes](https://docs.flutter.dev/release/whats-new) - Flutter 3.41 "Year of the Fire Horse" (Feb 2026)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup) - Official Firebase Flutter integration
- [speech_to_text 7.3.0](https://pub.dev/packages/speech_to_text) - Verified publisher, 1500+ likes
- [Riverpod 3.2.1](https://pub.dev/packages/riverpod) - Flutter Favorite, official successor to Provider
- [cloud_firestore 6.1.2](https://pub.dev/packages/cloud_firestore) - Firebase official, offline persistence support
- [go_router 17.1.0](https://pub.dev/packages/go_router) - Flutter team maintained, declarative routing
- [Hive Status](https://pub.dev/packages/hive) - Last published 3 years ago, superseded by Isar
- [sqflite 2.4.2](https://pub.dev/packages/sqflite) - Flutter Favorite, SQLite plugin
- [connectivity_plus 7.0.0](https://pub.dev/packages/connectivity_plus) - Flutter Community, 4000+ likes
- [workmanager 0.9.0+3](https://pub.dev/packages/workmanager) - Background task scheduling

---
*Stack research for: VoiceFlow Notes - Voice-first note-taking app*
*Researched: 2025-02-27*
*Confidence: HIGH - All versions verified from official sources*
