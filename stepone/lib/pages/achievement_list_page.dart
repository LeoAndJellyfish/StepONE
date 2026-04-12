import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/category.dart';
import '../services/achievement_dao.dart';
import '../services/category_dao.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'achievement_form_page.dart';

class AchievementListPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const AchievementListPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<AchievementListPage> createState() => _AchievementListPageState();
}

class _AchievementListPageState extends State<AchievementListPage> {
  final AchievementDao _achievementDao = AchievementDao();
  final CategoryDao _categoryDao = CategoryDao();
  
  List<Achievement> _achievements = [];
  List<Category> _categories = [];
  Category? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final categories = await _categoryDao.getAll();
    List<Achievement> achievements;
    
    if (_selectedCategory != null) {
      achievements = await _achievementDao.getByCategory(_selectedCategory!.id!);
    } else if (_searchQuery.isNotEmpty) {
      achievements = await _achievementDao.search(_searchQuery);
    } else {
      achievements = await _achievementDao.getAll();
    }
    
    setState(() {
      _categories = categories;
      _achievements = achievements;
      _isLoading = false;
    });
  }

  Future<void> _deleteAchievement(Achievement achievement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${achievement.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _achievementDao.delete(achievement.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('成就已删除')),
        );
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  Color _getCategoryColor(int categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(
        name: '未分类',
        code: 'UNKNOWN',
        color: '#6B9FE8',
        createdAt: DateTime.now(),
      ),
    );
    return _parseColor(category.color);
  }

  String _getCategoryName(int categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(
        name: '未分类',
        code: 'UNKNOWN',
        createdAt: DateTime.now(),
      ),
    );
    return category.name;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? '所有成就'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _achievements.isEmpty
                    ? EmptyState(
                        title: '没有找到成就',
                        subtitle: _searchQuery.isNotEmpty 
                            ? '尝试使用其他关键词搜索'
                            : '点击右下角的按钮添加成就',
                        icon: Icons.search_off,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _achievements[index];
                            return Dismissible(
                              key: Key(achievement.id.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _deleteAchievement(achievement);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: AchievementCard(
                                title: achievement.title,
                                description: achievement.description,
                                category: _getCategoryName(achievement.categoryId),
                                date: achievement.achievementDate,
                                categoryColor: _getCategoryColor(achievement.categoryId),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AchievementFormPage(
                                        achievement: achievement,
                                      ),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AchievementFormPage(),
            ),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索成就...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadData();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        onSubmitted: (_) => _loadData(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('全部'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() => _selectedCategory = null);
                  _loadData();
                },
              ),
            );
          }
          
          final category = _categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: _selectedCategory?.id == category.id,
              selectedColor: _parseColor(category.color).withValues(alpha: 0.2),
              checkmarkColor: _parseColor(category.color),
              onSelected: (selected) {
                setState(() => _selectedCategory = selected ? category : null);
                _loadData();
              },
            ),
          );
        },
      ),
    );
  }
}
