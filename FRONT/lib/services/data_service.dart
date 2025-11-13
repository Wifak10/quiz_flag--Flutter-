import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataService {
  static const String _countriesKey = 'cached_countries';
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'countries.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE countries(
            id INTEGER PRIMARY KEY,
            name TEXT,
            capital TEXT,
            region TEXT,
            flag_url TEXT,
            population INTEGER,
            area REAL,
            languages TEXT,
            currencies TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  static Future<List<dynamic>> fetchCountries() async {
    try {
      // Essayer de récupérer depuis l'API
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags,region,capital,population,area,languages,currencies'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        await _cacheCountries(data);
        await _saveToDatabase(data);
        return data;
      }
    } catch (e) {
      print('Erreur API: $e');
    }

    // Fallback vers le cache local
    return await _getCachedCountries();
  }

  static Future<void> _cacheCountries(List<dynamic> countries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countriesKey, jsonEncode(countries));
  }

  static Future<List<dynamic>> _getCachedCountries() async {
    try {
      // Essayer SharedPreferences d'abord
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_countriesKey);
      if (cachedData != null) {
        return jsonDecode(cachedData) as List;
      }

      // Fallback vers la base de données
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('countries');
      return maps.map((map) => jsonDecode(map['data'])).toList();
    } catch (e) {
      print('Erreur cache: $e');
      return [];
    }
  }

  static Future<void> _saveToDatabase(List<dynamic> countries) async {
    final db = await database;
    await db.delete('countries');
    
    for (var country in countries) {
      await db.insert('countries', {
        'name': country['name']?['common'] ?? '',
        'capital': country['capital']?.isNotEmpty == true ? country['capital'][0] : '',
        'region': country['region'] ?? '',
        'flag_url': country['flags']?['png'] ?? '',
        'population': country['population'] ?? 0,
        'area': country['area'] ?? 0.0,
        'languages': jsonEncode(country['languages'] ?? {}),
        'currencies': jsonEncode(country['currencies'] ?? {}),
        'data': jsonEncode(country),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getCountriesByRegion(String region) async {
    final db = await database;
    return await db.query('countries', where: 'region = ?', whereArgs: [region]);
  }

  static Future<Map<String, dynamic>?> getCountryByName(String name) async {
    final db = await database;
    final result = await db.query('countries', where: 'name = ?', whereArgs: [name], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }
}