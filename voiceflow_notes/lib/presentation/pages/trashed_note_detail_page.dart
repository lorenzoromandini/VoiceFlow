import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/permanently_delete_note_usecase.dart';
import '../../domain/usecases/restore_from_trash_usecase.dart';
import '../providers/notes_provider.dart';

class TrashedNoteDetailPage extends ConsumerWidget {
  final String noteId;

  const TrashedNoteDetailPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(trashedNotesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trash'),
        ),
      ),
      body: notesAsync.when(
        data: (notes) {
          final note = notes.where((n) => n.id == noteId).firstOrNull;
          if (note == null) {
            return const Center(child: Text('Note not found'));
          }
          return _NoteDetailContent(note: note);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load note')),
      ),
      bottomNavigationBar: notesAsync.when(
        data: (notes) {
          final note = notes.where((n) => n.id == noteId).firstOrNull;
          if (note == null) return const SizedBox.shrink();
          return _ActionBar(note: note);
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _NoteDetailContent extends StatelessWidget {
  final Note note;

  const _NoteDetailContent({required this.note});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title.isEmpty ? 'Untitled' : note.title,
            style: AppTheme.noteTitleStyle(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Deleted ${_formatDate(note.deletedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.hourglass_empty,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '${note.daysRemainingInTrash} days left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            note.content.isEmpty ? 'No content' : note.content,
            style: AppTheme.noteContentStyle(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionBar extends ConsumerWidget {
  final Note note;

  const _ActionBar({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _restoreNote(context, ref),
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => _permanentlyDelete(context, ref),
                icon: Icon(Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error),
                label: Text('Delete',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
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
      context.go('/trash');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored')),
      );
    } else if (context.mounted && result.isFailure) {
      ErrorHandler.showError(context, result.error!);
    }
  }

  Future<void> _permanentlyDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete?'),
        content: const Text(
            'This note will be permanently deleted and cannot be recovered.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final useCase = ref.read(permanentlyDeleteNoteUseCaseProvider);
      final result =
          await useCase(PermanentlyDeleteNoteParams(note.id));

      if (result.isSuccess && context.mounted) {
        context.go('/trash');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note permanently deleted')),
        );
      } else if (context.mounted && result.isFailure) {
        ErrorHandler.showError(context, result.error!);
      }
    }
  }
}
