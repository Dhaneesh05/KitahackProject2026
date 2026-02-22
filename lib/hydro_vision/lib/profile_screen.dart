import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final textMuted = Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // HUD Black
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
                    'OPERATIVE // PROFILE',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    onTap: () {},
                    child: Icon(Icons.settings_outlined, color: textMuted, size: 20),
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
                        colors: [cyan.withOpacity(0.1), cyan.withOpacity(0.4)],
                      ),
                      border: Border.all(color: cyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 45, color: cyan),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cyan,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.black, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'FIELD AGENT X',
                style: GoogleFonts.shareTechMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CLASS-4 · TACTICAL RESPONDER',
                style: GoogleFonts.shareTechMono(fontSize: 11, color: textMuted, letterSpacing: 1.2),
              ),
              const SizedBox(height: 28),

              // Stats row
              Row(
                children: [
                  Expanded(child: _StatCard(value: '1,250', label: 'CREDITS')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '12', label: 'SCANS')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: 'S+', label: 'RATING')),
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
                        color: cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cyan.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.shield, color: cyan, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ASSIGNED SECTOR',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sector #4023 · Monitored',
                            style: GoogleFonts.shareTechMono(fontSize: 11, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cyan.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: cyan,
                          letterSpacing: 1.2,
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
                      'ACHIEVEMENTS',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w800,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BadgeItem(icon: Icons.water_drop, label: 'Aqua\nSentinel', earned: true),
                        _BadgeItem(icon: Icons.flash_on, label: 'Rapid\nResponse', earned: true),
                        _BadgeItem(icon: Icons.eco, label: 'Eco\nElite', earned: false),
                        _BadgeItem(icon: Icons.groups, label: 'Squad\nLeader', earned: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Buffer for floating Bottom Nav
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
    const cyan = Color(0xFF00E5FF);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 18,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cyan,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.shareTechMono(
              fontSize: 10, 
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.5,
            ),
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
    const cyan = Color(0xFF00E5FF);
    final textMuted = Colors.white.withOpacity(0.3);

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: earned ? cyan.withOpacity(0.15) : textMuted.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: earned ? cyan.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: earned ? [BoxShadow(color: cyan.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Icon(
            icon,
            color: earned ? cyan : textMuted,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: earned ? Colors.white.withOpacity(0.8) : textMuted,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
