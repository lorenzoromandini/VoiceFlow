# Phase 1 Plan: Project Setup & Architecture Foundation

**Phase:** 1 - Project Setup & Architecture Foundation  
**Goal:** Developer has a runnable Flutter project with clean architecture, dependency injection, and local storage foundation ready for feature development.

---

## Plan Overview

| Plan ID | Name | Wave | Est. Time | Autonomous |
|---------|------|------|-----------|------------|
| 01-01 | Initialize Flutter Project | 1 | 15 min | Yes |
| 01-02 | Configure Dependencies & Build | 1 | 20 min | Yes |
| 01-03 | Setup Architecture Layers | 2 | 30 min | Yes |
| 01-04 | Configure Dependency Injection | 2 | 20 min | Yes |
| 01-05 | Setup Isar Local Database | 3 | 30 min | Yes |
| 01-06 | Implement Error Handling | 3 | 20 min | Yes |
| 01-07 | Build APK & Verify | 4 | 15 min | Yes |

**Total Plans:** 7  
**Total Est. Time:** ~2.5 hours  
**Waves:** 4

---

## Wave 1: Project Foundation (35 min)

### Plan 01-01: Initialize Flutter Project

**Task:** Create Flutter project with proper structure

```xml
<task>
  <action>Create Flutter project</action>
  <command>flutter create --org com.voiceflow --project-name voiceflow_notes voiceflow_notes</command>
  <cwd>/home/lromandini/projects/note-app</cwd>
</task>

<task>
  <action>Enable web support</action>
  <command>flutter config --enable-web</command>
</task>

<task>
  <action>Navigate to project</action>
  <command>cd voiceflow_notes</command>
</task>

<task>
  <action>Verify structure</action>
  <command>ls -la lib/</command>
  <verify>Contains main.dart and empty directories</verify>
</task>
```

**Files Modified:**
- `voiceflow_notes/` (entire project)

**Must Haves for Success:**
- [ ] Project creates without errors
- [ ] `flutter doctor` shows no critical issues
- [ ] `flutter run` launches on Android emulator

---

### Plan 01-02: Configure Dependencies & Build

**Task:** Add packages to pubspec.yaml and configure build runners

```xml
<task>
  <action>Update pubspec.yaml dependencies</action>
  <edit file="pubspec.yaml">
    <dependencies>
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
      
      # Firebase
      firebase_core: ^3.9.0
      
      # Utilities
      equatable: ^2.0.5
      freezed_annotation: ^2.4.1
      json_annotation: ^4.9.0
      uuid: ^4.5.1
    </dependencies>
    
    <dev_dependencies>
      flutter_test:
        sdk: flutter
      flutter_lints: ^5.0.0
      build_runner: ^2.4.14
      riverpod_generator: ^3.2.1
      isar_generator: ^3.1.0
      freezed: ^2.5.7
      json_serializable: ^6.9.0
    </dev_dependencies>
  </edit>
</task>

<task>
  <action>Get dependencies</action>
  <command>flutter pub get</command>
  <verify>No errors in dependency resolution</verify>
</task>

<task>
  <action>Create analysis_options.yaml</action>
  <write file="analysis_options.yaml">
    include: package:flutter_lints/flutter.yaml

    linter:
      rules:
        prefer_single_quotes: true
        prefer_const_constructors: true
        prefer_final_locals: true
        avoid_print: true
        prefer_relative_imports: true
  </write>
</task>

<task>
  <action>Configure Android build</action>
  <edit file="android/app/build.gradle">
    android {
        namespace "com.voiceflow.voiceflow_notes"
        compileSdk 34
        
        defaultConfig {
            minSdk 21
            targetSdk 34
            versionCode 1
            versionName "1.0.0"
        }
    }
  </edit>
</task>
```

**Files Modified:**
- `pubspec.yaml`
- `analysis_options.yaml`
- `android/app/build.gradle`

**Must Haves for Success:**
- [ ] `flutter pub get` completes successfully
- [ ] No dependency conflicts
- [ ] Android build configuration updated

---

## Wave 2: Architecture Setup (50 min)

### Plan 01-03: Setup Architecture Layers

**Task:** Create clean architecture folder structure

