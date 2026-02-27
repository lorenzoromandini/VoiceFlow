# Phase 1 Research: Project Setup & Architecture Foundation

## Research Date
2025-02-27

## Phase Goal
Developer has a runnable Flutter project with clean architecture, dependency injection, and local storage foundation ready for feature development.

---

## Key Research Findings

### 1. Flutter Project Initialization (2025 Best Practices)

**Current Stable Version:** Flutter 3.27.x (as of Feb 2025)

**Project Setup Approach:**
- Use `flutter create --org com.voiceflow notes` for proper package naming
- Enable null safety (default in Flutter 3.x)
- Configure for both Android and Web from the start
- Set up proper .gitignore and project structure

**Platform Configuration:**
- **Android:** Min SDK 21 (Android 5.0), target SDK 34
- **Web:** Enable web support with `flutter config --enable-web`
- Build runners: Gradle 8.x, Android SDK API 34

### 2. Clean Architecture for Flutter

**Recommended Pattern: Layered Architecture**

```
lib/
├── core/                    # Shared utilities, constants, errors
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── di/                  # Dependency injection setup
├── data/                    # Data layer
│   ├── datasources/         # Local DB, Remote API
│   ├── models/              # Data models (DTOs)
│   └── repositories/        # Repository implementations
├── domain/                  # Business logic
│   ├── entities/            # Core business objects
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business operations
├── presentation/            # UI layer
│   ├── blocs/               # State management (Riverpod)
│   ├── pages/               # Screens
│   └── widgets/             # Reusable UI components
└── main.dart
```

**Rationale:**
- Separation of concerns
- Testable business logic
- Swappable data sources (local ↔ cloud)
- Aligns with Flutter community best practices

### 3. Dependency Injection

**Recommendation: Riverpod 3.2.1**

**Why Riverpod over GetIt:**
- Compile-safe (no runtime errors from missing dependencies)
- Built-in support for async dependencies
- Scoped providers for feature isolation
- Excellent testing support with ProviderContainer
- Officially recommended by Flutter community

**Setup Pattern:**
```dart
// Global providers in core/di/
final databaseProvider = Provider<Database>((ref) => Database());

// Scoped providers per feature
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesRepositoryImpl(db);
});
```

### 4. Local Database: Isar vs sqflite

**Research Update (Feb 2025):**

**Isar 3.x** (Recommended for this project):
- ✅ Native Flutter (no platform channels)
- ✅ Full-text search built-in
- ✅ Type-safe with code generation
- ✅ Web support via IndexedDB
- ✅ Excellent performance
- ✅ Active maintenance

**sqflite 2.x:**
- ✅ Battle-tested, widely used
- ❌ No web support
- ❌ More boilerplate

**Decision:** Use Isar 3.x for local storage
- Supports the cross-platform requirement (Android + Web)
- Better developer experience with type safety
- FTS (Full Text Search) needed for NOTE-05 (search notes)

### 5. Error Handling Architecture

**Recommended Approach:**

```dart
// Core error types
abstract class AppException implements Exception {
  final String message;
  final String? code;
  AppException(this.message, {this.code});
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}
```

**User-Friendly Error Messages:**
- Technical errors → User-friendly translations
- Actionable next steps included
- Snackbar/toast integration for feedback

### 6. Project Configuration Files

**pubspec.yaml essentials:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State management
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^3.2.1
  
  # Navigation
  go_router: ^14.6.2
  
  # Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  
  # Firebase (pre-configure)
  firebase_core: ^3.9.0
  
  # Utilities
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.14
  riverpod_generator: ^3.2.1
  isar_generator: ^3.1.0
  freezed: ^2.5.7
  json_serializable: ^6.9.0
```

### 7. Build Configuration

**Android (android/app/build.gradle):**
```gradle
android {
    namespace "com.voiceflow.notes"
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

**Web (web/index.html):**
- Proper viewport meta tags
- PWA manifest setup (for Phase 5)
- Service worker placeholder

### 8. Development Workflow

**Code Generation:**
```bash
# Run code generators for Riverpod, Isar, Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch
```

**Build Commands:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release
```

---

## Technical Decisions for Phase 1

### Locked Decisions

1. **Architecture:** Layered (Data/Domain/Presentation)
   - *Rationale:* Clear separation, testable, scalable

2. **State Management:** Riverpod 3.2.1
   - *Rationale:* Compile-safe, async support, testing

3. **Local Database:** Isar 3.1.0
   - *Rationale:* Web support, FTS, type-safe, performance

4. **Navigation:** go_router 14.6.2
   - *Rationale:* Official Flutter team, declarative, deep linking

### Claude's Discretion

1. **DI Setup Pattern:** Single file vs multiple feature files
   - *Recommendation:* Start single file, split when grows

2. **Error Handler:** Global vs per-feature
   - *Recommendation:* Global handler with feature-specific extensions

3. **Folder Depth:** Flat vs deeply nested
   - *Recommendation:* Medium depth (lib/{feature}/{layer}/)

---

## Implementation Risks & Mitigations

### Risk: Code Generation Complexity
**Mitigation:** Document build_runner commands clearly, CI check for generated files

### Risk: Isar Web Support
**Mitigation:** Test web build early in Phase 1, not defer to Phase 5

### Risk: Riverpod Learning Curve
**Mitigation:** Start with simple Provider pattern, add StateNotifier later

### Risk: Architecture Over-Engineering
**Mitigation:** Keep usecases lightweight initially, expand as needed

---

## Dependencies Summary

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| flutter_riverpod | ^3.2.1 | State management | HIGH |
| go_router | ^14.6.2 | Navigation | HIGH |
| isar | ^3.1.0 | Local database | HIGH |
| isar_flutter_libs | ^3.1.0 | Isar native libs | HIGH |
| firebase_core | ^3.9.0 | Firebase foundation | HIGH |
| build_runner | ^2.4.14 | Code generation | HIGH |
| riverpod_generator | ^3.2.1 | Riverpod codegen | HIGH |
| isar_generator | ^3.1.0 | Isar codegen | HIGH |

---

## Open Questions

1. **CI/CD:** Do we set up GitHub Actions in Phase 1 or later?
   - *Recommendation:* Basic build check in Phase 1, full CI in Phase 6

2. **Testing:** How much test coverage in Phase 1?
   - *Recommendation:* Unit tests for repository layer, widget tests optional

3. **Linting:** Which lint rules to enable?
   - *Recommendation:* flutter_lints package + custom rules

---

## References

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Riverpod Documentation](https://riverpod.dev/)
- [Isar Documentation](https://isar.dev/)
- [go_router Documentation](https://pub.dev/packages/go_router)

---

*Research completed: 2025-02-27*
*Ready for planning phase*
