import '../../core/utils/result.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class RestoreFromTrashParams {
  final String id;
  const RestoreFromTrashParams(this.id);
}

class RestoreFromTrashUseCase implements UseCase<void, RestoreFromTrashParams> {
  final NoteRepository _repository;

  RestoreFromTrashUseCase(this._repository);

  @override
  Future<Result<void>> call(RestoreFromTrashParams params) {
    return _repository.restoreFromTrash(params.id);
  }
}
