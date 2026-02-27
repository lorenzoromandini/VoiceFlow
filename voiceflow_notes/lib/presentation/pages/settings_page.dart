import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../widgets/app_shell.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedCount = ref.watch(trashedNotesCountProvider);

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
              // TODO: Navigate to auth (Phase 11)
            },
          ),
          const Divider(),
          
          const _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Trash'),
            subtitle: const Text('Manage deleted notes'),
            trailing: trashedCount.when(
              data: (count) => count > 0
                  ? Badge(
                      label: Text('$count'),
                      child: const Icon(Icons.chevron_right),
                    )
                  : const Icon(Icons.chevron_right),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.chevron_right),
            ),
            onTap: () => context.go('/trash'),
          ),
          const Divider(),
          
          const _SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            subtitle: const Text('Follow system settings'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
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
            onTap: () => context.go('/about'),
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
