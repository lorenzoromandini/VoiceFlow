# Phase 3 Plan: Navigation & UI Framework

**Phase:** 3 - Navigation & UI Framework  
**Goal:** Users navigate between screens with responsive layouts that adapt to device size, with polished loading states.

---

## Plan Overview

| Plan ID | Name | Wave | Est. Time | Autonomous |
|---------|------|------|-----------|------------|
| 03-01 | Add Navigation Dependencies | 1 | 10 min | Yes |
| 03-02 | Setup go_router Configuration | 1 | 20 min | Yes |
| 03-03 | Create App Theme | 2 | 20 min | Yes |
| 03-04 | Configure Native Splash Screen | 2 | 15 min | Yes |
| 03-05 | Build Responsive Layout Widgets | 3 | 25 min | Yes |
| 03-06 | Create Skeleton Loading Widgets | 3 | 20 min | Yes |
| 03-07 | Build App Shell with Navigation | 4 | 30 min | Yes |
| 03-08 | Create Pages Structure | 4 | 25 min | Yes |
| 03-09 | Implement Loading States | 5 | 15 min | Yes |
| 03-10 | Test Navigation & Responsiveness | 5 | 15 min | Yes |

**Total Plans:** 10  
**Total Est. Time:** ~3 hours  
**Waves:** 5

---

## Wave 1: Navigation Setup (30 min)

### Plan 03-01: Add Navigation Dependencies

**Task:** Add go_router and flutter_native_splash

```xml
<task>
  <action>Update pubspec.yaml</action>
  <edit file="pubspec.yaml">
    dependencies:
      # ... existing dependencies ...
      
      # Navigation
      go_router: ^14.8.1
      
    dev_dependencies:
      # ... existing ...
      flutter_native_splash: ^2.4.4
  </edit>
</task>

<task>
  <action>Get dependencies</action>
  <command>flutter pub get</command>
</task>
```

**Files Modified:**
- `pubspec.yaml`

**Must Haves for Success:**
- [ ] go_router added
- [ ] flutter_native_splash added
- [ ] `flutter pub get` succeeds

---

### Plan 03-02: Setup go_router Configuration

**Task:** Create declarative router with routes

```xml
<task>
  <action>Create router configuration</action>
  <write file="lib/core/navigation/router.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:voiceflow_notes/presentation/pages/home_page.dart';
    import 'package:voiceflow_notes/presentation/pages/note_editor_page.dart';
    import 'package:voiceflow_notes/presentation/pages/settings_page.dart';
    import 'package:voiceflow_notes/presentation/pages/about_page.dart';

    final routerProvider = Provider<GoRouter>((ref) {
      return GoRouter(
        initialLocation: '/',
        routes: [
          // Home - Note list
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          
          // Create new note
          GoRoute(
            path: '/note/new',
            name: 'note-new',
            builder: (context, state) => const NoteEditorPage(),
          ),
          
          // Edit existing note
          GoRoute(
            path: '/note/:id',
            name: 'note-edit',
            builder: (context, state) {
              final noteId = state.pathParameters['id']!;
              return NoteEditorPage(noteId: noteId);
            },
          ),
          
          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          
          // About
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
        
        // Error page for unknown routes
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${state.error}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  </write>
</task>

<task>
  <action>Create navigation helper extensions</action>
  <write file="lib/core/navigation/extensions.dart">
    import 'package:go_router/go_router.dart';

    extension NavigationExtensions on GoRouter {
      void goHome() => go('/');
      void goNoteNew() => go('/note/new');
      void goNoteEdit(String id) => go('/note/$id');
      void goSettings() => go('/settings');
      void goAbout() => go('/about');
    }

    extension BuildContextNavigation on BuildContext {
      void popSafely() {
        if (canPop()) pop();
      }
    }
  </write>
</task>

<task>
  <action>Update app.dart to use router</action>
  <write file="lib/presentation/app.dart">
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/core/navigation/router.dart';
    import 'package:voiceflow_notes/core/theme/app_theme.dart';

    class VoiceFlowApp extends ConsumerWidget {
      const VoiceFlowApp({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final router = ref.watch(routerProvider);

        return MaterialApp.router(
          title: 'VoiceFlow Notes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: router,
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/core/navigation/router.dart`
- `lib/core/navigation/extensions.dart`
- `lib/presentation/app.dart`

