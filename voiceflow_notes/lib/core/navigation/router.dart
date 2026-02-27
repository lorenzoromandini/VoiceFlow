import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/note_editor_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/about_page.dart';
import '../../presentation/pages/trash_page.dart';
import '../../presentation/pages/welcome_page.dart';
import '../../presentation/pages/trashed_note_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      // Welcome - First launch
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      
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
      
      // Trash
      GoRoute(
        path: '/trash',
        name: 'trash',
        builder: (context, state) => const TrashPage(),
      ),
      
      // Trash note detail
      GoRoute(
        path: '/trash/:id',
        name: 'trash-detail',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return TrashedNoteDetailPage(noteId: noteId);
        },
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
