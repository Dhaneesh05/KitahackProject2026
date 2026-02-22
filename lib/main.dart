<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
=======
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

void main() {
>>>>>>> 26ab9ee (Added UI from Antigravity)
  runApp(const HydroVisionApp());
}

class HydroVisionApp extends StatelessWidget {
  const HydroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroVision',
<<<<<<< HEAD
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
=======
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Fade-in effect on app launch using standard Flutter animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    _AlertsPlaceholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000), // Enforce black HUD background
        body: Stack(
          children: [
            // Screen content - leaves room for the floating nav bar
            Positioned.fill(
              bottom: 90,
              child: _screens[_currentIndex],
            ),

            // Frosted glass bottom navigation bar (Tactical HUD style)
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
                      color: Colors.white.withOpacity(0.05), // Dark glass
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.3), // Cyan neon rim
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.12), // Cyan glow
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'HUD', index: 0, selectedIndex: _currentIndex, onTap: _onTap),
                        _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'MAP', index: 1, selectedIndex: _currentIndex, onTap: _onTap),
                        _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'ALERTS', index: 2, selectedIndex: _currentIndex, onTap: _onTap),
                        _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'PILOT', index: 3, selectedIndex: _currentIndex, onTap: _onTap),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
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
    const cyan = Color(0xFF00E5FF);
    final textMuted = Colors.white.withOpacity(0.5);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? cyan : textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ShareTechMono', // Manual check since we don't import google_fonts here
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isSelected ? cyan : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple alerts placeholder
class _AlertsPlaceholder extends StatelessWidget {
  const _AlertsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'SYSTEM ALERTS // NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 1.5,
                  fontFamily: 'ShareTechMono'
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_outlined, size: 56, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'No active alerts',
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All sectors clear.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
>>>>>>> 26ab9ee (Added UI from Antigravity)
    );
  }
}
