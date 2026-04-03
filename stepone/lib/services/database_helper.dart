import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'stepone.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        color TEXT NOT NULL DEFAULT '#6B9FE8',
        icon TEXT NOT NULL DEFAULT 'emoji_events',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        achievement_type TEXT NOT NULL DEFAULT 'award',
        achievement_date INTEGER NOT NULL,
        award_level TEXT,
        organization TEXT,
        certificate_number TEXT,
        is_collective INTEGER DEFAULT 0,
        is_leader INTEGER DEFAULT 0,
        participant_count INTEGER,
        image_path TEXT,
        file_path TEXT,
        remarks TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievement_tags (
        achievement_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (achievement_id, tag_id),
        FOREIGN KEY (achievement_id) REFERENCES achievements (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE file_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        achievement_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        mime_type TEXT,
        uploaded_at INTEGER NOT NULL,
        FOREIGN KEY (achievement_id) REFERENCES achievements (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_achievements_category_id ON achievements(category_id)');
    await db.execute('CREATE INDEX idx_achievements_achievement_date ON achievements(achievement_date)');
    await db.execute('CREATE INDEX idx_file_attachments_achievement_id ON file_attachments(achievement_id)');

    await _insertDefaultCategories(db);
    await _insertDefaultTags(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final defaultCategories = [
      {
        'name': '获奖荣誉',
        'code': 'AWARD',
        'description': '各类竞赛获奖、荣誉称号等',
        'color': '#FFB6C1',
        'icon': 'emoji_events',
        'created_at': now,
      },
      {
        'name': '专利成果',
        'code': 'PATENT',
        'description': '发明专利、实用新型专利、外观设计专利等',
        'color': '#98D8C8',
        'icon': 'lightbulb',
        'created_at': now,
      },
      {
        'name': '项目经历',
        'code': 'PROJECT',
        'description': '科研项目、创业项目、实践项目等',
        'color': '#B8E6FF',
        'icon': 'work',
        'created_at': now,
      },
      {
        'name': '论文发表',
        'code': 'PAPER',
        'description': '学术论文、会议论文等',
        'color': '#DDA0DD',
        'icon': 'article',
        'created_at': now,
      },
      {
        'name': '技能证书',
        'code': 'CERTIFICATE',
        'description': '职业资格证书、技能证书等',
        'color': '#F0E68C',
        'icon': 'workspace_premium',
        'created_at': now,
      },
      {
        'name': '社会实践',
        'code': 'PRACTICE',
        'description': '实习经历、志愿服务、社会实践等',
        'color': '#E6E6FA',
        'icon': 'volunteer_activism',
        'created_at': now,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _insertDefaultTags(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final defaultTags = [
      {'name': '国家级', 'code': 'NATIONAL', 'description': '国家级别', 'created_at': now},
      {'name': '省级', 'code': 'PROVINCIAL', 'description': '省份级别', 'created_at': now},
      {'name': '市级', 'code': 'CITY', 'description': '城市级别', 'created_at': now},
      {'name': '校级', 'code': 'SCHOOL', 'description': '学校级别', 'created_at': now},
      {'name': '一等奖', 'code': 'FIRST_PRIZE', 'description': '一等奖项', 'created_at': now},
      {'name': '二等奖', 'code': 'SECOND_PRIZE', 'description': '二等奖项', 'created_at': now},
      {'name': '三等奖', 'code': 'THIRD_PRIZE', 'description': '三等奖项', 'created_at': now},
      {'name': '优秀', 'code': 'EXCELLENT', 'description': '优秀等级', 'created_at': now},
    ];

    for (final tag in defaultTags) {
      await db.insert('tags', tag);
    }
  }
}
