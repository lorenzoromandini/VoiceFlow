import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voiceflow_notes/data/models/isar_note_model.dart';

class LocalDatabase {
  late final Isar _isar;

  Isar get isar => _isar;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [IsarNoteModelSchema],
      directory: dir.path,
    );
  }

  Future<void> close() async {
    await _isar.close();
  }
}
