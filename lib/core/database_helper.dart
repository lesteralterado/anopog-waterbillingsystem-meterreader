import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'meter_reader.db';
  static const _databaseVersion = 1;

  // Table names
  static const tablePendingReadings = 'pending_readings';

  // Column names
  static const columnId = 'id';
  static const columnUserId = 'user_id';
  static const columnReadingValue = 'reading_value';
  static const columnReadingDate = 'reading_date';
  static const columnImagePath = 'image_path';
  static const columnLatitude = 'latitude';
  static const columnLongitude = 'longitude';
  static const columnAccuracy = 'accuracy';
  static const columnNotes = 'notes';
  static const columnCreatedAt = 'created_at';
  static const columnStatus = 'status'; // 'pending', 'uploading', 'failed'

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePendingReadings (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserId INTEGER NOT NULL,
        $columnReadingValue REAL NOT NULL,
        $columnReadingDate TEXT,
        $columnImagePath TEXT,
        $columnLatitude REAL,
        $columnLongitude REAL,
        $columnAccuracy REAL,
        $columnNotes TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnStatus TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  Future<int> insertPendingReading(Map<String, dynamic> reading) async {
    Database db = await database;
    return await db.insert(tablePendingReadings, reading);
  }

  Future<List<Map<String, dynamic>>> getPendingReadings() async {
    Database db = await database;
    return await db.query(
      tablePendingReadings,
      where: '$columnStatus = ?',
      whereArgs: ['pending'],
      orderBy: '$columnCreatedAt ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllPendingReadings() async {
    Database db = await database;
    return await db.query(
      tablePendingReadings,
      orderBy: '$columnCreatedAt ASC',
    );
  }

  Future<int> updateReadingStatus(int id, String status) async {
    Database db = await database;
    return await db.update(
      tablePendingReadings,
      {columnStatus: status},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReading(int id) async {
    Database db = await database;
    return await db.delete(
      tablePendingReadings,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPendingReadingsCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tablePendingReadings WHERE $columnStatus = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearOldReadings({int daysOld = 30}) async {
    Database db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();
    await db.delete(
      tablePendingReadings,
      where: '$columnCreatedAt < ? AND $columnStatus != ?',
      whereArgs: [cutoffDate, 'pending'],
    );
  }
}