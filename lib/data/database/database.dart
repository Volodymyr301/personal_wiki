import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get parentId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
}

@DriftDatabase(tables: [Categories, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Categories operations
  Future<List<Category>> getAllCategories() => select(categories).get();
  
  Future<List<Category>> getSubcategories(int parentId) =>
      (select(categories)..where((c) => c.parentId.equals(parentId))).get();
  
  Future<int> createCategory(CategoriesCompanion category) =>
      into(categories).insert(category);
  
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);
  
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // Notes operations
  Future<List<Note>> getNotesForCategory(int categoryId) =>
      (select(notes)..where((n) => n.categoryId.equals(categoryId))).get();
  
  Future<Note> getNote(int id) =>
      (select(notes)..where((n) => n.id.equals(id))).getSingle();
  
  Future<int> createNote(NotesCompanion note) =>
      into(notes).insert(note);
  
  Future<bool> updateNote(Note note) =>
      update(notes).replace(note);
  
  Future<int> deleteNote(int id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();
}

DatabaseConnection _openConnection() => createDriftDatabaseConnection();
