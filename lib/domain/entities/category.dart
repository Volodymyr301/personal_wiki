import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final DateTime createdAt;
  final List<CategoryEntity> subcategories;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    this.subcategories = const [],
  });

  @override
  List<Object?> get props => [id, name, parentId, createdAt, subcategories];

  CategoryEntity copyWith({
    int? id,
    String? name,
    int? parentId,
    DateTime? createdAt,
    List<CategoryEntity>? subcategories,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}
