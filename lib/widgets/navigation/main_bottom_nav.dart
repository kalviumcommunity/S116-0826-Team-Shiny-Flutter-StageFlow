import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class MainBottomNav extends StatelessWidget {
  final Widget child;

  const MainBottomNav({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/productions')) return 2;
    if (location.startsWith('/profile')) return 3;
    // For auxiliary routes, don't force select if not on 4 main tabs
    if (location.startsWith('/auditions')) return 1;
    if (location.startsWith('/venues')) return 1;
    if (location.startsWith('/availability')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/schedule');
        break;
      case 2:
        context.go('/productions');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131B2E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF283044) : AppColors.borderHairline;
    final activeColor = isDark ? const Color(0xFFFF93A6) : AppColors.primaryContainer;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  isSelected: selectedIndex == 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Home',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  isSelected: selectedIndex == 1,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Schedule',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  isSelected: selectedIndex == 2,
                  icon: Icons.theater_comedy_outlined,
                  activeIcon: Icons.theater_comedy,
                  label: 'Productions',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  isSelected: selectedIndex == 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required bool isSelected,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: 14,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
