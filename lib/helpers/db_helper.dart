/*
 * SQFlite Helper class  
 */
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static final _dbName = "swizard.db";
  static final _dbVersion = 1;

  static final tableUserData = 'user_data';

  static final columnKey = 'key';
  static final columnValue = 'value';

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, _dbName),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $tableUserData($columnKey TEXT PRIMARY KEY, $columnValue TEXT NULL)');
    }, version: _dbVersion);
  }

  static Future<void> insert(String table, Map<String, Object> dataRow) async {
    final db = await DBHelper.database();
    await db.insert(table, dataRow,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getDataRows(String table) async {
    final db = await DBHelper.database();
    return await db.query(table);
  }

  static Future<int?> queryRowCount(String table) async {
    final db = await DBHelper.database();
    return sql.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  static Future<int> update(String table, Map<String, dynamic> dataRow) async {
    final db = await DBHelper.database();
    String key = dataRow[columnKey];
    return await db
        .update(table, dataRow, where: '$columnKey = ?', whereArgs: [key]);
  }

  Future<int> delete(String table, String key) async {
    final db = await DBHelper.database();
    return await db.delete(table, where: '$columnKey = ?', whereArgs: [key]);
  }
}
