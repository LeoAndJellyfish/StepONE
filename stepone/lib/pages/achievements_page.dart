import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'achievement_form_page.dart';

class AchievementsPage extends StatefulWidget {
  final List<Achievement> achievements;
  final List<Category> categories;
  final int totalAchievements;
  final VoidCallback onRefresh;

  const AchievementsPage({
    super.key,
    required this.achievements,
    required this.categories,
    required this.totalAchievements,
    required this.onRefresh,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = '全部';
  int? _selectedCategoryId;

  List<Achievement> get _filteredAchievements => _applyFilter(widget.achievements);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Achievement> _applyFilter(List<Achievement> achievements) {
    var filtered = achievements;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((a) => a.title.toLowerCase().contains(query) || a.description.toLowerCase().contains(query)).toList();
    }
    if (_activeFilter == '最近') filtered = filtered.take(10).toList();
    if (_activeFilter == '分类' && _selectedCategoryId != null) filtered = filtered.where((a) => a.categoryId == _selectedCategoryId).toList();
    return filtered;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _activeFilter = filter;
      if (filter != '分类') _selectedCategoryId = null;
    });
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); }) : null,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'cancel'), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, 'search'), child: const Text('搜索')),
        ],
      ),
    );
    if (result == 'search') setState(() {});
  }

  Future<void> _showCategoryFilterDialog() async {
    if (widget.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('还没有分类，请先创建分类'), backgroundColor: Colors.transparent));
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
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              return ListTile(leading: Icon(_getIconData(category.icon), color: _parseColor(category.color)), title: Text(category.name), onTap: () => Navigator.pop(context, category));
            },
          ),
        ),
      ),
    );
    if (selectedCategory != null) setState(() { _selectedCategoryId = selectedCategory.id; _activeFilter = '分类'; });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events': return Icons.emoji_events;
      case 'lightbulb': return Icons.lightbulb;
      case 'work': return Icons.work;
      case 'article': return Icons.article;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'volunteer_activism': return Icons.volunteer_activism;
      default: return Icons.star;
    }
  }

  Color _parseColor(String colorString) {
    try { return Color(int.parse('FF${colorString.replaceAll('#', '')}', radix: 16)); } catch (e) { return AppTheme.primaryColor; }
  }

  Color _getCategoryColor(int categoryId) {
    final cat = widget.categories.firstWhere((c) => c.id == categoryId, orElse: () => Category(name: '未分类', code: 'UNKNOWN', color: '#6B9FE8', createdAt: DateTime.now()));
    return _parseColor(cat.color);
  }

  String _getCategoryName(int categoryId) {
    return widget.categories.firstWhere((c) => c.id == categoryId, orElse: () => Category(name: '未分类', code: 'UNKNOWN', createdAt: DateTime.now())).name;
  }

  Future<void> _navigateToAddAchievement() async {
    await AchievementFormPage.navigate(context);
    widget.onRefresh();
  }

  Future<void> _navigateToEditAchievement(Achievement achievement) async {
    await AchievementFormPage.navigate(context, achievement: achievement);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [_buildPanelHeader(), Expanded(child: _buildPanelContent())]),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          GestureDetector(onTap: _showSearchDialog, child: Icon(Icons.search_rounded, size: 20, color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(onTap: _showSearchDialog, child: Text(_searchController.text.isEmpty ? '搜索成就...' : _searchController.text, style: TextStyle(fontSize: 14, color: _searchController.text.isEmpty ? Colors.white.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.9)), overflow: TextOverflow.ellipsis))),
          _buildChip('全部', _activeFilter == '全部'),
          _buildChip('分类', _activeFilter == '分类'),
          _buildChip('最近', _activeFilter == '最近'),
          IconButton(icon: Icon(Icons.add_rounded, size: 20, color: Colors.white.withValues(alpha: 0.5)), onPressed: _navigateToAddAchievement, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ],
      ),
    );
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
            color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
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
                  color: isActive ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.5),
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

  Widget _buildPanelContent() {
    return Column(children: [
      Divider(height: 1, thickness: 0.5, color: Colors.white.withValues(alpha: 0.08)),
      _buildStatsRow(),
      if (_activeFilter == '分类') _buildCategoriesRow(),
      Expanded(child: _buildRecentList()),
    ]);
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Expanded(child: DarkGlassCard(child: Column(children: [
          Text('${widget.totalAchievements}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('总成就数', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ]))),
        const SizedBox(width: 10),
        Expanded(child: DarkGlassCard(child: Column(children: [
          Text('${widget.categories.length}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('分类数', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ]))),
      ]),
    );
  }

  Widget _buildCategoriesRow() {
    if (widget.categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(height: 110, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: widget.categories.length, itemBuilder: (context, index) {
      final category = widget.categories[index];
      final isSelected = _selectedCategoryId == category.id;
      return Padding(padding: const EdgeInsets.only(right: 10), child: SizedBox(width: 130, child: DarkCategoryCard(name: category.name, icon: category.icon, color: _parseColor(category.color), isSelected: isSelected, onTap: () => setState(() { _selectedCategoryId = category.id; _activeFilter = '分类'; }))));
    }));
  }

  Widget _buildRecentList() {
    if (_filteredAchievements.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: DarkEmptyState(title: _searchController.text.isNotEmpty ? '没有找到匹配的成就' : '还没有成就', subtitle: _searchController.text.isNotEmpty ? '尝试其他搜索条件或清除搜索' : '点击右下角按钮添加你的第一个成就', action: _searchController.text.isNotEmpty ? TextButton(onPressed: () { _searchController.clear(); _onFilterChanged('全部'); }, child: const Text('清除搜索')) : null));
    }
    return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), itemCount: _filteredAchievements.length, itemBuilder: (context, index) {
      final achievement = _filteredAchievements[index];
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: DarkAchievementCard(title: achievement.title, description: achievement.description, category: _getCategoryName(achievement.categoryId), date: achievement.achievementDate, categoryColor: _getCategoryColor(achievement.categoryId), onTap: () => _navigateToEditAchievement(achievement)));
    });
  }
}
