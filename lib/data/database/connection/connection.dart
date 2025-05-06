import 'web.dart' if (dart.library.io) 'native.dart';
import 'package:drift/drift.dart';

DatabaseConnection createDriftDatabaseConnection() {
  return createConnection();
}
