import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening camera to report drain...'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── App Header ──────────────────────────────────────────
              _AppHeader(),
              const SizedBox(height: 28),

              // ── Ecosystem / Flood Risk Card ─────────────────────────
              _FloodRiskCard(),
              const SizedBox(height: 36),

              // ── Quick Action ────────────────────────────────────────
              Center(
                child: Text(
                  'QUICK ACTION',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(child: _ReportButton(onTap: () => _onReport(context))),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Report Drain',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tap to report a blocked or flooded drain nearby',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // ── Recent Reports ──────────────────────────────────────
              Text(
                'RECENT REPORTS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _RecentReportItem(
                icon: Icons.water_drop_outlined,
                title: 'Drain #4023 Cleared',
                subtitle: 'Jalan Ampang • 10 mins ago',
                color: AppColors.teal,
              ),
              const SizedBox(height: 8),
              _RecentReportItem(
                icon: Icons.warning_amber_rounded,
                title: 'Flash Flood Alert Resolved',
                subtitle: 'Bangsar • 2 hours ago',
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              _RecentReportItem(
                icon: Icons.emoji_events_outlined,
                title: 'Badge Earned: Water Guardian',
                subtitle: 'Yesterday',
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  App Header
// ─────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo badge
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.water_drop, color: AppColors.teal, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HydroVision',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'SMART FLOOD SHIELD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        GlassCard(
          padding: const EdgeInsets.all(10),
          borderRadius: 14,
          onTap: () {},
          child: Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
//  Flood Risk Card
// ─────────────────────────────────────────────────────
class _FloodRiskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag row
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              Text(
                'ECOSYSTEM',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // LIVE badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Flood Risk Forecast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                'Downtown District, Zone 4',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Risk level + stat cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: risk level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Low',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.trending_down, color: AppColors.teal, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Risk progress bar
                    _RiskBar(filledSegments: 1),
                    const SizedBox(height: 8),
                    Text(
                      'Next 24h rainfall: 2.1mm expected',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right: stat cards
              Column(
                children: [
                  _StatMini(value: '87%', label: 'Drain Cap.'),
                  const SizedBox(height: 8),
                  _StatMini(value: '12', label: 'Sensors', accentValue: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  final int filledSegments;
  const _RiskBar({this.filledSegments = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              color: i < filledSegments ? AppColors.teal : AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  final bool accentValue;
  const _StatMini({required this.value, required this.label, this.accentValue = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 82,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentValue ? AppColors.teal : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Report Button
// ─────────────────────────────────────────────────────
class _ReportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealLight.withValues(alpha: 0.6),
            ),
          ),
          // Inner button
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.teal, AppColors.tealDeep],
                center: const Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: AppColors.textOnTeal, size: 28),
                const SizedBox(height: 4),
                Text(
                  'REPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.textOnTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Recent Report Item
// ─────────────────────────────────────────────────────
class _RecentReportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _RecentReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
