import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  final String tableName = 'users';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password TEXT NOT NULL)');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    await db.insert(tableName, user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(
      tableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (users.isNotEmpty) {
      return users.first;
    } else {
      return null;
    }
  }
}
