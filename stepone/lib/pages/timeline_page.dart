import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import 'achievement_form_page.dart';

class TimelinePage extends StatefulWidget {
  final List<Achievement> achievements;
  final List<Category> categories;
  final VoidCallback onRefresh;

  const TimelinePage({
    super.key,
    required this.achievements,
    required this.categories,
    required this.onRefresh,
  });

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Achievement> _getTimelineAchievements() {
    final sorted = List<Achievement>.from(widget.achievements);
    sorted.sort((a, b) => b.achievementDate.compareTo(a.achievementDate));
    return sorted.take(8).toList();
  }

  Color _getCategoryColor(int categoryId) {
    final category = widget.categories.firstWhere(
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
    final category = widget.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(
        name: '未分类',
        code: 'UNKNOWN',
        createdAt: DateTime.now(),
      ),
    );
    return category.name;
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  Future<void> _navigateToEditAchievement(Achievement achievement) async {
    await AchievementFormPage.navigate(context, achievement: achievement);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final timelineAchievements = _getTimelineAchievements();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间线',
            style: TextStyle(
              fontFamily: 'Noto Sans SC',
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '你的成就旅程',
            style: TextStyle(
              fontFamily: 'Noto Sans SC',
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: timelineAchievements.isEmpty
                ? _buildEmptyTimeline()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: timelineAchievements.length,
                    itemBuilder: (context, index) {
                      return _buildTimelineItem(timelineAchievements[index], index == 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有成就记录',
            style: TextStyle(
              fontFamily: 'Noto Sans SC',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '添加你的第一个成就开始记录',
            style: TextStyle(
              fontFamily: 'Noto Sans SC',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Achievement achievement, bool isLatest) {
    final categoryColor = _getCategoryColor(achievement.categoryId);
    final categoryName = _getCategoryName(achievement.categoryId);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isLatest ? categoryColor : categoryColor.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: isLatest
                        ? [BoxShadow(color: categoryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [categoryColor.withValues(alpha: 0.4), categoryColor.withValues(alpha: 0.05)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isLatest ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLatest ? categoryColor.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                  width: isLatest ? 1.2 : 0.8,
                ),
              ),
              child: GestureDetector(
                onTap: () => _navigateToEditAchievement(achievement),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.emoji_events_outlined, size: 18, color: categoryColor.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.92)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            achievement.description,
                            style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(categoryName, style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 9.5, color: categoryColor.withValues(alpha: 0.85), fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(height: 4),
                        Text(_formatTimelineDate(achievement.achievementDate), style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 10, color: Colors.white.withValues(alpha: 0.35))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimelineDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return '今天';
    if (difference.inDays == 1) return '昨天';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    if (date.year == now.year) return '${date.month}月${date.day}日';
    return '${date.year}年${date.month}月${date.day}日';
  }
}
