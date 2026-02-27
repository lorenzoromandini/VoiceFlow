# Phase 3 Research: Navigation & UI Framework

## Research Date
2025-02-27

## Phase Goal
Users navigate between screens with responsive layouts that adapt to device size, with polished loading states.

---

## Key Research Findings

### 1. Navigation: go_router vs Navigator 2.0

**Decision: go_router (already chosen in Phase 1)**

**Why go_router:**
- ✅ Declarative routing (URL-based)
- ✅ Deep linking support
- ✅ Works with Riverpod
- ✅ Official Flutter package
- ✅ Type-safe routes possible

**Basic Pattern:**
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/note/:id', builder: (_, state) => NotePage(id: state.params['id']!)),
    GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
  ],
);
```

**Integration with Riverpod:**
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // ... routes
    ],
  );
});
```

---

### 2. Responsive Design

**Approach: Breakpoint-based layouts**

**Breakpoints:**
| Width | Name | Use Case |
|-------|------|----------|
| < 600px | Mobile | Phone portrait |
| 600-900px | Tablet | Phone landscape/tablet |
| > 900px | Desktop | Tablets/desktop |

**Implementation:**
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) return mobile;
      if (constraints.maxWidth < 900) return tablet;
      return desktop;
    });
  }
}
```

---

### 3. Splash Screen

**Two Options:**

**Option A: Flutter Native Splash (Recommended)**
- Package: `flutter_native_splash`
- Shows immediately on app start
- Native platform splash (no Flutter delay)
- Auto-hides when Flutter loads

**Option B: Custom Splash Widget**
- Pure Flutter implementation
- Shows after Flutter loads
- More control but slight delay

**Decision:** Option A for true zero-delay splash

---

### 4. Loading States

**Skeleton Screens (Recommended):**
- Show placeholder UI while data loads
- Better UX than spinner alone
- Package: `shimmer` or custom implementation

**Implementation:**
```dart
class NoteSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(width: 48, height: 48, color: Colors.white),
        title: Container(height: 16, color: Colors.white),
        subtitle: Container(height: 12, color: Colors.white),
      ),
    );
  }
}
```

---

### 5. Theming

**Material 3 (You):**
- Modern design system
- Dynamic colors (Android 12+)
- Built into Flutter

**Dark Mode:**
- Automatic with `ThemeMode.system`
- Define both light and dark themes

---

### 6. Navigation Structure

**Routes needed:**
- `/` — Home (note list)
- `/note/new` — Create new note
- `/note/:id` — Edit note
- `/settings` — App settings
- `/about` — About page

**Bottom Navigation:**
- Home (notes)
- Settings (sync, theme, logout)
- FAB: Create new note

---

## Technical Decisions

### Locked Decisions

1. **Navigation: go_router**
   - URL-based routing
   - Deep linking ready

2. **Splash: flutter_native_splash**
   - Native platform splash
   - No Flutter delay

3. **Responsive: LayoutBuilder breakpoints**
   - Mobile/tablet/desktop
   - Simple, no packages needed

4. **Theming: Material 3**
   - Built-in, modern

### Claude's Discretion

1. **Bottom Nav vs Drawer?**
   - Recommendation: Bottom nav (mobile), drawer (desktop)
   - Or: Always bottom nav (simpler)

2. **Skeleton package vs custom?**
   - Recommendation: Custom (simple rectangles)
   - Package adds complexity

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| go_router | ^14.8.1 | Navigation |
| flutter_native_splash | ^2.4.4 | Splash screen |

---

## Files to Create

- `lib/core/theme/app_theme.dart` — Theme definitions
- `lib/core/navigation/router.dart` — GoRouter configuration
- `lib/presentation/widgets/responsive_layout.dart` — Responsive wrapper
- `lib/presentation/widgets/skeleton.dart` — Skeleton placeholders
- `lib/presentation/widgets/bottom_nav.dart` — Bottom navigation
- `lib/presentation/pages/splash_page.dart` — Splash fallback
- Assets: splash screen images

---

## References

- [go_router documentation](https://pub.dev/packages/go_router)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [Material 3 design](https://m3.material.io/)

---

*Research completed: 2025-02-27*
*Ready for planning*
