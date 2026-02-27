import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import 'responsive_layout.dart';

class AppShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Breakpoints.isDesktop(context);
    final trashedCount = ref.watch(trashedNotesCountProvider);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('VoiceFlow'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          
          // Trash button with badge
          IconButton(
            icon: trashedCount.when(
              data: (count) => count > 0
                  ? Badge(
                      label: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: const Icon(Icons.delete_outline),
                    )
                  : const Icon(Icons.delete_outline),
              loading: () => const Icon(Icons.delete_outline),
              error: (_, __) => const Icon(Icons.delete_outline),
            ),
            tooltip: 'Trash',
            onPressed: () => context.go('/trash'),
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
