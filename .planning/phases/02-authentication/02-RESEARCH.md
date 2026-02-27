# Phase 2 Research: Authentication System

## Research Date
2025-02-27

## Phase Goal
Users can securely create accounts and authenticate via email/password or Google OAuth.

---

## Key Research Findings

### 1. Firebase Authentication for Flutter

**Current State (Feb 2025):**
- **firebase_auth: ^5.5.1** — Latest stable
- **google_sign_in: ^6.3.0** — Google OAuth integration
- **flutterfire CLI** — Required for Firebase project configuration

**Architecture Decisions:**

**Option A: Firebase Auth with Riverpod (Recommended)**
- Use Riverpod to manage auth state globally
- Provider that watches auth state changes
- Clean separation: UI layer never talks to Firebase directly

**Option B: Direct Firebase in UI**
- Call Firebase Auth methods directly from widgets
- Quick but messy, hard to test
- Not recommended for production

**Decision:** Option A — Repository pattern with Riverpod

---

### 2. Authentication Flow Architecture

**Recommended Pattern:**

```
┌─────────────────────────────────────────────────────────┐
│  UI Layer (LoginPage, SignUpPage)                       │
│  - Calls UseCases                                       │
│  - Shows loading/error states                           │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│  Domain Layer                                           │
│  - UseCases: SignInUseCase, SignUpUseCase, etc.        │
│  - Returns Result<User>                                 │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│  Data Layer                                             │
│  - AuthRepository (interface)                           │
│  - FirebaseAuthRepository (implementation)             │
│  - GoogleSignInRepository (implementation)             │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│  External                                               │
│  - Firebase Auth SDK                                   │
│  - Google Sign-In SDK                                  │
└─────────────────────────────────────────────────────────┘
```

---

### 3. Firebase Auth Methods

**Email/Password:**
```dart
// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Send password reset
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
```

**Google OAuth:**
```dart
// Triggered from UI
final googleUser = await GoogleSignIn().signIn();
final googleAuth = await googleUser!.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

---

### 4. Auth State Management with Riverpod

**Best Practice:**

```dart
// Single source of truth for auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Use case providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(authRepositoryProvider));
});
```

**UI Consumption:**
```dart
// In any widget
Consumer(builder: (context, ref, child) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null ? HomePage() : LoginPage(),
    loading: () => CircularProgressIndicator(),
    error: (_, __) => ErrorWidget(),
  );
});
```

---

### 5. Session Persistence

**Firebase Auth handles this automatically:**
- Stores auth token in platform-specific secure storage
- Persists across app restarts
- Refreshes tokens automatically
- **Nothing extra needed!** (Fulfills AUTH-03)

**Verification:**
```dart
// On app start, Firebase automatically restores session
FirebaseAuth.instance.authStateChanges().listen((user) {
  // user will be non-null if previously authenticated
});
```

---

### 6. Security Considerations

**Email Validation:**
- Firebase can send verification emails: `user.sendEmailVerification()`
- Check: `user.emailVerified`
- Recommended: Allow login but restrict features until verified

**Password Requirements:**
- Firebase enforces minimum 6 characters
- Recommended: Add client-side validation for stronger passwords
- Pattern: At least 8 chars, 1 uppercase, 1 number

**Rate Limiting:**
- Firebase handles brute force protection
- Returns specific error codes for retry limits

---

### 7. Error Handling

**Firebase Auth Error Codes:**

| Error Code | Meaning | User Message |
|------------|---------|--------------|
| `invalid-email` | Bad email format | "Please enter a valid email" |
| `user-disabled` | Account disabled | "This account has been disabled" |
| `user-not-found` | No such user | "No account found with this email" |
| `wrong-password` | Bad password | "Incorrect password. Please try again" |
| `email-already-in-use` | Duplicate email | "An account already exists with this email" |
| `weak-password` | Weak password | "Password must be at least 8 characters" |
| `network-request-failed` | No internet | "Please check your internet connection" |

**Implementation:** Map Firebase errors to AppException subclasses

---

### 8. Google OAuth Configuration

**Android Setup:**
1. Add `google-services.json` to `android/app/`
2. Configure OAuth 2.0 client in Google Cloud Console
3. Add SHA-1 fingerprint from signing certificate

**Web Setup:**
1. Add web client ID configuration
2. Configure authorized JavaScript origins
3. Handle pop-up vs redirect flow

**Flutter Setup:**
```yaml
dependencies:
  google_sign_in: ^6.3.0
  firebase_auth: ^5.5.1
