import 'package:aplikasi_todo/todo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    io.Directory documentsDirectory = await getApplicationCacheDirectory();
    String path = join(
      documentsDirectory.path,
      'todolist.db',
    );
    var theDb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE 
        IF NOT EXISTS todos 
        (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          completed INTEGER NOT NULL
        )   
        ''');
  }

  Future<List<Todo>> getAllTodos() async {
    var dbClient = await db;
    var todos = await dbClient!.query('todos');
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<Todo> getTodoById(int id) async {
    var dbClient = await db;
    var todo = await dbClient!.query('todos', where: 'id = ?', whereArgs: [id]);
    return todo.map((todo) => Todo.fromMap(todo)).single;
  }

  Future<List<Todo>> getTodoByTitle(String title) async {
    var dbClient = await db;
    final keyword =
        '%${title.toLowerCase()}%'; // Add wildcards and convert to lowercase
    var todo = await dbClient!.query(
      'todos',
      where: 'LOWER(title) LIKE ?', // Make the search case-insensitive
      whereArgs: [keyword],
    );
    return todo.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<int> insertTodo(Todo todo) async {
    var dbClient = await db;
    return await dbClient!.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTodo(Todo todo) async {
    var dbClient = await db;
    return await dbClient!
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future deleteAllTodo() async {
    var dbClient = await db;
    return await dbClient!
        .delete('todos', where: 'completed = ?', whereArgs: [true]);
  }
}
