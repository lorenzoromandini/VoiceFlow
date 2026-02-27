import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class UpdateNoteUseCase implements UseCase<void, Note> {
  final NoteRepository _repository;

  UpdateNoteUseCase(this._repository);

  @override
  Future<Result<void>> call(Note note) {
    return _repository.updateNote(note);
  }
}