**Must Haves for Success:**
- [ ] GoRouter configured with all routes
- [ ] Navigation extensions created
- [ ] MaterialApp.router setup
- [ ] No analysis errors

---

## Wave 2: Theme & Splash (35 min)

### Plan 03-03: Create App Theme

**Task:** Define Material 3 themes with VoiceFlow branding

```xml
<task>
  <action>Create theme configuration</action>
  <write file="lib/core/theme/app_theme.dart">
    import 'package:flutter/material.dart';
    import 'package:google_fonts/google_fonts.dart';

    class AppTheme {
      // Colors
      static const Color primaryColor = Color(0xFF6C63FF); // Purple
      static const Color secondaryColor = Color(0xFF00BFA6); // Teal
      static const Color errorColor = Color(0xFFE53935);
      static const Color backgroundLight = Color(0xFFF8F9FA);
      static const Color backgroundDark = Color(0xFF121212);

      static ThemeData get light {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: backgroundLight,
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: backgroundLight,
            foregroundColor: Colors.black87,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          textTheme: _textTheme(Brightness.light),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      static ThemeData get dark {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: backgroundDark,
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: backgroundDark,
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          textTheme: _textTheme(Brightness.dark),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      static TextTheme _textTheme(Brightness brightness) {
        final base = GoogleFonts.poppinsTextTheme();
        final color = brightness == Brightness.light ? Colors.black87 : Colors.white;

        return base.copyWith(
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          bodyLarge: base.bodyLarge?.copyWith(color: color),
          bodyMedium: base.bodyMedium?.copyWith(color: color),
          bodySmall: base.bodySmall?.copyWith(color: color),
        );
      }
    }
  </write>
</task>

<task>
  <action>Add google_fonts dependency</action>
  <edit file="pubspec.yaml">
    dependencies:
      # ... existing ...
      google_fonts: ^6.2.0
  </edit>
</task>
```

**Files Modified:**
- `lib/core/theme/app_theme.dart`
- `pubspec.yaml`

**Must Haves for Success:**
- [ ] Light and dark themes defined
- [ ] Material 3 enabled
- [ ] Custom colors (purple primary, teal accent)
- [ ] Consistent shapes (rounded corners)
- [ ] Typography configured

---

### Plan 03-04: Configure Native Splash Screen

**Task:** Setup flutter_native_splash for zero-delay splash

```xml
<task>
  <action>Create splash configuration</action>
  <write file="flutter_native_splash.yaml">
    flutter_native_splash:
      color: "#6C63FF"
      image: assets/images/splash_logo.png
      branding: assets/images/splash_branding.png
      
      android_12:
        image: assets/images/splash_logo_android12.png
        icon_background_color: "#6C63FF"
        
      fullscreen: true
      
      android: true
      ios: true
      web: true
  </write>
</task>

<task>
  <action>Create placeholder splash assets</action>
  <commands>
    mkdir -p assets/images
    # Create simple SVG or use placeholder
    echo "Placeholder: Replace with actual splash_logo.png (1024x1024)"
    echo "Placeholder: Replace with splash_branding.png (optional)"
  </commands>
</task>

<task>
  <action>Generate splash screens</action>
  <command>flutter pub run flutter_native_splash:create</command>
  <verify>Generates splash files for all platforms</verify>
</task>
```

**Files Modified:**
- `flutter_native_splash.yaml`
- `android/app/src/main/res/` (generated splash)
- `ios/Runner/` (generated splash)

**Must Haves for Success:**
- [ ] Config file created
- [ ] Assets directory setup
- [ ] Splash generated for all platforms
- [ ] App launches with splash immediately

---

## Wave 3: Responsive & Loading (45 min)

### Plan 03-05: Build Responsive Layout Widgets

**Task:** Create responsive layout utilities

