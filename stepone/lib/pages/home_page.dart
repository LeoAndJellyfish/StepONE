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

  List<Achievement> _recentAchievements = [];
  List<Category> _categories = [];
  int _totalAchievements = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final achievements = await _achievementDao.getAll();
    final categories = await _categoryDao.getAll();
    final total = await _achievementDao.getCount();

    setState(() {
      _recentAchievements = achievements.take(5).toList();
      _categories = categories;
      _totalAchievements = total;
      _isLoading = false;
    });
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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/zzSQs.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
          Icon(Icons.search_rounded, size: 20, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '搜索成就...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.45),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          _buildChip('全部', true),
          _buildChip('分类', false),
          _buildChip('最近', false),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 20, color: Colors.white.withOpacity(0.5)),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
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
        _buildCategoriesRow(),
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
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 130,
              child: DarkCategoryCard(
                name: category.name,
                icon: category.icon,
                color: _parseColor(category.color),
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
          title: '还没有成就',
          subtitle: '点击右下角按钮添加你的第一个成就',
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
    );
  }
}
