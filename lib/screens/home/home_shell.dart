import 'package:flutter/material.dart';
import 'package:stagesync/screens/home/home_dashboard_screen.dart';
import 'package:stagesync/screens/production/productions_list_screen.dart';
import 'package:stagesync/screens/profile/profile_screen.dart';
import 'package:stagesync/screens/schedule/schedule_screen.dart';
import 'package:stagesync/theme/app_colors.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;

  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeDashboardScreen(),
      const ScheduleScreen(),
      const ProductionsListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: AppColors.spotlightAmberGlow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
                Icon(Icons.home, color: AppColors.primaryCharcoalDark),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today,
                color: AppColors.primaryCharcoalDark),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.theater_comedy_outlined),
            selectedIcon: Icon(Icons.theater_comedy,
                color: AppColors.primaryCharcoalDark),
            label: 'Productions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person, color: AppColors.primaryCharcoalDark),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
