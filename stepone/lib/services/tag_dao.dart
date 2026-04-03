import '../models/tag.dart';
import 'database_helper.dart';

class TagDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Tag tag) async {
    final db = await _dbHelper.database;
    return await db.insert('tags', tag.toMap());
  }

  Future<List<Tag>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  Future<Tag?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tag.fromMap(maps.first);
    }
    return null;
  }

  Future<Tag?> getByCode(String code) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isNotEmpty) {
      return Tag.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Tag>> getTagsForAchievement(int achievementId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN achievement_tags at ON t.id = at.tag_id
      WHERE at.achievement_id = ?
      ORDER BY t.created_at ASC
    ''', [achievementId]);
    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  Future<void> addTagToAchievement(int achievementId, int tagId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'achievement_tags',
      {'achievement_id': achievementId, 'tag_id': tagId},
    );
  }

  Future<void> removeTagFromAchievement(int achievementId, int tagId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'achievement_tags',
      where: 'achievement_id = ? AND tag_id = ?',
      whereArgs: [achievementId, tagId],
    );
  }

  Future<int> update(Tag tag) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
