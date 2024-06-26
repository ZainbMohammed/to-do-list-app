import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note.dart';
import '../model/users2.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 20, onCreate: _createDB,onUpgrade: _upgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.isImportant} $boolType,
  ${NoteFields.number} $integerType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType
  )
''');
}
Future _upgrade(Database db, int oldVersion,int newVersion) async{
  if(oldVersion >=20){
    try {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      _id INTEGER PRIMARY KEY AUTOINCREMENT,
      userName TEXT NOT NULL,
      userPassword TEXT NOT NULL
    )
  ''');
    print('user table created successful');

  
} catch (e) {
  print('Error : $e');
}

  }
}

  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }
  // create user 
  // Future<User> createUser(User user) async {
  //   final db = await instance.database;
  //   final id = await db.insert(tableUsers, user.toJson());
  //   return user.copy(id: id);
  // }
// Future<User> createUser(User user) async {
//   final db = await instance.database;

//   try {
//     final id = await db.insert(tableUsers, user.toJson());
//     return user.copy(userId: id); // Assuming you have a copy method in your User class
//   } catch (e) {
//     print('Error creating user: $e');
//     throw Exception('Failed to create user');
//   }
// }
Future<void> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    await db.insert(tableUsers, user);
  }
Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // read user
  // Future<User> readUser(int userId) async {
  //   final db = await instance.database;

  //   final maps = await db.query(
  //     tableUsers,
  //     where: 'username = ?',
  //     whereArgs: [userId],
  //   );

  //   if (maps.isNotEmpty) {
  //     return User.fromJson(maps.first);
  //   } else {
  //     throw Exception('ID $userId not found');
  //   }
  // }
Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(
      tableUsers,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (users.isNotEmpty) {
      return users.first;
    } else {
      return null;
    }
}
Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final orderBy = '${NoteFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
}

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
