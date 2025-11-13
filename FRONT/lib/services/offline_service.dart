import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static Database? _database;
  static const String _dbName = 'quiz_offline.db';
  static const String _countriesTable = 'countries';
  static const String _scoresTable = 'offline_scores';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_countriesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        capital TEXT,
        region TEXT,
        subregion TEXT,
        population INTEGER,
        area REAL,
        flag_url TEXT,
        languages TEXT,
        currencies TEXT,
        borders TEXT,
        timezones TEXT,
        continent TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_scoresTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        game_type TEXT NOT NULL,
        date TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> cacheCountries(List<dynamic> countries) async {
    final db = await database;
    await db.delete(_countriesTable);
    
    for (var country in countries) {
      await db.insert(_countriesTable, {
        'name': country['name']['common'] ?? '',
        'capital': country['capital']?.join(', ') ?? '',
        'region': country['region'] ?? '',
        'subregion': country['subregion'] ?? '',
        'population': country['population'] ?? 0,
        'area': country['area'] ?? 0.0,
        'flag_url': country['flags']?['png'] ?? '',
        'languages': jsonEncode(country['languages'] ?? {}),
        'currencies': jsonEncode(country['currencies'] ?? {}),
        'borders': jsonEncode(country['borders'] ?? []),
        'timezones': jsonEncode(country['timezones'] ?? []),
        'continent': country['continents']?.first ?? '',
      });
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_cache_update', DateTime.now().toIso8601String());
  }

  static Future<List<Map<String, dynamic>>> getCachedCountries() async {
    final db = await database;
    return await db.query(_countriesTable);
  }

  static Future<List<Map<String, dynamic>>> getCountriesByContinent(String continent) async {
    final db = await database;
    return await db.query(
      _countriesTable,
      where: 'continent = ?',
      whereArgs: [continent],
    );
  }

  static Future<void> saveOfflineScore(int score, String gameType) async {
    final db = await database;
    await db.insert(_scoresTable, {
      'score': score,
      'game_type': gameType,
      'date': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getOfflineScores() async {
    final db = await database;
    return await db.query(_scoresTable, orderBy: 'date DESC');
  }

  static Future<bool> needsCacheUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_cache_update');
    if (lastUpdate == null) return true;
    
    final lastUpdateDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    return now.difference(lastUpdateDate).inDays > 7;
  }

  static Future<void> syncOfflineScores() async {
    final db = await database;
    final unsyncedScores = await db.query(
      _scoresTable,
      where: 'synced = ?',
      whereArgs: [0],
    );

    for (var score in unsyncedScores) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        if (token != null) {
          await http.post(
            Uri.parse('http://localhost:5000/api/score'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'userId': 3,
              'score': score['score'],
              'gameType': score['game_type'],
            }),
          );

          await db.update(
            _scoresTable,
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [score['id']],
          );
        }
      } catch (e) {
        print('Erreur lors de la synchronisation: $e');
      }
    }
  }
}