```xml
<task>
  <action>Create responsive layout widget</action>
  <write file="lib/presentation/widgets/responsive_layout.dart">
    import 'package:flutter/material.dart';

    /// Breakpoints for responsive design
    class Breakpoints {
      static const double mobile = 600;
      static const double tablet = 900;
      
      static bool isMobile(BuildContext context) =>
          MediaQuery.of(context).size.width < mobile;
      
      static bool isTablet(BuildContext context) =>
          MediaQuery.of(context).size.width >= mobile && 
          MediaQuery.of(context).size.width < tablet;
      
      static bool isDesktop(BuildContext context) =>
          MediaQuery.of(context).size.width >= tablet;
    }

    /// Widget that builds different layouts based on screen size
    class ResponsiveLayout extends StatelessWidget {
      final Widget mobile;
      final Widget? tablet;
      final Widget? desktop;

      const ResponsiveLayout({
        super.key,
        required this.mobile,
        this.tablet,
        this.desktop,
      });

      @override
      Widget build(BuildContext context) {
        return LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth >= Breakpoints.tablet && desktop != null) {
            return desktop!;
          }
          if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
            return tablet!;
          }
          return mobile;
        });
      }
    }

    /// Responsive scaffold that adapts layout
    class ResponsiveScaffold extends StatelessWidget {
      final Widget body;
      final PreferredSizeWidget? appBar;
      final Widget? bottomNavigationBar;
      final Widget? drawer;
      final Widget? floatingActionButton;

      const ResponsiveScaffold({
        super.key,
        required this.body,
        this.appBar,
        this.bottomNavigationBar,
        this.drawer,
        this.floatingActionButton,
      });

      @override
      Widget build(BuildContext context) {
        final isDesktop = Breakpoints.isDesktop(context);
        
        return Scaffold(
          appBar: appBar,
          body: isDesktop
              ? Row(
                  children: [
                    if (drawer != null) drawer!,
                    Expanded(child: body),
                  ],
                )
              : body,
          bottomNavigationBar: isDesktop ? null : bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        );
      }
    }
  </write>
</task>

<task>
  <action>Create adaptive grid</action>
  <write file="lib/presentation/widgets/adaptive_grid.dart">
    import 'package:flutter/material.dart';
    import 'responsive_layout.dart';

    /// Grid that adapts number of columns to screen size
    class AdaptiveGrid extends StatelessWidget {
      final List<Widget> children;
      final double spacing;
      final double runSpacing;

      const AdaptiveGrid({
        super.key,
        required this.children,
        this.spacing = 16,
        this.runSpacing = 16,
      });

      @override
      Widget build(BuildContext context) {
        return LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount;
          
          if (constraints.maxWidth >= Breakpoints.tablet) {
            crossAxisCount = 3; // Desktop
          } else if (constraints.maxWidth >= Breakpoints.mobile) {
            crossAxisCount = 2; // Tablet
          } else {
            crossAxisCount = 1; // Mobile
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        });
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/widgets/responsive_layout.dart`
- `lib/presentation/widgets/adaptive_grid.dart`

**Must Haves for Success:**
- [ ] Breakpoint constants defined
- [ ] ResponsiveLayout widget
- [ ] ResponsiveScaffold with drawer/desktop support
- [ ] AdaptiveGrid for note list

---

### Plan 03-06: Create Skeleton Loading Widgets

**Task:** Build skeleton placeholders for loading states

```xml
<task>
  <action>Create skeleton widgets</action>
  <write file="lib/presentation/widgets/skeleton.dart">
    import 'package:flutter/material.dart';

    /// Base shimmer effect
    class Shimmer extends StatefulWidget {
      final Widget child;
      final Color baseColor;
      final Color highlightColor;
      final Duration period;

      const Shimmer({
        super.key,
        required this.child,
        this.baseColor = const Color(0xFFE0E0E0),
        this.highlightColor = const Color(0xFFF5F5F5),
        this.period = const Duration(milliseconds: 1500),
      });

      @override
      State<Shimmer> createState() => _ShimmerState();
    }

    class _ShimmerState extends State<Shimmer>
        with SingleTickerProviderStateMixin {
      late AnimationController _controller;
      late Animation<double> _animation;

      @override
      void initState() {
        super.initState();
        _controller = AnimationController(vsync: this, duration: widget.period)
          ..repeat();
        _animation = Tween<double>(begin: -1, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );
      }

      @override
      void dispose() {
        _controller.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
                  stops: const [0.0, 0.5, 1.0],
                  transform: GradientRotation(_animation.value * 3.14),
                ).createShader(bounds);
              },
              child: widget.child,
            );
          },
        );
      }
    }

    /// Skeleton for a note card
    class NoteCardSkeleton extends StatelessWidget {
      const NoteCardSkeleton({super.key});

      @override
      Widget build(BuildContext context) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 150,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      }
    }

    /// Skeleton for note list
    class NoteListSkeleton extends StatelessWidget {
      final int itemCount;

      const NoteListSkeleton({
        super.key,
        this.itemCount = 6,
      });

      @override
      Widget build(BuildContext context) {
        return Shimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: NoteCardSkeleton(),
            ),
          ),
        );
      }
    }

    /// Skeleton for a single note
    class NoteEditorSkeleton extends StatelessWidget {
      const NoteEditorSkeleton({super.key});

      @override
      Widget build(BuildContext context) {
        return Shimmer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/widgets/skeleton.dart`

