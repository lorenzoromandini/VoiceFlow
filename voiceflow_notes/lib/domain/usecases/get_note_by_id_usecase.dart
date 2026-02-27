import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class GetNoteByIdParams {
  final String id;
  const GetNoteByIdParams(this.id);
}

class GetNoteByIdUseCase implements UseCase<Note?, GetNoteByIdParams> {
  final NoteRepository _repository;

  GetNoteByIdUseCase(this._repository);

  @override
  Future<Result<Note?>> call(GetNoteByIdParams params) {
    return _repository.getNoteById(params.id);
  }
}