```xml
<task>
  <action>Create architecture directories</action>
  <commands>
    mkdir -p lib/core/{constants,errors,utils,di}
    mkdir -p lib/data/{datasources,models,repositories}
    mkdir -p lib/domain/{entities,repositories,usecases}
    mkdir -p lib/presentation/{providers,pages,widgets}
  </commands>
</task>

<task>
  <action>Create core error classes</action>
  <write file="lib/core/errors/app_exception.dart">
    abstract class AppException implements Exception {
      final String message;
      final String? code;
      final StackTrace? stackTrace;
      
      const AppException(this.message, {this.code, this.stackTrace});
      
      @override
      String toString() => '[$code] $message';
    }

    class DatabaseException extends AppException {
      const DatabaseException(super.message, {super.code, super.stackTrace});
    }

    class NetworkException extends AppException {
      const NetworkException(super.message, {super.code, super.stackTrace});
    }

    class ValidationException extends AppException {
      const ValidationException(super.message, {super.code, super.stackTrace});
    }
  </write>
</task>

<task>
  <action>Create result wrapper</action>
  <write file="lib/core/utils/result.dart">
    import 'package:voiceflow_notes/core/errors/app_exception.dart';

    sealed class Result<T> {
      const Result();
      
      bool get isSuccess => this is Success<T>;
      bool get isFailure => this is Failure<T>;
      
      T? get value => switch (this) {
        Success<T>(value: final v) => v,
        _ => null,
      };
      
      AppException? get error => switch (this) {
        Failure<T>(error: final e) => e,
        _ => null,
      };
    }

    class Success<T> extends Result<T> {
      final T value;
      const Success(this.value);
    }

    class Failure<T> extends Result<T> {
      final AppException error;
      const Failure(this.error);
    }
  </write>
</task>

<task>
  <action>Create usecase base class</action>
  <write file="lib/domain/usecases/usecase.dart">
    import 'package:voiceflow_notes/core/utils/result.dart';

    abstract class UseCase<Type, Params> {
      Future<Result<Type>> call(Params params);
    }

    class NoParams {
      const NoParams();
    }
  </write>
</task>
```

**Files Modified:**
- `lib/core/errors/app_exception.dart`
- `lib/core/utils/result.dart`
- `lib/domain/usecases/usecase.dart`
- Multiple directory structures

**Must Haves for Success:**
- [ ] All directories created
- [ ] Core error classes defined
- [ ] Result wrapper for error handling
- [ ] UseCase base class ready

---

### Plan 01-04: Configure Dependency Injection

**Task:** Setup Riverpod with provider structure

```xml
<task>
  <action>Create DI configuration file</action>
  <write file="lib/core/di/providers.dart">
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    
    // Core providers will be added here
    // Example: final databaseProvider = Provider<Database>((ref) => Database());
  </write>
</task>

<task>
  <action>Update main.dart with Riverpod</action>
  <write file="lib/main.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/presentation/app.dart';

    void main() {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const ProviderScope(child: VoiceFlowApp()));
    }
  </write>
</task>

<task>
  <action>Create root App widget</action>
  <write file="lib/presentation/app.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    class VoiceFlowApp extends ConsumerWidget {
      const VoiceFlowApp({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        return MaterialApp(
          title: 'VoiceFlow Notes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Center(
              child: Text('VoiceFlow Notes - Ready to build'),
            ),
          ),
        );
      }
    }
  </write>
</task>

<task>
  <action>Test Riverpod setup</action>
  <command>flutter analyze</command>
  <verify>No errors related to Riverpod or imports</verify>
</task>
```

**Files Modified:**
- `lib/core/di/providers.dart`
- `lib/main.dart`
- `lib/presentation/app.dart`

**Must Haves for Success:**
- [ ] Riverpod ProviderScope wraps app
- [ ] No import errors
- [ ] App runs without errors

---

## Wave 3: Database & Error Handling (50 min)

### Plan 01-05: Setup Isar Local Database

**Task:** Configure Isar with Note entity

