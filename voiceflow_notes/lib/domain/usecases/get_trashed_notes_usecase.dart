import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class GetTrashedNotesUseCase implements UseCase<List<Note>, NoParams> {
  final NoteRepository _repository;

  GetTrashedNotesUseCase(this._repository);

  @override
  Future<Result<List<Note>>> call(NoParams params) {
    return _repository.getTrashedNotes();
  }
}
