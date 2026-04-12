import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/achievement.dart';
import '../models/category.dart';
import '../services/achievement_dao.dart';
import '../services/category_dao.dart';
import '../widgets/dark_sidebar.dart';
import 'timeline_page.dart';
import 'achievements_page.dart';
import 'achievement_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AchievementDao _achievementDao = AchievementDao();
  final CategoryDao _categoryDao = CategoryDao();

  List<Achievement> _allAchievements = [];
  List<Category> _categories = [];
  int _totalAchievements = 0;
  bool _isLoading = true;
  bool _isSidebarExpanded = true;

  NavigationItem _selectedItem = NavigationItem.timeline;

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
      _allAchievements = achievements;
      _categories = categories;
      _totalAchievements = total;
      _isLoading = false;
    });
  }

  void _onNavItemSelected(NavigationItem item) {
    setState(() => _selectedItem = item);
  }

  void _toggleSidebarExpand() {
    setState(() => _isSidebarExpanded = !_isSidebarExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/zzSQs.jpg', fit: BoxFit.cover),
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
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              DarkSidebar(
                selectedItem: _selectedItem,
                onItemSelected: _onNavItemSelected,
                isExpanded: _isSidebarExpanded,
                onToggleExpand: _toggleSidebarExpand,
              ),
              Expanded(
                child: _isLoading
                    ? const SafeArea(child: Center(child: CircularProgressIndicator(color: Colors.white70)))
                    : Column(
                        children: [
                          _buildAppBar(),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: KeyedSubtree(
                                key: ValueKey(_selectedItem),
                                child: _buildCurrentPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AchievementFormPage.navigate(context);
          _loadData();
        },
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add, color: Colors.white70),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedItem) {
      case NavigationItem.timeline:
        return TimelinePage(
          achievements: _allAchievements,
          categories: _categories,
          onRefresh: _loadData,
        );
      case NavigationItem.achievements:
        return AchievementsPage(
          achievements: _allAchievements,
          categories: _categories,
          totalAchievements: _totalAchievements,
          onRefresh: _loadData,
        );
    }
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Text(
              _getPageTitle(),
              style: TextStyle(
                fontFamily: 'Noto Sans SC',
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedItem) {
      case NavigationItem.timeline:
        return '时间线';
      case NavigationItem.achievements:
        return '成就管理';
    }
  }
}