**Must Haves for Success:**
- [ ] Shimmer animation widget
- [ ] NoteCardSkeleton
- [ ] NoteListSkeleton
- [ ] NoteEditorSkeleton

---

## Wave 4: App Shell (55 min)

### Plan 03-07: Build App Shell with Navigation

**Task:** Create main app shell with bottom nav and FAB

```xml
<task>
  <action>Create app shell scaffold</action>
  <write file="lib/presentation/widgets/app_shell.dart">
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'responsive_layout.dart';

    class AppShell extends StatelessWidget {
      final Widget body;
      final String currentPath;

      const AppShell({
        super.key,
        required this.body,
        required this.currentPath,
      });

      int get _currentIndex {
        switch (currentPath) {
          case '/':
            return 0;
          case '/settings':
            return 1;
          default:
            return 0;
        }
      }

      @override
      Widget build(BuildContext context) {
        final isDesktop = Breakpoints.isDesktop(context);

        return ResponsiveScaffold(
          appBar: AppBar(
            title: const Text('VoiceFlow'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Search functionality
                },
              ),
              if (isDesktop)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.go('/settings'),
                ),
            ],
          ),
          drawer: isDesktop ? _buildDrawer(context) : null,
          body: body,
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go('/');
                        break;
                      case 1:
                        context.go('/settings');
                        break;
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notes),
                      label: 'Notes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/note/new'),
            icon: const Icon(Icons.mic),
            label: const Text('Voice Note'),
          ),
        );
      }

      Widget _buildDrawer(BuildContext context) {
        return NavigationDrawer(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/settings');
                break;
              case 2:
                context.go('/about');
                break;
            }
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'VoiceFlow',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.notes_outlined),
              selectedIcon: Icon(Icons.notes),
              label: Text('Notes'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info),
              label: Text('About'),
            ),
          ],
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/widgets/app_shell.dart`

**Must Haves for Success:**
- [ ] Bottom navigation (mobile)
- [ ] Navigation drawer (desktop)
- [ ] FAB for voice note
- [ ] App bar with search icon
- [ ] Responsive switching

---

### Plan 03-08: Create Pages Structure

**Task:** Build Home, NoteEditor, Settings, and About pages

