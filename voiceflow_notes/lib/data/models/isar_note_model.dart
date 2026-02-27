import 'package:isar/isar.dart';
import '../../domain/entities/note.dart';

part 'isar_note_model.g.dart';

/// Isar database model for Note
/// Maps to Note domain entity
@collection
class IsarNoteModel {
  /// Primary key (auto-increment)
  Id id = Isar.autoIncrement;

  /// UUID for cross-platform identification
  @Index(unique: true, replace: true)
  late String uuid;

  /// Note title
  late String title;

  /// Note content
  late String content;

  /// Creation timestamp (indexed for sorting)
  @Index()
  late DateTime createdAt;

  /// Last modification timestamp (indexed for sorting)
  @Index()
  late DateTime updatedAt;

  /// Cloud sync status
  late bool isSynced;

  /// Owner user ID (null for local-only notes)
  String? userId;

  /// Soft delete flag
  late bool isDeleted;

  /// When moved to trash (null if not deleted)
  @Index()
  DateTime? deletedAt;

  /// Convert to domain entity
  Note toEntity() => Note(
    id: uuid,
    title: title,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isSynced: isSynced,
    userId: userId,
    isDeleted: isDeleted,
    deletedAt: deletedAt,
  );

  /// Create from domain entity
  static IsarNoteModel fromEntity(Note note) => IsarNoteModel()
    ..uuid = note.id
    ..title = note.title
    ..content = note.content
    ..createdAt = note.createdAt
    ..updatedAt = note.updatedAt
    ..isSynced = note.isSynced
    ..userId = note.userId
    ..isDeleted = note.isDeleted
    ..deletedAt = note.deletedAt;

  /// Create copy with modifications
  IsarNoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return IsarNoteModel()
      ..id = id
      ..uuid = uuid
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..createdAt = createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..isSynced = isSynced ?? this.isSynced
      ..userId = userId ?? this.userId
      ..isDeleted = isDeleted ?? this.isDeleted
      ..deletedAt = deletedAt ?? this.deletedAt;
  }
}
