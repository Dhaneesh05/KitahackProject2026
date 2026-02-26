import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/ai_vision_service.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import '../widgets/report_details_dialog.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── AI Vision Report Function ──────────────────────────────────────────
  Future<void> _onReport(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 50,
      );
      
      if (photo != null && context.mounted) {
        // Start analyzing image with Gemini
        final resultFuture = AiVisionService().analyzeDrainImage(photo);
        
        if (context.mounted) {
          // Show AI Analysis Results immediately and pass the future
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => _AnalysisResultSheet(resultFuture: resultFuture, imageFile: photo),
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
      backgroundColor: AppColors.of(context).scaffoldBg,
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
              
              // ── Predictive Alert Banner ──────────────────────────────
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('system_alerts').doc('current_forecast').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const SizedBox(height: 28); // Placeholder space
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox(height: 28);
                  }
                  
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final bool isCritical = data['is_critical'] ?? false;
                  final String date = data['date'] ?? '';

                  if (!isCritical) return const SizedBox(height: 28);

                  return Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: _ResidentUrgentAlertCard(date: date),
                  );
                },
              ),

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
                    color: AppColors.of(context).textSecondary,
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
                    color: AppColors.of(context).textPrimary,
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
                    color: AppColors.of(context).textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // ── Recent Activity ──────────────────────────────────────
              Text(
                'RECENT REPORTS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              
              StreamBuilder<QuerySnapshot>(
                stream: DatabaseService().getActiveReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: AppColors.of(context).teal),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No recent reports.',
                          style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.take(3).toList();

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final String material = data['debrisType'] ?? 'Unknown';
                      
                      // Calculate time ago
                      String timeAgo = 'Just now';
                      final timestamp = data['timestamp'];
                      if (timestamp is Timestamp) {
                        final diff = DateTime.now().difference(timestamp.toDate());
                        if (diff.inDays > 0) {
                          timeAgo = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
                        } else if (diff.inHours > 0) {
                          timeAgo = '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
                        } else if (diff.inMinutes > 0) {
                          timeAgo = '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
                        }
                      }

                      // Severity mapping
                      final dynamic rawScore = data['severityScore'];
                      int score = 0;
                      if (rawScore is int) {
                        score = rawScore;
                      } else if (rawScore is String) {
                        if (rawScore.toLowerCase() == 'high') {
                          score = 85;
                        } else if (rawScore.toLowerCase() == 'medium') {
                          score = 65;
                        } else if (rawScore.toLowerCase() == 'low') {
                          score = 30;
                        } else {
                          score = int.tryParse(rawScore) ?? 0;
                        }
                      } else if (rawScore is double) {
                        score = rawScore.toInt();
                      }

                      Color color = Colors.green;
                      if (score >= 80) {
                        color = Colors.redAccent;
                      } else if (score >= 60) {
                        color = Colors.orange;
                      }

                      // Icon mapping
                      IconData icon = Icons.water_drop_outlined;
                      final String lowerMat = material.toLowerCase();
                      if (lowerMat.contains('plastic') || lowerMat.contains('trash') || lowerMat.contains('garbage')) {
                        icon = Icons.delete_outline;
                      } else if (lowerMat.contains('veg') || lowerMat.contains('leaf') || lowerMat.contains('leaves') || lowerMat.contains('branch')) {
                        icon = Icons.eco_outlined;
                      } else if (lowerMat.contains('mud') || lowerMat.contains('silt') || lowerMat.contains('soil') || lowerMat.contains('sand')) {
                        icon = Icons.terrain_outlined;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _RecentReportItem(
                          icon: icon,
                          title: 'Report: $material',
                          subtitle: timeAgo,
                          color: color,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ReportDetailsDialog(reportData: data),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 320,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).glassBg.withValues(alpha: 0.8),
              border: Border(right: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5), width: 1.5)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.of(context).textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GlassCard(
                          padding: EdgeInsets.all(8),
                          borderRadius: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.6),
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close_rounded, color: AppColors.of(context).textSecondary, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.accessibility_new_outlined,
                    title: 'Accessibility',
                    onTap: () {
                      Navigator.pop(context);
                      _showAccessibilitySheet(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Divider(height: 1, thickness: 1, color: Colors.black12),
                  ),
                  const SizedBox(height: 16),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, 16, 24, 24),
                    child: Text(
                      'HydroVision v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.of(context).textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAccessibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.of(context).scaffoldBg.withValues(alpha: 0.8),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accessibility',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: appThemeNotifier,
                      builder: (context, currentMode, child) {
                        final isDark = currentMode == ThemeMode.dark;
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.55),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                    color: AppColors.of(context).teal,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    isDark ? 'Light Mode' : 'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.of(context).textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isDark,
                                activeThumbColor: AppColors.of(context).teal,
                                onChanged: (val) {
                                  appThemeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: 16,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.55),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.redAccent.withValues(alpha: 0.15)
                    : AppColors.of(context).tealDeep.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                color: isDestructive ? Colors.redAccent : AppColors.of(context).tealDeep, 
                size: 20
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.of(context).textMuted, size: 20),
          ],
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
            color: AppColors.of(context).tealLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.water_drop, color: AppColors.of(context).teal, size: 22),
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
                color: AppColors.of(context).textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'SMART FLOOD SHIELD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).textSecondary,
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
          child: Icon(Icons.settings_outlined, color: AppColors.of(context).textSecondary, size: 20),
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
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('system_alerts').doc('current_forecast').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassCard(
            padding: const EdgeInsets.all(22),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 0.8),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 120, decoration: BoxDecoration(color: AppColors.of(context).textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 24),
                      Container(height: 28, width: 180, decoration: BoxDecoration(color: AppColors.of(context).textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 24),
                      Container(height: 50, width: 120, decoration: BoxDecoration(color: AppColors.of(context).textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8))),
                      const SizedBox(height: 16),
                      Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: AppColors.of(context).textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                );
              },
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data()!;
        final bool isHighRisk = data['is_critical'] == true;
        
        final String riskText = data['risk_level']?.toString() ?? 'Pending';
        final String confidenceText = data['confidence']?.toString() ?? '--%';
        final String rainfallText = data['expected_rain']?.toString() ?? '--mm';
        
        final Color activeColor = isHighRisk ? Colors.redAccent : Colors.green.shade500;
        final Color activeBgColor = isHighRisk ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.15);
        final IconData activeIcon = isHighRisk ? Icons.trending_up : Icons.trending_down;

        return GlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag row
              Row(
                children: [
                  Icon(Icons.water_drop_outlined, color: AppColors.of(context).teal, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ML FORECAST',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // LIVE badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: activeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: activeColor,
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
                  color: AppColors.of(context).textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.of(context).textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Downtown District, Zone 4',
                    style: TextStyle(fontSize: 13, color: AppColors.of(context).textSecondary),
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
                              riskText,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: activeColor,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              activeIcon,
                              color: activeColor,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Risk progress bar 
                        _RiskBar(filledSegments: isHighRisk ? 4 : 1, activeColor: activeColor),
                        const SizedBox(height: 8),
                        Text(
                          'Next 24h rainfall: $rainfallText',
                          style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right: stat cards
                  Column(
                    children: [
                      _StatMini(value: confidenceText, label: 'ML Conf.'),
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
  final Color activeColor;
  const _RiskBar({this.filledSegments = 1, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              color: i < filledSegments ? activeColor : AppColors.of(context).textMuted.withValues(alpha: 0.3),
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
                  color: accentValue ? AppColors.of(context).teal : AppColors.of(context).textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.of(context).textSecondary),
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
                    color: AppColors.of(context).tealLight.withValues(alpha: 0.6),
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
                colors: [AppColors.of(context).teal, AppColors.of(context).tealDeep],
                center: const Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.of(context).teal.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: AppColors.of(context).textOnTeal, size: 28),
                const SizedBox(height: 4),
                Text(
                  'REPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.of(context).textOnTeal,
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
//  Activity Item  (used in Recent Reports)
// ─────────────────────────────────────────────────────
class _RecentReportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RecentReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      onTap: onTap,
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
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.of(context).textMuted),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Analysis Result Sheet  (with post compose + geolocation)
// ─────────────────────────────────────────────────────
class _AnalysisResultSheet extends StatefulWidget {
  final Future<Map<String, dynamic>> resultFuture;
  final XFile imageFile;

  const _AnalysisResultSheet({
    required this.resultFuture,
    required this.imageFile,
  });

  @override
  State<_AnalysisResultSheet> createState() => _AnalysisResultSheetState();
}

class _AnalysisResultSheetState extends State<_AnalysisResultSheet> {
  bool _isSubmitting = false;
  bool _isAnalyzing = true;
  Map<String, dynamic>? _result;
  String? _analysisError;

  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;
  String? _locationLabel;

  final TextEditingController _descController = TextEditingController();

  static const _severities = ['Clear', 'Low', 'Medium', 'Danger'];
  late String _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _selectedSeverity = 'Low';
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final res = await widget.resultFuture;
      if (mounted) {
        final aiSeverity = res['severity'] ?? 'Low';
        final matched = _severities.firstWhere(
          (s) => s.toLowerCase() == aiSeverity.toString().toLowerCase(),
          orElse: () => 'Low',
        );
        setState(() {
          _result = res;
          _isAnalyzing = false;
          _selectedSeverity = matched;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _analysisError = e.toString(); _isAnalyzing = false; });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'danger': return Colors.red.shade500;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue.shade400;
      default: return AppColors.of(context).teal;
    }
  }

  IconData _severityIcon(String s) {
    switch (s.toLowerCase()) {
      case 'danger': return Icons.warning_amber_rounded;
      case 'medium': return Icons.water_rounded;
      case 'low': return Icons.water_drop_outlined;
      default: return Icons.check_circle_outline_rounded;
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationLabel =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _submitToFirebase(BuildContext context) async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please write a description for your report.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      // 1. Upload to Storage
      final photoUrl =
          await StorageService().uploadDrainPhoto(widget.imageFile, 'user_resident_123');

      // 2. Write to Database
      final severity = (_result != null && _result!.containsKey('severity')) ? _result!['severity'] : _selectedSeverity;
      final material = (_result != null && _result!.containsKey('material')) ? _result!['material'] : 'Unknown';

      await DatabaseService().submitReport({
        'userId': 'user_resident_123',
        'imageUrl': photoUrl,
        'severityScore': severity,
        'debrisType': material,
        'description': _descController.text.trim(),
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      });

      if (context.mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully! 🌊'),
            backgroundColor: AppColors.of(context).teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.of(context).scaffoldBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, decoration: BoxDecoration(color: AppColors.of(context).textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: AppColors.of(context).teal, strokeWidth: 2)),
                const SizedBox(width: 12),
                Text('Analyzing Image...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary, letterSpacing: -0.5)),
              ],
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(height: 60, child: Row(children: [Icon(Icons.auto_awesome, color: AppColors.of(context).teal), const SizedBox(width: 16), Expanded(child: Text('AI is scanning for blockages...', style: TextStyle(color: AppColors.of(context).textSecondary)))])),
            ),
            const SizedBox(height: 16),
            Text('Analyzed image: ${widget.imageFile.name}', style: TextStyle(fontSize: 12, color: AppColors.of(context).textMuted)),
            const SizedBox(height: 32),
            SizedBox(height: 56, width: double.infinity, child: ElevatedButton(onPressed: null, style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).textMuted.withValues(alpha: 0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: Text('ANALYZING...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.of(context).textMuted)))),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      );
    }
    
    if (_analysisError != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.of(context).scaffoldBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(child: Icon(Icons.error_outline, color: Colors.redAccent, size: 48)),
             const SizedBox(height: 16),
             Text('Analysis Failed: $_analysisError', style: TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center),
             const SizedBox(height: 24),
             SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text('Close', style: TextStyle(fontSize: 16, color: AppColors.of(context).textOnTeal)))),
             SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ]
        ),
      );
    }

    final severity = _result?['severity'] ?? 'Unknown';
    final material = _result?['material'] ?? 'Unknown';
    
    Color severityColor = AppColors.of(context).teal;
    if (severity == 'High' || severity == 'Error') severityColor = Colors.redAccent;
    if (severity == 'Medium') severityColor = Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Drag handle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.of(context).teal, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Analysis Complete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.of(context).textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'AI detected the following — review and complete your post.',
              style: TextStyle(fontSize: 13, color: AppColors.of(context).textSecondary),
            ),
            const SizedBox(height: 20),

            // ── AI Result Card ──────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blockage Severity', style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary)),
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
                  Container(width: 1, height: 40, color: AppColors.of(context).textMuted.withValues(alpha: 0.2)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detected Material', style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          material,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.of(context).textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Description Field ───────────────────────────────
            Text('Your Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.of(context).textPrimary, letterSpacing: 0.3)),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _descController,
                maxLines: 4,
                maxLength: 280,
                style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.of(context).textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe what you see… e.g. "Jalan Ampang completely flooded, water waist-deep" #FloodAlert',
                  hintStyle: TextStyle(color: AppColors.of(context).textMuted, fontSize: 14),
                  counterStyle: TextStyle(color: AppColors.of(context).textMuted, fontSize: 11),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Severity Selector ───────────────────────────────
            Text('Flood Severity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.of(context).textPrimary, letterSpacing: 0.3)),
            const SizedBox(height: 10),
            Row(
              children: _severities.map((s) {
                final isSelected = s == _selectedSeverity;
                final color = _severityColor(s);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSeverity = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.of(context).glassBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppColors.of(context).textMuted.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_severityIcon(s), size: 18, color: isSelected ? color : AppColors.of(context).textMuted),
                            const SizedBox(height: 4),
                            Text(s, style: TextStyle(
                              fontSize: 11, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? color : AppColors.of(context).textMuted,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Geolocation Tag ─────────────────────────────────
            Text('Location Tag', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.of(context).textPrimary, letterSpacing: 0.3)),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _latitude != null ? Icons.location_on_rounded : Icons.location_off_outlined,
                    color: _latitude != null ? AppColors.of(context).teal : AppColors.of(context).textMuted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _locationLabel ?? 'No location tagged yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: _latitude != null ? AppColors.of(context).textPrimary : AppColors.of(context).textMuted,
                        fontWeight: _latitude != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isFetchingLocation ? null : _fetchLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).teal,
                        foregroundColor: AppColors.of(context).textOnTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: _isFetchingLocation
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_latitude != null ? 'Update' : 'Tag Me',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzed image: ${widget.imageFile.name}',
              style: TextStyle(fontSize: 12, color: AppColors.of(context).textMuted),
            ),
            const SizedBox(height: 28),

            // ── Submit Button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitToFirebase(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).teal,
                  foregroundColor: AppColors.of(context).textOnTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: AppColors.of(context).textOnTeal, strokeWidth: 2),
                      )
                    : const Text(
                        'CONFIRM REPORT & EARN 50 PTS',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Resident Urgent Alert Card
// ─────────────────────────────────────────────────────
class _ResidentUrgentAlertCard extends StatefulWidget {
  final String date;
  const _ResidentUrgentAlertCard({required this.date});

  @override
  State<_ResidentUrgentAlertCard> createState() => _ResidentUrgentAlertCardState();
}

class _ResidentUrgentAlertCardState extends State<_ResidentUrgentAlertCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _colorAnimation = ColorTween(
      begin: Colors.redAccent.withValues(alpha: 0.15),
      end: Colors.orangeAccent.withValues(alpha: 0.3),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('⛈️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'URGENT ALERT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Major storm expected ${widget.date}! Earn 2x Points for reporting blocked drains in your neighborhood today.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}