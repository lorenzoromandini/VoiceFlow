import '../../core/utils/result.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class DeleteNoteParams {
  final String id;
  const DeleteNoteParams(this.id);
}

class DeleteNoteUseCase implements UseCase<void, DeleteNoteParams> {
  final NoteRepository _repository;

  DeleteNoteUseCase(this._repository);

  @override
  Future<Result<void>> call(DeleteNoteParams params) {
    return _repository.deleteNote(params.id);
  }
}
