import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class GetNotesUseCase implements UseCase<List<Note>, NoParams> {
  final NoteRepository _repository;

  GetNotesUseCase(this._repository);

  @override
  Future<Result<List<Note>>> call(NoParams params) {
    return _repository.getAllNotes();
  }
}
