import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final int id;
  final String title;
  final String content;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [id, title, content, categoryId, createdAt, updatedAt];

  NoteEntity copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
