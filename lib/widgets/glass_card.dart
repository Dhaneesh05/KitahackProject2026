import 'dart:ui';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../theme/app_theme.dart';
=======
>>>>>>> 26ab9ee (Added UI from Antigravity)

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: color ?? AppColors.glassBg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.glassBorder,
=======
              color: color ?? Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
>>>>>>> 26ab9ee (Added UI from Antigravity)
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
<<<<<<< HEAD
                  color: AppColors.shadow,
=======
                  color: Colors.black.withOpacity(0.2),
>>>>>>> 26ab9ee (Added UI from Antigravity)
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
