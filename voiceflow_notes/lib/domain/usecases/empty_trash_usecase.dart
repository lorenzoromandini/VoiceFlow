import '../../core/utils/result.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class EmptyTrashUseCase implements UseCase<int, NoParams> {
  final NoteRepository _repository;

  EmptyTrashUseCase(this._repository);

  @override
  Future<Result<int>> call(NoParams params) {
    return _repository.emptyTrash();
  }
}
