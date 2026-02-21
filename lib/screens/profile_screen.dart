import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Header
              Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const Spacer(),
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    onTap: () {},
                    child: Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.tealLight, AppColors.teal.withValues(alpha: 0.4)],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 3),
                    ),
                    child: Icon(Icons.person_rounded, size: 45, color: AppColors.teal),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Eco Warrior',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Level 5 · Smart City Contributor',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // Stats row
              Row(
                children: [
                  Expanded(child: _StatCard(value: '1,250', label: 'Points')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '12', label: 'Reports')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '#42', label: 'Rank')),
                ],
              ),
              const SizedBox(height: 16),

              // Adopted drain card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.verified_rounded, color: AppColors.teal, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adopted Drain',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Drain #4023 · Clean & Verified',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Badges
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BADGES',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BadgeItem(icon: Icons.water_drop, label: 'Water\nGuardian', earned: true),
                        _BadgeItem(icon: Icons.flash_on, label: 'Quick\nResponder', earned: true),
                        _BadgeItem(icon: Icons.eco, label: 'Eco\nChampion', earned: false),
                        _BadgeItem(icon: Icons.groups, label: 'Community\nHero', earned: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 18,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.teal,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool earned;
  const _BadgeItem({required this.icon, required this.label, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: earned ? AppColors.tealLight : AppColors.textMuted.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: earned ? AppColors.teal.withValues(alpha: 0.4) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: earned ? AppColors.teal : AppColors.textMuted,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: earned ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
