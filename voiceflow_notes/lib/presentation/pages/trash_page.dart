import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/empty_trash_usecase.dart';
import '../../domain/usecases/permanently_delete_note_usecase.dart';
import '../../domain/usecases/restore_from_trash_usecase.dart';
import '../providers/notes_provider.dart';
import '../widgets/app_shell.dart';

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedNotesAsync = ref.watch(trashedNotesStreamProvider);
    final trashedCount = ref.watch(trashedNotesCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          // Empty trash button
          TextButton(
            onPressed: () => _showEmptyTrashConfirmation(context, ref),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
      body: trashedNotesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const _EmptyState();
          }
          return _TrashedNoteList(notes: notes);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _ErrorState(),
      ),
    );
  }

  Future<void> _showEmptyTrashConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text(
          'All notes in trash older than 15 days will be permanently deleted. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Empty Trash',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final useCase = ref.read(emptyTrashUseCaseProvider);
      final result = await useCase(const NoParams());

      if (result.isSuccess && context.mounted) {
        final deletedCount = result.value ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount notes permanently deleted'),
          ),
        );
      } else if (context.mounted && result.isFailure) {
        ErrorHandler.showError(context, result.error!);
      }
    }
  }
}

class _TrashedNoteList extends StatelessWidget {
  final List<Note> notes;

  const _TrashedNoteList({required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _TrashedNoteCard(note: note);
      },
    );
  }
}

class _TrashedNoteCard extends ConsumerWidget {
  final Note note;

  const _TrashedNoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysRemaining = note.daysRemainingInTrash;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              style: AppTheme.noteTitleStyle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Preview
            if (note.preview.isNotEmpty)
              Text(
                note.preview,
                style: AppTheme.notePreviewStyle(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 8),

            // Days remaining
            Text(
              daysRemaining <= 0
                  ? 'Will be deleted soon'
                  : 'Deleted in $daysRemaining days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: daysRemaining <= 3
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline,
                  ),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _restoreNote(context, ref),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _permanentlyDelete(context, ref),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Forever'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreNote(BuildContext context, WidgetRef ref) async {
    final useCase = ref.read(restoreFromTrashUseCaseProvider);
    final result = await useCase(RestoreFromTrashParams(note.id));

    if (result.isSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${note.title.isEmpty ? 'Untitled' : note.title}" restored'),
        ),
      );
    } else if (context.mounted && result.isFailure) {
      ErrorHandler.showError(context, result.error!);
    }
  }

  Future<void> _permanentlyDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forever?'),
        content: const Text(
          'This note will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete Forever',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final useCase = ref.read(permanentlyDeleteNoteUseCaseProvider);
      final result = await useCase(PermanentlyDeleteNoteParams(note.id));

      if (result.isSuccess && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note permanently deleted'),
          ),
        );
      } else if (context.mounted && result.isFailure) {
        ErrorHandler.showError(context, result.error!);
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Trash is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Deleted notes will appear here\nfor 15 days before permanent deletion',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load trash',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
