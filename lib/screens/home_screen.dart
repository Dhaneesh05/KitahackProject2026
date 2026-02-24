import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/ai_vision_service.dart';
import '../services/flood_prediction_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── AI Vision Report Function ──────────────────────────────────────────
  Future<void> _onReport(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo != null && context.mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        );

        // Analyze image with Gemini
        final result = await AiVisionService().analyzeDrainImage(photo);
        
        // Close loading indicator
        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
          // Show AI Analysis Results
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => _AnalysisResultSheet(result: result, imagePath: photo.name),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to perform analysis: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: _SettingsDrawer(),
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
//  Settings Drawer
// ─────────────────────────────────────────────────────
class _SettingsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.scaffoldBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _DrawerItem(
              icon: Icons.lock_outline,
              title: 'Privacy',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Privacy
              },
            ),
            _DrawerItem(
              icon: Icons.accessibility_new_outlined,
              title: 'Accessibility',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Accessibility
              },
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Terms
              },
            ),
            const Spacer(),
            const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'HydroVision v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.teal, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      onTap: onTap,
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
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
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
    return FutureBuilder<Map<String, dynamic>>(
      future: FloodPredictionService().getTodayFloodRisk(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassCard(
            padding: const EdgeInsets.all(40),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }

        final data = snapshot.data!;
        final bool isHighRisk = data['riskLevel'] == 'High';

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
                    'ML FORECAST',
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
                      color: isHighRisk ? Colors.red.withValues(alpha: 0.2) : AppColors.tealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isHighRisk ? Colors.redAccent : AppColors.teal,
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
                    data['zone'] as String,
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
                              data['riskLevel'] as String,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: isHighRisk ? Colors.redAccent : AppColors.textPrimary,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              data['trend'] == 'rising' ? Icons.trending_up : Icons.trending_down,
                              color: isHighRisk ? Colors.redAccent : AppColors.teal,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Risk progress bar (simulated high risk = 4 segments)
                        _RiskBar(filledSegments: isHighRisk ? 4 : 1),
                        const SizedBox(height: 8),
                        Text(
                          'Next 24h rainfall: ${data['predictedRainfall']}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right: stat cards
                  Column(
                    children: [
                      _StatMini(value: data['confidence'] as String, label: 'ML Conf.'),
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
class _ReportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ReportButton({required this.onTap});

  @override
  State<_ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<_ReportButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealLight.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
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

// ─────────────────────────────────────────────────────
//  AI Analysis Result Sheet
// ─────────────────────────────────────────────────────
class _AnalysisResultSheet extends StatelessWidget {
  final Map<String, dynamic> result;
  final String imagePath;

  const _AnalysisResultSheet({
    required this.result,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final severity = result['severity'] ?? 'Unknown';
    final material = result['material'] ?? 'Unknown';
    
    Color severityColor = AppColors.teal;
    if (severity == 'High' || severity == 'Error') severityColor = Colors.redAccent;
    if (severity == 'Medium') severityColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.teal, size: 28),
              const SizedBox(width: 12),
              Text(
                'AI Analysis Complete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blockage Severity', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        severity,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.textMuted.withValues(alpha: 0.2)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detected Material', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        material,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzed image: $imagePath',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('SUBMIT REPORT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
