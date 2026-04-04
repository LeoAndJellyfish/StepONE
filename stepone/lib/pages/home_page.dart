import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/achievement.dart';
import '../models/category.dart';
import '../services/achievement_dao.dart';
import '../services/category_dao.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'achievement_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AchievementDao _achievementDao = AchievementDao();
  final CategoryDao _categoryDao = CategoryDao();
  final TextEditingController _searchController = TextEditingController();

  List<Achievement> _recentAchievements = [];
  List<Achievement> _allAchievements = [];
  List<Category> _categories = [];
  int _totalAchievements = 0;
  bool _isLoading = true;
  
  String _activeFilter = '全部';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final achievements = await _achievementDao.getAll();
    final categories = await _categoryDao.getAll();
    final total = await _achievementDao.getCount();

    setState(() {
      _allAchievements = achievements;
      _recentAchievements = _applyFilter(achievements);
      _categories = categories;
      _totalAchievements = total;
      _isLoading = false;
    });
  }

  List<Achievement> _applyFilter(List<Achievement> achievements) {
    var filtered = achievements;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(query) ||
               a.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_activeFilter == '最近') {
      filtered = filtered.take(10).toList();
    } else if (_activeFilter == '分类' && _selectedCategoryId != null) {
      filtered = filtered.where((a) => a.categoryId == _selectedCategoryId).toList();
    }

    return filtered;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _activeFilter = filter;
      if (filter != '分类') {
        _selectedCategoryId = null;
      }
      _recentAchievements = _applyFilter(_allAchievements);
    });
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _activeFilter = '分类';
      _recentAchievements = _applyFilter(_allAchievements);
    });
  }

  Future<void> _navigateToAddAchievement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementFormPage(),
      ),
    );
    _loadData();
  }

  Future<void> _navigateToEditAchievement(Achievement achievement) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementFormPage(
          achievement: achievement,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _showCategoryFilterDialog() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('还没有分类，请先创建分类'),
          backgroundColor: Colors.transparent,
        ),
      );
      return;
    }

    final selectedCategory = await showDialog<Category>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('选择分类'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ListTile(
                leading: Icon(
                  _getIconData(category.icon),
                  color: _parseColor(category.color),
                ),
                title: Text(category.name),
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCategory != null) {
      _onCategorySelected(selectedCategory!.id);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'work':
        return Icons.work;
      case 'article':
        return Icons.article;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/zzSQs.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white70))
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeroSection(),
                      ),
                      SliverToBoxAdapter(
                        child: _buildBottomPanel(),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AchievementFormPage(),
            ),
          );
          _loadData();
        },
        backgroundColor: Colors.white.withOpacity(0.15),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white70),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'StepONE',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 52,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.95),
                  letterSpacing: 3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'The ',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.75),
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'modern, native, privacy-first',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'achievement tracker for you.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Column(
          children: [
            _buildPanelHeader(),
            _buildPanelContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showSearchDialog(),
            child: Icon(Icons.search_rounded, size: 20, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showSearchDialog(),
              child: Text(
                _searchController.text.isEmpty ? '搜索成就...' : _searchController.text,
                style: TextStyle(
                  fontSize: 14,
                  color: _searchController.text.isEmpty 
                      ? Colors.white.withOpacity(0.45) 
                      : Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _buildChip('全部', _activeFilter == '全部'),
          _buildChip('分类', _activeFilter == '分类'),
          _buildChip('最近', _activeFilter == '最近'),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 20, color: Colors.white.withOpacity(0.5)),
            onPressed: _navigateToAddAchievement,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索成就...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'search'),
            child: const Text('搜索'),
          ),
        ],
      ),
    );

    if (result == 'search') {
      setState(() {
        _recentAchievements = _applyFilter(_allAchievements);
      });
    }
  }

  Widget _buildChip(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          if (label == '分类' && isActive) {
            _showCategoryFilterDialog();
          } else {
            _onFilterChanged(label);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _getChipColor(label),
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.5),
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChipColor(String label) {
    switch (label) {
      case '全部': return AppTheme.primaryColor;
      case '分类': return AppTheme.secondaryColor;
      case '最近': return AppTheme.accentColor;
      default: return Colors.white;
    }
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

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  Widget _buildPanelContent() {
    return Column(
      children: [
        Divider(height: 1, thickness: 0.5, color: Colors.white.withOpacity(0.08)),
        _buildStatsRow(),
        if (_activeFilter == '分类') _buildCategoriesRow(),
        _buildRecentList(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: DarkGlassCard(
              child: Column(
                children: [
                  Text(
                    '$_totalAchievements',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '总成就数',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DarkGlassCard(
              child: Column(
                children: [
                  Text(
                    '${_categories.length}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '分类数',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 130,
              child: DarkCategoryCard(
                name: category.name,
                icon: category.icon,
                color: _parseColor(category.color),
                isSelected: isSelected,
                onTap: () => _onCategorySelected(category.id!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentList() {
    if (_recentAchievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: DarkEmptyState(
          title: _searchController.text.isNotEmpty ? '没有找到匹配的成就' : '还没有成就',
          subtitle: _searchController.text.isNotEmpty 
              ? '尝试其他搜索条件或清除搜索' 
              : '点击右下角按钮添加你的第一个成就',
          action: _searchController.text.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _onFilterChanged('全部');
                  },
                  child: const Text('清除搜索'),
                )
              : null,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _recentAchievements.length,
      itemBuilder: (context, index) {
        final achievement = _recentAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DarkAchievementCard(
            title: achievement.title,
            description: achievement.description,
            category: _getCategoryName(achievement.categoryId),
            date: achievement.achievementDate,
            categoryColor: _getCategoryColor(achievement.categoryId),
            onTap: () => _navigateToEditAchievement(achievement),
          ),
        );
      },
    );
  }
}