```xml
<task>
  <action>Create Note entity</action>
  <write file="lib/domain/entities/note.dart">
    import 'package:equatable/equatable.dart';

    class Note extends Equatable {
      final String id;
      final String title;
      final String content;
      final DateTime createdAt;
      final DateTime updatedAt;
      final bool isSynced;

      const Note({
        required this.id,
        required this.title,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
        this.isSynced = false,
      });

      Note copyWith({
        String? id,
        String? title,
        String? content,
        DateTime? createdAt,
        DateTime? updatedAt,
        bool? isSynced,
      }) {
        return Note(
          id: id ?? this.id,
          title: title ?? this.title,
          content: content ?? this.content,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          isSynced: isSynced ?? this.isSynced,
        );
      }

      @override
      List<Object?> get props => [id, title, content, createdAt, updatedAt, isSynced];
    }
  </write>
</task>

<task>
  <action>Create Isar Note model</action>
  <write file="lib/data/models/isar_note_model.dart">
    import 'package:isar/isar.dart';
    import 'package:voiceflow_notes/domain/entities/note.dart';

    part 'isar_note_model.g.dart';

    @collection
    class IsarNoteModel {
      Id id = Isar.autoIncrement;
      
      @Index(unique: true, replace: true)
      late String uuid;
      
      late String title;
      late String content;
      late DateTime createdAt;
      late DateTime updatedAt;
      late bool isSynced;

      Note toEntity() => Note(
        id: uuid,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: isSynced,
      );

      static IsarNoteModel fromEntity(Note note) => IsarNoteModel()
        ..uuid = note.id
        ..title = note.title
        ..content = note.content
        ..createdAt = note.createdAt
        ..updatedAt = note.updatedAt
        ..isSynced = note.isSynced;
    }
  </write>
</task>

<task>
  <action>Create database service</action>
  <write file="lib/data/datasources/local_database.dart">
    import 'package:isar/isar.dart';
    import 'package:path_provider/path_provider.dart';
    import 'package:voiceflow_notes/data/models/isar_note_model.dart';

    class LocalDatabase {
      late final Isar _isar;
      
      Isar get isar => _isar;

      Future<void> initialize() async {
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [IsarNoteModelSchema],
          directory: dir.path,
        );
      }

      Future<void> close() async {
        await _isar.close();
      }
    }
  </write>
</task>

<task>
  <action>Add database provider</action>
  <edit file="lib/core/di/providers.dart">
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/data/datasources/local_database.dart';

    final localDatabaseProvider = Provider<LocalDatabase>((ref) {
      return LocalDatabase();
    });
  </edit>
</task>

<task>
  <action>Initialize database on app start</action>
  <edit file="lib/main.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/core/di/providers.dart';
    import 'package:voiceflow_notes/presentation/app.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      
      final container = ProviderContainer();
      final db = container.read(localDatabaseProvider);
      await db.initialize();
      
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const VoiceFlowApp(),
        ),
      );
    }
  </edit>
</task>

<task>
  <action>Run code generation</action>
  <command>flutter pub run build_runner build --delete-conflicting-outputs</command>
  <verify>isar_note_model.g.dart is created</verify>
</task>
```

**Files Modified:**
- `lib/domain/entities/note.dart`
- `lib/data/models/isar_note_model.dart`
- `lib/data/datasources/local_database.dart`
- `lib/core/di/providers.dart`
- `lib/main.dart`

**Must Haves for Success:**
- [ ] Isar code generation runs successfully
- [ ] Database initializes without errors
- [ ] Note model has all required fields

---

### Plan 01-06: Implement Error Handling

**Task:** Create error handling infrastructure

```xml
<task>
  <action>Create error handler</action>
  <write file="lib/core/utils/error_handler.dart">
    import 'package:flutter/material.dart';
    import 'package:voiceflow_notes/core/errors/app_exception.dart';

    class ErrorHandler {
      static String getUserFriendlyMessage(AppException error) {
        return switch (error) {
          DatabaseException() => 'Unable to save your note. Please try again.',
          NetworkException() => 'No internet connection. Your note is saved locally.',
          ValidationException() => error.message,
          _ => 'Something went wrong. Please try again.',
        };
      }

      static void showError(BuildContext context, AppException error) {
        final message = getUserFriendlyMessage(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  </write>
</task>

<task>
  <action>Create async operation wrapper</action>
  <write file="lib/core/utils/async_handler.dart">
    import 'dart:developer';
    import 'package:voiceflow_notes/core/errors/app_exception.dart';
    import 'package:voiceflow_notes/core/utils/result.dart';

    typedef AsyncOperation<T> = Future<T> Function();

    class AsyncHandler {
      static Future<Result<T>> execute<T>(
        AsyncOperation<T> operation, {
        String? operationName,
      }) async {
        try {
          final result = await operation();
          return Success(result);
        } on AppException catch (e, stackTrace) {
          log(
            'AppException in ${operationName ?? 'operation'}: ${e.message}',
            error: e,
            stackTrace: stackTrace,
          );
          return Failure(e);
        } catch (e, stackTrace) {
          log(
            'Unexpected error in ${operationName ?? 'operation'}: $e',
            error: e,
            stackTrace: stackTrace,
          );
          return Failure(
            AppException(
              'An unexpected error occurred',
              code: 'UNKNOWN_ERROR',
              stackTrace: stackTrace,
            ),
          );
        }
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/core/utils/error_handler.dart`
- `lib/core/utils/async_handler.dart`

**Must Haves for Success:**
- [ ] Error handler provides user-friendly messages
- [ ] Async handler wraps operations with Result type
- [ ] Errors are logged for debugging

---

## Wave 4: Verification (15 min)

### Plan 01-07: Build APK & Verify

