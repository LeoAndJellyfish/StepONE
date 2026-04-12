import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NavigationItem { timeline, achievements }

class DarkSidebar extends StatelessWidget {
  final NavigationItem selectedItem;
  final ValueChanged<NavigationItem> onItemSelected;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const DarkSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isExpanded ? 240 : 64,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpanded = constraints.maxWidth > 120;
          return SafeArea(
            right: false,
            child: Column(
              children: [
                _buildHeader(showExpanded),
                const SizedBox(height: 20),
                _buildNavItems(showExpanded),
                const Spacer(),
                _buildExpandToggle(showExpanded),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool showExpanded) {
    final logoIcon = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.8), AppTheme.accentColor.withValues(alpha: 0.6)]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
    );

    if (showExpanded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
        child: Row(
          children: [
            logoIcon,
            const SizedBox(width: 12),
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('StepONE', style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.95), letterSpacing: 1), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text('成就管理平台', style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 11, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.45)), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: logoIcon,
    );
  }

  Widget _buildNavItems(bool showExpanded) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showExpanded ? 10 : 8),
      child: Column(children: [
        _NavItem(
          icon: Icons.timeline_rounded,
          label: '时间线',
          item: NavigationItem.timeline,
          isSelected: selectedItem == NavigationItem.timeline,
          showExpanded: showExpanded,
          onTap: () => onItemSelected(NavigationItem.timeline),
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.emoji_events_outlined,
          label: '成就管理',
          item: NavigationItem.achievements,
          isSelected: selectedItem == NavigationItem.achievements,
          showExpanded: showExpanded,
          onTap: () => onItemSelected(NavigationItem.achievements),
        ),
      ]),
    );
  }

  Widget _buildExpandToggle(bool showExpanded) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showExpanded ? 10 : 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleExpand,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: showExpanded ? 14 : 0,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: showExpanded
                ? Row(children: [
                    Icon(Icons.chevron_left_rounded, size: 20, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 10),
                    Flexible(child: Text('收起侧栏', style: TextStyle(fontFamily: 'Noto Sans SC', fontSize: 13, color: Colors.white.withValues(alpha: 0.45)), overflow: TextOverflow.ellipsis)),
                  ])
                : Center(child: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withValues(alpha: 0.5))),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final NavigationItem item;
  final bool isSelected;
  final bool showExpanded;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.item,
    required this.isSelected,
    required this.showExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: isSelected ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.45),
    );

    if (!showExpanded) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
            ),
            child: Center(child: iconWidget),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
          ),
          child: Row(children: [
            iconWidget,
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Noto Sans SC',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ),
    );
  }
}
