import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    FeedScreen(),
    RewardsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBg,
      body: Stack(
        children: [
          // Screen content - leaves room for the floating nav bar
          Positioned.fill(
            bottom: 90,
            child: _screens[_selectedIndex],
          ),

          // Frosted glass bottom navigation bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.of(context).glassBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.of(context).glassBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.of(context).teal.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'HOME', index: 0, selectedIndex: _selectedIndex, onTap: _onTap),
                      _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'MAP', index: 1, selectedIndex: _selectedIndex, onTap: _onTap),
                      _NavItem(icon: Icons.feed_outlined, activeIcon: Icons.feed_rounded, label: 'FEED', index: 2, selectedIndex: _selectedIndex, onTap: _onTap),
                      _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded, label: 'REWARDS', index: 3, selectedIndex: _selectedIndex, onTap: _onTap),
                      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'PROFILE', index: 4, selectedIndex: _selectedIndex, onTap: _onTap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(int index) => setState(() => _selectedIndex = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.of(context).tealLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.of(context).teal : AppColors.of(context).textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isSelected ? AppColors.of(context).teal : AppColors.of(context).textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

