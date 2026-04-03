import 'package:sqflite/sqflite.dart';
import '../models/achievement.dart';
import 'database_helper.dart';

class AchievementDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Achievement achievement) async {
    final db = await _dbHelper.database;
    return await db.insert('achievements', achievement.toMap());
  }

  Future<List<Achievement>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      orderBy: 'achievement_date DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  Future<Achievement?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Achievement.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Achievement>> getByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'achievement_date DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  Future<List<Achievement>> getByType(String achievementType) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'achievement_type = ?',
      whereArgs: [achievementType],
      orderBy: 'achievement_date DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  Future<List<Achievement>> search(String keyword) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'title LIKE ? OR description LIKE ? OR organization LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'achievement_date DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  Future<int> update(Achievement achievement) async {
    final db = await _dbHelper.database;
    return await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM achievements');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCountByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM achievements WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getCountByType() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT achievement_type, COUNT(*) as count FROM achievements GROUP BY achievement_type',
    );
    final Map<String, int> countMap = {};
    for (final row in result) {
      countMap[row['achievement_type'] as String] = row['count'] as int;
    }
    return countMap;
  }
}
