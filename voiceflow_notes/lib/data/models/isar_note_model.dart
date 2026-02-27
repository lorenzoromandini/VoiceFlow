import 'package:isar/isar.dart';
import '../../domain/entities/note.dart';

part 'isar_note_model.g.dart';

@collection
class IsarNoteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;

  Note toEntity() => Note(
    id: uuid,
    title: title,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isSynced: isSynced,
  );

  static IsarNoteModel fromEntity(Note note) => IsarNoteModel()
    ..uuid = note.id
    ..title = note.title
    ..content = note.content
    ..createdAt = note.createdAt
    ..updatedAt = note.updatedAt
    ..isSynced = note.isSynced;
}
