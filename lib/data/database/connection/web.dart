import 'package:drift/drift.dart';
import 'package:drift/web.dart';

DatabaseConnection createConnection() {
  return DatabaseConnection(WebDatabase('wiki_db'));
}
