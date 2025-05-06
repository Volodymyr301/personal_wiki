import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

DatabaseConnection createConnection() {
  return DatabaseConnection(LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wiki.db'));
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return NativeDatabase(file, setup: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    });
  }));
}
