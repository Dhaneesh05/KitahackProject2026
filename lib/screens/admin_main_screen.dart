import 'dart:ui';
import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'map_screen.dart';
import 'admin_feed_screen.dart';
import 'admin_profile_screen.dart';

/// The admin's main screen with bottom navigation — mirrors user MainScreen
/// but with admin-specific tabs.
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    MapScreen(),
    AdminFeedScreen(),
    AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 90,
            child: _screens[_selectedIndex],
          ),

          // Dark frosted glass bottom navigation bar
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
                    color: const Color(0xD01E3A3A),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AdminNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'COMMAND', index: 0, selectedIndex: _selectedIndex, onTap: _onTap),
                      _AdminNavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'MAP', index: 1, selectedIndex: _selectedIndex, onTap: _onTap),
                      _AdminNavItem(icon: Icons.feed_outlined, activeIcon: Icons.feed_rounded, label: 'REPORTS', index: 2, selectedIndex: _selectedIndex, onTap: _onTap),
                      _AdminNavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield_rounded, label: 'ADMIN', index: 3, selectedIndex: _selectedIndex, onTap: _onTap),
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

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;

  const _AdminNavItem({
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
          color: isSelected ? const Color(0xFF00897B).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF26A69A) : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isSelected ? const Color(0xFF26A69A) : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
