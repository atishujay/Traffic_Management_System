import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
    static final AuthService instance = AuthService._init();
    static Database? _database;

    AuthService._init();

    Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDB('users.db');
        return _database!;
    }

    Future<Database> _initDB(String fileName) async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, fileName);
        return await openDatabase(path, version: 1, onCreate: _createDB);
    }

    Future<void> _createDB(Database db, int version) async {
        await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 1000
      )
    ''');
        // Insert a default user for testing
        await _insertDefaultUser(db);
    }

    Future<void> _insertDefaultUser(Database db) async {
        await db.insert('users', {
            'username': 'arun',
            'password': 'yadav',
            'points': 1000,
        });
    }

    Future<bool> registerUser(String username, String password) async {
        final db = await instance.database;
        try {
            await db.insert('users', {
                'username': username,
                'password': password,
                'points': 1000,
            });
            return true;
        } catch (e) {
            return false;
        }
    }

    Future<bool> loginUser(String username, String password) async {
        // Check against the hardcoded user
        if (username == 'arun' && password == 'yadav' || username == 'atishu' && password == 'rajput') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('username', username);
            return true;
        }

        // Also check against database users.
        final db = await instance.database;
        final result = await db.query(
            'users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
        if (result.isNotEmpty) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('username', username);
            return true;
        }

        return false;
    }

    Future<String?> getCurrentUser() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.getString('username');
    }
}