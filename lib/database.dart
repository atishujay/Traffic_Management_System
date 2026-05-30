import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async{
    if(_db != null) return _db!;
    final path = join(await
    getDatabasesPath(), 'traffic_app.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
username TEXT UNIQUE NOT NULL,
password  TEXT NOT NULL,
points INTEGER NOT NULL DEFAULT 1000
);
''');
await db.execute('''
CREATE TABLE violations(
id INTEGER PRIMARY KEY AUTOINCREMENT,
username TEXT NOT NULL,
place TEXT,
plate TEXT,
points INTEGER,
timestamp TEXT
);
''');
  }
  Future<void> addUser(String username,
  String password) async {
    final db = await database;
    await db.insert('users',{
      'username': username,
      'password': password,
      'points': 1000
});
}
  Future<bool> validateUser(String username, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty;
  }
  Future<int> getUserPoints(String usrname) async{
    final db = await database;
    final res = await db.query(
      'users',
      columns: ['points'],
      where: 'username = ?',
      whereArgs: [usrname],
    );
    return res.isNotEmpty ? res.first['points'] as int : 1000;
  }
  Future<List<Map<String,dynamic>>> getViolations(String username) async {
    final db = await database;
    return await db.query(
      'violations',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'timestamp DESC',
    );
  }
  Future<void> addViolation(
    String username,
    String place,
    String plate,
    int points,
    String timestamp,
  ) async {
    final db = await database;

    //check if user exists
    final userExists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM users WHERE username = ?',
      [username],
    ))! >0;

    if(!userExists){
      //inserting user if not founed , maybe with default password
      await db.insert('users', {
        'username': username,
        'password': 'default',
        'points': points,
      });
    } else {
      await db.update(
        'users',
        {'points': points},
        where: 'username = ?',
        whereArgs: [username],
      );
    }

    await db.update(
      'users',
      {'points': points},
      where: 'username = ?',
      whereArgs: [username],
    );
    await db.insert('violations',{
      'username': username,
      'place': place,
      'plate': plate,
      'points': points,
      'timestamp': timestamp,
    });
  }
}