import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voiceflow_notes/data/repositories/isar_note_repository.dart';
import 'package:voiceflow_notes/domain/entities/note.dart';
import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
import 'package:voiceflow_notes/domain/usecases/create_note_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/delete_note_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/empty_trash_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/get_note_by_id_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/get_notes_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/get_trashed_notes_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/move_to_trash_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/restore_from_trash_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/search_notes_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/update_note_usecase.dart';
import 'package:voiceflow_notes/domain/usecases/usecase.dart';
import 'local_database_provider.dart';

// Repository
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(localDatabaseProvider);
  return IsarNoteRepository(db);
});

// Use cases
final getNotesUseCaseProvider = Provider<GetNotesUseCase>((ref) {
  return GetNotesUseCase(ref.watch(noteRepositoryProvider));
});

final getNoteByIdUseCaseProvider = Provider<GetNoteByIdUseCase>((ref) {
  return GetNoteByIdUseCase(ref.watch(noteRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(noteRepositoryProvider));
});

final moveToTrashUseCaseProvider = Provider<MoveToTrashUseCase>((ref) {
  return MoveToTrashUseCase(ref.watch(noteRepositoryProvider));
});

final restoreFromTrashUseCaseProvider = Provider<RestoreFromTrashUseCase>((ref) {
  return RestoreFromTrashUseCase(ref.watch(noteRepositoryProvider));
});

final emptyTrashUseCaseProvider = Provider<EmptyTrashUseCase>((ref) {
  return EmptyTrashUseCase(ref.watch(noteRepositoryProvider));
});

final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
  return SearchNotesUseCase(ref.watch(noteRepositoryProvider));
});

// Stream provider for reactive updates
final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotesStream();
});

// Trashed notes stream
final trashedNotesStreamProvider = StreamProvider<List<Note>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getTrashedNotesStream();
});

// Current notes (async)
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final useCase = ref.watch(getNotesUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.value ?? [];
});

// Selected note
final selectedNoteProvider = StateProvider<Note?>((ref) => null);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results
final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final useCase = ref.watch(searchNotesUseCaseProvider);
  final result = await useCase(SearchNotesParams(query));
  return result.value ?? [];
});

// Notes count
final notesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getNotesCount();
  return result.value ?? 0;
});

// Trashed notes count
final trashedNotesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getTrashedNotesCount();
  return result.value ?? 0;
});

// Loading state for operations
final noteOperationLoadingProvider = StateProvider<bool>((ref) => false);

// Error state
final noteErrorProvider = StateProvider<String?>((ref) => null);
