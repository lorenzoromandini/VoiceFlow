import '../../core/utils/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'usecase.dart';

class SearchNotesParams {
  final String query;
  const SearchNotesParams(this.query);
}

class SearchNotesUseCase implements UseCase<List<Note>, SearchNotesParams> {
  final NoteRepository _repository;

  SearchNotesUseCase(this._repository);

  @override
  Future<Result<List<Note>>> call(SearchNotesParams params) {
    return _repository.searchNotes(params.query);
  }
}
