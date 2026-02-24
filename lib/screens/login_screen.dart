import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  bool _isResident = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _login() {
    if (_isResident) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Mesh Gradient Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFE0F7FA), const Color(0xFFF1F8E9), _bgController.value)!,
                      Color.lerp(const Color(0xFFF1F8E9), const Color(0xFFE0F2F1), _bgController.value)!,
                      Color.lerp(const Color(0xFFE0F2F1), const Color(0xFFFDFDFD), _bgController.value)!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo Area
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(Icons.water_drop, color: AppColors.teal, size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'HydroVision',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'SMART FLOOD SHIELD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Resident vs City Council Toggle
                  Center(
                    child: _LiquidGlassContainer(
                      borderRadius: 30,
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ToggleButton(
                            title: 'Resident',
                            isActive: _isResident,
                            onTap: () => setState(() => _isResident = true),
                          ),
                          _ToggleButton(
                            title: 'City Council',
                            isActive: !_isResident,
                            onTap: () => setState(() => _isResident = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  _GlassTextField(
                    hintText: 'Email Address',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  _GlassTextField(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),

                  // Glowing Enter Button
                  GestureDetector(
                    onTap: _login,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [AppColors.teal, AppColors.tealDeep],
                          center: const Alignment(-0.8, -0.6),
                          radius: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ENTER SYSTEM',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}

class _ToggleButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? AppColors.tealDeep : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const _GlassTextField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return _LiquidGlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextFormField(
        obscureText: obscureText,
        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.textSecondary, size: 22),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _LiquidGlassContainer({
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }
}
