import 'package:flutter_crud/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static Database? _db;
  DatabaseService._constructor();

  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";


  Future<Database> database() async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    // await deleteDatabase(await getDatabasesPath());

    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_tasksTableName (
            $_tasksIdColumnName INTEGER PRIMARY KEY, 
            $_tasksContentColumnName TEXT NOT NULL,
            $_tasksStatusColumnName INTEGER NOT NULL
          )
        ''');
      },
    );
    return database;
  }

  void addTask(String content) async {
    final db = await database();
    await db.insert(
      _tasksTableName,
      {_tasksContentColumnName: content, _tasksStatusColumnName: 0},
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database();
    final data = await db.query(_tasksTableName);
    List<Task> tasks = data
        .map(
          (task) => Task(
            id: task["id"] as int,
            status: task["status"] as int,
            content: task["content"] as String,
          ),
        )
        .toList();
    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database();
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void deleteTask(int id) async {
    final db = await database();
    await db.delete(_tasksTableName, where: 'id = ?', whereArgs: [id]);
  }
}
