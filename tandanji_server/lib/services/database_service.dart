import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late Database _db;

  Future<void> init() async {
    // 데이터 디렉토리 생성
    final dbDir = Directory('data');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    _db = sqlite3.open('data/tandanji.db');
    await _createTables();
    print('✅ SQLite 데이터베이스 연결 완료');
  }

  Future<void> _createTables() async {
    // Users 테이블
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        weight REAL,
        height REAL,
        age INTEGER,
        diet_plan TEXT DEFAULT 'diet',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Body Stats 테이블
    _db.execute('''
      CREATE TABLE IF NOT EXISTS body_stats (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        weight REAL NOT NULL,
        body_fat REAL,
        muscle_mass REAL,
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Meals 테이블
    _db.execute('''
      CREATE TABLE IF NOT EXISTS meals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        meal_number INTEGER NOT NULL,
        foods TEXT NOT NULL,
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    print('✅ 테이블 생성 완료');
  }

  Database get db => _db;

  void close() {
    _db.dispose();
  }
}