import 'package:voiceflow_notes/core/utils/result.dart';
import 'package:voiceflow_notes/domain/repositories/note_repository.dart';
import 'package:voiceflow_notes/domain/usecases/usecase.dart';

class PermanentlyDeleteNoteParams {
  final String id;
  const PermanentlyDeleteNoteParams(this.id);
}

class PermanentlyDeleteNoteUseCase
    implements UseCase<void, PermanentlyDeleteNoteParams> {
  final NoteRepository _repository;

  PermanentlyDeleteNoteUseCase(this._repository);

  @override
  Future<Result<void>> call(PermanentlyDeleteNoteParams params) {
    return _repository.permanentlyDeleteNote(params.id);
  }
}