```

---

### 9. Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_auth | ^5.5.1 | Email/password, OAuth, session management |
| google_sign_in | ^6.3.0 | Google OAuth integration |
| firebase_core | ^3.15.2 | Already in Phase 1 |

**No additional dependencies needed** — Firebase Auth is the core.

---

### 10. Testing Strategy

**Unit Tests:**
- Mock AuthRepository
- Test UseCases with mocked failures
- Verify error mapping

**Integration Tests:**
- Test against Firebase Auth Emulator
- Mock Google Sign-In (hard to automate)

**Manual Testing:**
- Real Google OAuth flow
- Password reset email arrival
- Session persistence across restarts

---

## Technical Decisions for Phase 2

### Locked Decisions

1. **Firebase Auth Backend**
   - *Rationale:* Managed service, secure, free tier, handles session persistence

2. **Repository Pattern**
   - *Rationale:* Abstract Firebase for testing, allow future auth provider swaps

3. **Riverpod for Auth State**
   - *Rationale:* Reactive, testable, already in Phase 1 architecture

4. **Google OAuth Included**
   - *Rationale:* User requirement, modern auth standard

### Claude's Discretion

1. **Email Verification Required?**
   - *Recommendation:* Optional for MVP, add in v2
   - *Reason:* Friction for users, Firebase allows unverified access

2. **Password Reset Flow UX**
   - *Recommendation:* Deep link back to app from email
   - *Alternative:* Just show "Check your email" message

3. **Anonymous Auth?**
   - *Recommendation:* Skip for MVP
   - *Reason:* Adds complexity, not in requirements

---

## Implementation Risks & Mitigations

### Risk: Google OAuth Complexity
**Mitigation:** Use firebase_auth's Google provider (simpler than raw Google Sign-In)

### Risk: Session Persistence Edge Cases
**Mitigation:** Firebase handles this, but test: force quit app, reboot device

### Risk: Error Messages Not User-Friendly
**Mitigation:** Map all Firebase error codes to custom messages in ErrorHandler

### Risk: Firebase Project Setup
**Mitigation:** Document steps clearly, use flutterfire CLI

---

## Integration with Phase 1

**Leverages:**
- Error handling (AppException, Result type)
- AsyncHandler for Firebase calls
- Riverpod ProviderScope already configured
- Note entity (will extend with userId)

**Extends:**
- Add userId to Note entity
- AuthRepository implementation
- Auth UseCases
- Login/Register UI

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/domain/entities/user.dart` | User entity |
| `lib/domain/repositories/auth_repository.dart` | Auth interface |
| `lib/data/repositories/firebase_auth_repository.dart` | Firebase implementation |
| `lib/domain/usecases/sign_in_usecase.dart` | Sign in use case |
| `lib/domain/usecases/sign_up_usecase.dart` | Sign up use case |
| `lib/domain/usecases/sign_out_usecase.dart` | Sign out use case |
| `lib/domain/usecases/reset_password_usecase.dart` | Password reset use case |
| `lib/presentation/providers/auth_provider.dart` | Auth state providers |
| `lib/presentation/pages/login_page.dart` | Login screen |
| `lib/presentation/pages/register_page.dart` | Registration screen |
| `android/app/google-services.json` | Firebase config (Android) |
| `ios/Runner/GoogleService-Info.plist` | Firebase config (iOS) |

---

## Firebase Project Setup Steps

1. Go to https://console.firebase.google.com
2. Create project "VoiceFlow"
3. Add Android app: package `com.voiceflow.voiceflow_notes`
4. Add Web app: name "VoiceFlow Web"
5. Enable Authentication: Email/Password, Google
6. Download config files
7. Run `flutterfire configure`

---

## References

- [Firebase Auth Flutter](https://firebase.flutter.dev/docs/auth/overview)
- [Riverpod Auth Example](https://riverpod.dev/docs/case_studies/authentication)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Auth Error Codes](https://firebase.google.com/docs/auth/flutter/errors)

---

*Research completed: 2025-02-27*
*Ready for planning phase*
