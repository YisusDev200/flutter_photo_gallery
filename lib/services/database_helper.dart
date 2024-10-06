import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'photos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        photo BLOB
      )
    ''');
  }

  Future<int> insertPhoto(Map<String, dynamic> photo) async {
    final db = await database;
    return await db.insert('photos', photo);
  }

  Future<List<Map<String, dynamic>>> getPhotos() async {
    final db = await database;
    return await db.query('photos');
  }

  Future<void> deleteAllPhotos() async {
    final db = await database;
    await db.delete('photos');
  }

  // Método para eliminar una foto por ID
  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete(
      'photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