```xml
<task>
  <action>Update HomePage with AppShell</action>
  <write file="lib/presentation/pages/home_page.dart">
    import 'package:flutter/material.dart';
    import 'package:voiceflow_notes/presentation/widgets/app_shell.dart';
    import 'package:voiceflow_notes/presentation/widgets/skeleton.dart';

    class HomePage extends StatelessWidget {
      const HomePage({super.key});

      @override
      Widget build(BuildContext context) {
        return AppShell(
          currentPath: '/',
          body: const _HomeContent(),
        );
      }
    }

    class _HomeContent extends StatelessWidget {
      const _HomeContent();

      @override
      Widget build(BuildContext context) {
        // TODO: Replace with actual note list from Phase 4
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notes, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No notes yet',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the mic button to create your first voice note',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }
    }
  </write>
</task>

<task>
  <action>Create NoteEditorPage</action>
  <write file="lib/presentation/pages/note_editor_page.dart">
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    class NoteEditorPage extends StatefulWidget {
      final String? noteId;

      const NoteEditorPage({super.key, this.noteId});

      @override
      State<NoteEditorPage> createState() => _NoteEditorPageState();
    }

    class _NoteEditorPageState extends State<NoteEditorPage> {
      final _titleController = TextEditingController();
      final _contentController = TextEditingController();
      bool _isRecording = false;

      @override
      void dispose() {
        _titleController.dispose();
        _contentController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        final isNewNote = widget.noteId == null;

        return Scaffold(
          appBar: AppBar(
            title: Text(isNewNote ? 'New Note' : 'Edit Note'),
            actions: [
              TextButton(
                onPressed: () {
                  // Save note
                  context.pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Tap the mic button to start recording...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () {
              setState(() => _isRecording = !_isRecording);
              // TODO: Voice recording (Phase 5)
            },
            backgroundColor: _isRecording ? Colors.red : null,
            child: Icon(_isRecording ? Icons.stop : Icons.mic),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      }
    }
  </write>
</task>

<task>
  <action>Create SettingsPage</action>
  <write file="lib/presentation/pages/settings_page.dart">
    import 'package:flutter/material.dart';
    import 'package:voiceflow_notes/presentation/widgets/app_shell.dart';

    class SettingsPage extends StatelessWidget {
      const SettingsPage({super.key});

      @override
      Widget build(BuildContext context) {
        return AppShell(
          currentPath: '/settings',
          body: ListView(
            children: [
              const _SectionHeader('Account'),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Sign in to sync'),
                subtitle: const Text('Sync notes across devices'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to auth (Phase 4)
                },
              ),
              const Divider(),
              const _SectionHeader('Appearance'),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark mode'),
                subtitle: const Text('Follow system settings'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Theme toggle
                  },
                ),
              ),
              const Divider(),
              const _SectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About VoiceFlow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to about
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // Open privacy policy
                },
              ),
            ],
          ),
        );
      }
    }

    class _SectionHeader extends StatelessWidget {
      final String title;

      const _SectionHeader(this.title);

      @override
      Widget build(BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      }
    }
  </write>
</task>

<task>
  <action>Create AboutPage</action>
  <write file="lib/presentation/pages/about_page.dart">
    import 'package:flutter/material.dart';
    import 'package:voiceflow_notes/presentation/widgets/app_shell.dart';

    class AboutPage extends StatelessWidget {
      const AboutPage({super.key});

      @override
      Widget build(BuildContext context) {
        return AppShell(
          currentPath: '/about',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'VoiceFlow',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Voice-first note-taking app. Speak naturally and capture your thoughts instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open GitHub repo
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('View on GitHub'),
                ),
              ],
            ),
          ),
        );
      }
    }
  </write>
</task>
```

**Files Modified:**
- `lib/presentation/pages/home_page.dart`
- `lib/presentation/pages/note_editor_page.dart`
- `lib/presentation/pages/settings_page.dart`
- `lib/presentation/pages/about_page.dart`

**Must Haves for Success:**
- [ ] Home page with empty state
- [ ] Note editor with title/content fields
- [ ] Settings page with account/appearance/about sections
- [ ] About page with app info
- [ ] All wrapped in AppShell

---

## Wave 5: Integration & Testing (30 min)

### Plan 03-09: Implement Loading States

**Task:** Integrate skeleton loading in pages

```xml
<task>
  <action>Create loading state provider</action>
  <write file="lib/presentation/providers/loading_provider.dart">
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    final isLoadingProvider = StateProvider<bool>((ref) => false);

    final loadingNotesProvider = StateProvider<bool>((ref) => false);
    final loadingNoteProvider = StateProvider.family<bool, String>(
      (ref, id) => false,
    );
  </write>
</task>

<task>
  <action>Add loading states to HomePage</action>
  <edit file="lib/presentation/pages/home_page.dart">
    // Add import
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/presentation/providers/loading_provider.dart';

    // Update _HomeContent to ConsumerWidget
    class _HomeContent extends ConsumerWidget {
      const _HomeContent();

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final isLoading = ref.watch(loadingNotesProvider);

        if (isLoading) {
          return const NoteListSkeleton();
        }

        // ... rest of existing code
      }
    }
  </edit>
</task>

<task>
  <action>Add loading states to NoteEditorPage</action>
  <edit file="lib/presentation/pages/note_editor_page.dart">
    // Add imports
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:voiceflow_notes/presentation/providers/loading_provider.dart';
    import 'package:voiceflow_notes/presentation/widgets/skeleton.dart';

    // Wrap build with Consumer
    class NoteEditorPage extends ConsumerStatefulWidget {
      // ... existing code
    }

    // In build method:
    final isLoading = ref.watch(loadingNoteProvider(widget.noteId ?? 'new'));

    if (isLoading) {
      return const Scaffold(
        body: NoteEditorSkeleton(),
      );
    }

    // ... rest of existing build
  </edit>
</task>
```