**Task:** Build APK and verify everything works

```xml
<task>
  <action>Run static analysis</action>
  <command>flutter analyze</command>
  <verify>No critical errors</verify>
</task>

<task>
  <action>Build APK</action>
  <command>flutter build apk --debug</command>
  <verify>Build succeeds, APK exists at build/app/outputs/flutter-apk/app-debug.apk</verify>
</task>

<task>
  <action>Test web build</action>
  <command>flutter build web</command>
  <verify>Build succeeds, web build exists at build/web/</verify>
</task>

<task>
  <action>Verify project structure</action>
  <commands>
    echo "=== Project Structure ==="
    tree lib/ -L 3 || find lib/ -type d | head -20
    
    echo "=== Generated Files ==="
    ls -la lib/data/models/*.g.dart 2>/dev/null || echo "No generated files found"
    
    echo "=== Key Files Exist ==="
    test -f lib/main.dart && echo "✓ main.dart"
    test -f lib/presentation/app.dart && echo "✓ app.dart"
    test -f lib/core/di/providers.dart && echo "✓ providers.dart"
    test -f lib/data/datasources/local_database.dart && echo "✓ local_database.dart"
    test -f lib/domain/entities/note.dart && echo "✓ note.dart"
  </commands>
</task>
```

**Files Modified:** None (verification only)

**Must Haves for Success:**
- [ ] `flutter analyze` passes with no errors
- [ ] `flutter build apk` completes successfully
- [ ] `flutter build web` completes successfully
- [ ] All key files exist
- [ ] No compilation errors

---

## Verification Criteria

### Phase Success Criteria (from ROADMAP)
All must be met:

- [ ] `flutter run` launches app successfully on Android emulator/device
- [ ] Clean architecture layers established (Data/Domain/Presentation)
- [ ] Dependency injection configured and working (Riverpod)
- [ ] Local database schema created and migrations working
- [ ] Basic error handling shows user-friendly messages
- [ ] Project builds APK without errors

### Technical Verification

- [ ] Architecture directories created (core/, data/, domain/, presentation/)
- [ ] Core utilities (Result, AppException, ErrorHandler, AsyncHandler)
- [ ] Note entity defined with all fields
- [ ] Isar model generated successfully
- [ ] Database initializes on app start
- [ ] Riverpod providers configured
- [ ] pubspec.yaml has all dependencies
- [ ] Android build.gradle configured

---

## Files Created/Modified

### New Files:
- `lib/core/constants/` (directory)
- `lib/core/errors/app_exception.dart`
- `lib/core/utils/result.dart`
- `lib/core/utils/error_handler.dart`
- `lib/core/utils/async_handler.dart`
- `lib/core/di/providers.dart`
- `lib/data/datasources/local_database.dart`
- `lib/data/models/isar_note_model.dart`
- `lib/data/models/isar_note_model.g.dart` (generated)
- `lib/data/repositories/` (directory)
- `lib/domain/entities/note.dart`
- `lib/domain/repositories/` (directory)
- `lib/domain/usecases/usecase.dart`
- `lib/presentation/app.dart`
- `lib/presentation/providers/` (directory)
- `lib/presentation/pages/` (directory)
- `lib/presentation/widgets/` (directory)
- `analysis_options.yaml`

### Modified Files:
- `pubspec.yaml` — Added dependencies
- `android/app/build.gradle` — Updated SDK versions
- `lib/main.dart` — Refactored for Riverpod

---

## Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^3.2.1 | State management |
| riverpod_annotation | ^3.2.1 | Code generation |
| riverpod_generator | ^3.2.1 | DI code gen |
| go_router | ^14.6.2 | Navigation |
| isar | ^3.1.0 | Local database |
| isar_flutter_libs | ^3.1.0 | Isar native libs |
| isar_generator | ^3.1.0 | Isar code gen |
| firebase_core | ^3.9.0 | Firebase foundation |
| equatable | ^2.0.5 | Value equality |
| freezed | ^2.5.7 | Immutable classes |
| freezed_annotation | ^2.4.1 | Freezed annotations |
| json_annotation | ^4.9.0 | JSON serialization |
| json_serializable | ^6.9.0 | JSON code gen |
| uuid | ^4.5.1 | UUID generation |
| build_runner | ^2.4.14 | Code generation |
| flutter_lints | ^5.0.0 | Linting rules |

---

## Next Phase

After Phase 1 completes successfully:

**Phase 2: Authentication System**
- Firebase Auth setup
- Email/password login
- Google OAuth integration
- Password reset flow

Run `/gsd-execute-phase 1` to execute this plan.

---

*Plan created: 2025-02-27*
*Ready for execution*
