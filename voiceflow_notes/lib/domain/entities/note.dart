import 'package:equatable/equatable.dart';

/// Domain entity for a Note
/// Represents a text note with metadata and trash state
class Note extends Equatable {
  final String id;                    // UUID for cross-platform sync
  final String title;                  // Note title
  final String content;                // Note content (transcribed text)
  final DateTime createdAt;            // Creation timestamp
  final DateTime updatedAt;            // Last modification timestamp
  final bool isSynced;                 // Cloud sync status
  final String? userId;                // Owner (null for local-only)

  // Trash fields
  final bool isDeleted;                // Soft delete flag
  final DateTime? deletedAt;             // When moved to trash (null if not deleted)

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Check if note should be auto-deleted (after 15 days in trash)
  bool get shouldBePermanentlyDeleted {
    if (!isDeleted || deletedAt == null) return false;
    final daysInTrash = DateTime.now().difference(deletedAt!).inDays;
    return daysInTrash >= 15;
  }

  /// Days remaining before permanent deletion
  int get daysRemainingInTrash {
    if (!isDeleted || deletedAt == null) return 0;
    final daysInTrash = DateTime.now().difference(deletedAt!).inDays;
    return (15 - daysInTrash).clamp(0, 15);
  }

  /// Create empty note with new ID
  factory Note.empty() {
    final now = DateTime.now();
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Convert to trash state
  Note toTrash() {
    return copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
    );
  }

  /// Restore from trash
  Note restore() {
    return copyWith(
      isDeleted: false,
      deletedAt: null,
    );
  }

  String get preview {
    if (content.isEmpty) return '';
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length > 100) {
      return '${firstLine.substring(0, 100)}...';
    }
    return firstLine;
  }

  /// Check if note is empty
  bool get isEmpty => title.isEmpty && content.isEmpty;

  /// Create copy with modifications
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, title, content, createdAt, updatedAt, isSynced, userId,
    isDeleted, deletedAt,
  ];
}