**Files Modified:**
- `lib/presentation/providers/loading_provider.dart`
- `lib/presentation/pages/home_page.dart`
- `lib/presentation/pages/note_editor_page.dart`

**Must Haves for Success:**
- [ ] Loading providers created
- [ ] Skeleton shown while loading
- [ ] Smooth transitions

---

### Plan 03-10: Test Navigation & Responsiveness

**Task:** Verify all navigation and responsive layouts

```xml
<task>
  <action>Build and verify</action>
  <commands>
    flutter analyze
    flutter build web
  </commands>
  <verify>No errors, web build succeeds</verify>
</task>

<task>
  <action>Test navigation manually</action>
  <manual>
    1. Launch app → Splash screen shows
    2. App loads to Home page
    3. Tap FAB → Note editor opens
    4. Back button → Returns to Home
    5. Tap Settings in bottom nav → Settings opens
    6. Tap Back → Returns to Home
    7. Test responsive: resize window
       - < 600px: Bottom nav visible
       - > 900px: Side drawer visible
  </manual>
</task>

<task>
  <action>Test loading states</action>
  <manual>
    1. Toggle loading provider manually
    2. Verify skeleton appears
    3. Verify smooth transition to content
  </manual>
</task>
```

**Files Modified:** None (testing only)

**Must Haves for Success:**
- [ ] All routes accessible
- [ ] Navigation works (deep links, back button)
- [ ] Responsive layouts switch correctly
- [ ] Loading skeletons appear
- [ ] Web build succeeds

---

## Verification Criteria

### Phase Success Criteria (from ROADMAP)

- [ ] App launches in under 3 seconds (splash + first render)
- [ ] Navigation works between screens (go_router)
- [ ] UI adapts to mobile/tablet/desktop
- [ ] Bottom navigation (mobile) / Drawer (desktop)
- [ ] Loading states show skeletons
- [ ] FAB for voice note visible
- [ ] Theme works in light and dark mode

### Technical Verification

- [ ] go_router configured with all routes
- [ ] Deep linking works
- [ ] Responsive breakpoints implemented
- [ ] Skeleton loading widgets created
- [ ] App shell with navigation complete
- [ ] All pages (Home, Editor, Settings, About)
- [ ] Native splash screen configured
- [ ] Material 3 theming applied
- [ ] Web build succeeds

---

## Files Created/Modified

### New Files:
- `lib/core/navigation/router.dart` — GoRouter config
- `lib/core/navigation/extensions.dart` — Navigation helpers
- `lib/core/theme/app_theme.dart` — Light/dark themes
- `lib/presentation/widgets/responsive_layout.dart` — Responsive utilities
- `lib/presentation/widgets/adaptive_grid.dart` — Responsive grid
- `lib/presentation/widgets/skeleton.dart` — Loading skeletons
- `lib/presentation/widgets/app_shell.dart` — Main app scaffold
- `lib/presentation/providers/loading_provider.dart` — Loading states
- `lib/presentation/pages/home_page.dart` — Note list
- `lib/presentation/pages/note_editor_page.dart` — Create/edit notes
- `lib/presentation/pages/settings_page.dart` — App settings
- `lib/presentation/pages/about_page.dart` — About page
- `flutter_native_splash.yaml` — Splash config
- `assets/images/` — Splash assets

### Modified Files:
- `lib/presentation/app.dart` — Use router
- `pubspec.yaml` — Add go_router, google_fonts, flutter_native_splash
- `lib/main.dart` — May need updates

---

## Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| go_router | ^14.8.1 | Navigation |
| google_fonts | ^6.2.0 | Typography |
| flutter_native_splash | ^2.4.4 | Native splash screen |

---

## Next Phase

**Phase 4: Local Storage & Note CRUD**
- Isar integration
- Note repository
- Create, read, update, delete notes
- Local search

---

*Plan created: 2025-02-27*
*Ready for execution*
