import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/asa_exposure.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  String exposureTable = 'exposure_table';
  String colId = 'id';
  String colDate = 'date';
  String colDuration = 'duration';
  String colNotes = 'notes';

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'asa_exposures.db');
    final exposureDb =  await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return exposureDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $exposureTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDate TEXT, $colDuration TEXT, $colNotes TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getExposureMapList() async {
    Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(exposureTable);
    return result;
  }

  Future<int> insertExposure(AsaExposure exposure) async {
    Database db = await database;
    final int result =  await db.insert(exposureTable, exposure.toMap());
    return result;
  }

    // tietojen muokkaus
  Future<int> updateExposure(AsaExposure exposure) async {
    Database db = await database;
    final int result = await db.update(
      exposureTable,
      exposure.toMap(),
      where: '$colId = ?',
      whereArgs: [exposure.id],
    );
    return result;
  }

    //Tietojen poisto 
  Future<int> deleteExposure(int id) async {
    Database db = await database;
    final int result = await db.delete(
      exposureTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  

  

  

  

  
  
}
