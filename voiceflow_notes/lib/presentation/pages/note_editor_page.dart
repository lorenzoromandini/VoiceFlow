import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/get_note_by_id_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../providers/notes_provider.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Timer? _debounceTimer;
  bool _isNewNote = true;
  Note? _currentNote;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      _isNewNote = false;
      final useCase = ref.read(getNoteByIdUseCaseProvider);
      final result = await useCase(GetNoteByIdParams(widget.noteId!));

      if (result.isSuccess && result.value != null) {
        setState(() {
          _currentNote = result.value;
          _titleController.text = _currentNote!.title;
          _contentController.text = _currentNote!.content;
        });
      }
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    if (_isNewNote) {
      // Create new note
      final useCase = ref.read(createNoteUseCaseProvider);
      final result = await useCase(CreateNoteParams(
        title: title,
        content: content,
      ));

      if (result.isSuccess) {
        setState(() {
          _isNewNote = false;
          _currentNote = result.value;
        });
      } else if (mounted) {
        ErrorHandler.showError(context, result.error!);
      }
    } else if (_currentNote != null) {
      // Update existing note
      final updatedNote = _currentNote!.copyWith(
        title: title,
        content: content,
      );

      final useCase = ref.read(updateNoteUseCaseProvider);
      final result = await useCase(updatedNote);

      if (result.isFailure && mounted) {
        ErrorHandler.showError(context, result.error!);
      }
    }
  }

  Future<void> _onVoiceButtonPressed() async {
    // TODO: Implement voice recording (Phase 5)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Input'),
        content: const Text('Voice recording coming in Phase 5!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
        actions: [
          TextButton(
            onPressed: _autoSave,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: AppTheme.noteTitleStyle(context),
              onChanged: (_) => _onTextChanged(),
            ),
          ),
          const Divider(),
          // Content field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start typing or tap the mic to record...',
                  border: InputBorder.none,
                ),
                style: AppTheme.noteContentStyle(context),
                maxLines: null,
                expands: true,
                onChanged: (_) => _onTextChanged(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _onVoiceButtonPressed,
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
