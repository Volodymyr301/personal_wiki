import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/note.dart';

class WikiRepository {
  final AppDatabase _database;

  WikiRepository(this._database);

  // Category operations
  Future<List<CategoryEntity>> getAllCategories() async {
    final categories = await _database.getAllCategories();
    return _buildCategoryTree(categories);
  }

  Future<int> createCategory(String name, int? parentId) {
    return _database.createCategory(
      CategoriesCompanion.insert(
        name: name,
        parentId: Value(parentId),
      ),
    );
  }

  Future<bool> updateCategory(CategoryEntity category) {
    return _database.updateCategory(
      Category(
        id: category.id,
        name: category.name,
        parentId: category.parentId,
        createdAt: category.createdAt,
      ),
    );
  }

  Future<int> deleteCategory(int id) {
    return _database.deleteCategory(id);
  }

  // Note operations
  Future<List<NoteEntity>> getNotesForCategory(int categoryId) async {
    final notes = await _database.getNotesForCategory(categoryId);
    return notes.map((note) => NoteEntity(
      id: note.id,
      title: note.title,
      content: note.content,
      categoryId: note.categoryId,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    )).toList();
  }

  Future<NoteEntity> getNote(int id) async {
    final note = await _database.getNote(id);
    return NoteEntity(
      id: note.id,
      title: note.title,
      content: note.content,
      categoryId: note.categoryId,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  Future<int> createNote(String title, String content, int categoryId) {
    return _database.createNote(
      NotesCompanion.insert(
        title: title,
        content: content,
        categoryId: categoryId,
      ),
    );
  }

  Future<bool> updateNote(NoteEntity note) {
    return _database.updateNote(
      Note(
        id: note.id,
        title: note.title,
        content: note.content,
        categoryId: note.categoryId,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<int> deleteNote(int id) {
    return _database.deleteNote(id);
  }

  // Helper method to build category tree
  List<CategoryEntity> _buildCategoryTree(List<Category> flatCategories) {
    final Map<int?, List<CategoryEntity>> categoryMap = {};
    
    // Convert all categories to CategoryEntity
    final List<CategoryEntity> entities = flatCategories.map((cat) => 
      CategoryEntity(
        id: cat.id,
        name: cat.name,
        parentId: cat.parentId,
        createdAt: cat.createdAt,
      )
    ).toList();

    // Group categories by parentId
    for (var category in entities) {
      categoryMap.putIfAbsent(category.parentId, () => []);
      categoryMap[category.parentId]!.add(category);
    }

    // Build tree starting from root categories (parentId == null)
    return _buildSubtree(categoryMap, null);
  }

  List<CategoryEntity> _buildSubtree(Map<int?, List<CategoryEntity>> categoryMap, int? parentId) {
    final List<CategoryEntity> result = [];
    final List<CategoryEntity>? categories = categoryMap[parentId];
    
    if (categories == null) return result;

    for (var category in categories) {
      final subcategories = _buildSubtree(categoryMap, category.id);
      result.add(category.copyWith(subcategories: subcategories));
    }

    return result;
  }
}
