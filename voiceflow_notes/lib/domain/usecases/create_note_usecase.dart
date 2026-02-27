import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class CreateNoteParams {
  final String title;
  final String content;

  const CreateNoteParams({
    required this.title,
    required this.content,
  });
}

class CreateNoteUseCase implements UseCase<Note, CreateNoteParams> {
  final NoteRepository _repository;

  CreateNoteUseCase(this._repository);

  @override
  Future<Result<Note>> call(CreateNoteParams params) {
    return _repository.createNote(
      title: params.title,
      content: params.content,
    );
  }
}
