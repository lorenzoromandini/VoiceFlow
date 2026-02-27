import '../../core/utils/result.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class MoveToTrashParams {
  final String id;
  const MoveToTrashParams(this.id);
}

class MoveToTrashUseCase implements UseCase<void, MoveToTrashParams> {
  final NoteRepository _repository;

  MoveToTrashUseCase(this._repository);

  @override
  Future<Result<void>> call(MoveToTrashParams params) {
    return _repository.moveToTrash(params.id);
  }
}
