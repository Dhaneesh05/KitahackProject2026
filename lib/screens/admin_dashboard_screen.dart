import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';
import '../services/seed_service.dart';
import '../widgets/report_details_dialog.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────
//  Admin Dashboard — EOC Multi-Pane Layout
// ─────────────────────────────────────────────────────────
// ─── Shared helper: safely parse severityScore from String or num ───────────
int _parseSeverity(dynamic raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toInt();
  if (raw is String) {
    final lower = raw.toLowerCase();
    if (lower == 'danger' || lower == 'critical') return 90;
    if (lower == 'high') return 80;
    if (lower == 'medium' || lower == 'moderate') return 55;
    if (lower == 'low') return 30;
    if (lower == 'clear') return 5;
    return int.tryParse(raw) ?? 0;
  }
  return 0;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Run seeder exactly once when the screen mounts — NOT on every build
    SeedService.seedIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = MediaQuery.of(context).size.width >= 700;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.cyanAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    isWide ? 'HYDROVISION — COMMAND CENTER' : 'COMMAND CENTER',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.cyanAccent,
                      letterSpacing: 1.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              icon: const Icon(Icons.logout, color: Colors.white38, size: 15),
              label: Text(
                'SIGN OUT',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: [Color(0xFF1E3A3A), Color(0xFF0F172A)],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                return isWide ? _WideLayout() : _NarrowLayout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wide layout: 60/40 horizontal split ─────────────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: 'LIVE PRECIPITATION RADAR'),
                const SizedBox(height: 6),
                const _PrecipitationChartCard(),
                const SizedBox(height: 12),
                const _SectionLabel(label: 'AI VISUAL TRIAGE'),
                const SizedBox(height: 6),
                const Expanded(child: _TriageGrid()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: 'SYSTEM TELEMETRY'),
                const SizedBox(height: 6),
                const _TelemetryRow(),
                const SizedBox(height: 12),
                const _SectionLabel(label: 'PRIORITY DISPATCH'),
                const SizedBox(height: 6),
                const Expanded(child: _DispatchQueue()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Narrow layout: single scrollable column (phone) ─────────────────────────
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry
          const _SectionLabel(label: 'SYSTEM TELEMETRY'),
          const SizedBox(height: 6),
          const _TelemetryRow(),
          const SizedBox(height: 14),
          // Chart
          const _SectionLabel(label: 'LIVE PRECIPITATION RADAR'),
          const SizedBox(height: 6),
          const _PrecipitationChartCard(),
          const SizedBox(height: 14),
          // AI Triage
          const _SectionLabel(label: 'AI VISUAL TRIAGE'),
          const SizedBox(height: 6),
          SizedBox(
            height: 420,
            child: const _TriageGrid(),
          ),
          const SizedBox(height: 14),
          // Dispatch
          const _SectionLabel(label: 'PRIORITY DISPATCH'),
          const SizedBox(height: 6),
          SizedBox(
            height: 380,
            child: const _DispatchQueue(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Shared section label
// ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.cyanAccent,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Live Precipitation Chart
// ─────────────────────────────────────────────────────────
class _PrecipitationChartCard extends StatefulWidget {
  const _PrecipitationChartCard();

  @override
  State<_PrecipitationChartCard> createState() => _PrecipitationChartCardState();
}

class _PrecipitationChartCardState extends State<_PrecipitationChartCard> {
  late final Future<List<({double x, double y, String label})>> _future;

  @override
  void initState() {
    super.initState();
    _future = WeatherService.getHourlyPrecipitation();
  }

  @override
  Widget build(BuildContext context) {
    return _GlassPane(
      child: SizedBox(
        height: 150,
        child: FutureBuilder<List<({double x, double y, String label})>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
              );
            }
            if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
              return const Center(
                child: Text('Unable to load data', style: TextStyle(color: Colors.white38, fontSize: 12)),
              );
            }

            final pts = snap.data!;
            final maxY = pts.map((p) => p.y).fold(0.0, (a, b) => a > b ? a : b);
            final chartMaxY = maxY < 1.0 ? 2.0 : maxY * 1.3;
            final labelSet = <int>{};
            for (int i = 0; i < pts.length; i += 4) { labelSet.add(i); }

            return LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.07),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    left: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white30, fontSize: 8),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (!labelSet.contains(i) || i >= pts.length) return const SizedBox.shrink();
                        return Text(pts[i].label, style: const TextStyle(color: Colors.white30, fontSize: 7));
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: pts.map((p) => FlSpot(p.x, p.y)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Colors.cyanAccent,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    shadow: Shadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 8),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.cyanAccent.withValues(alpha: 0.3),
                          Colors.cyanAccent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  AI Triage Grid (left panel bottom)
// ─────────────────────────────────────────────────────────
class _TriageGrid extends StatelessWidget {
  const _TriageGrid();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('timestamp', descending: true)
          .limit(12)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2));
        }
        final docs = snap.hasData ? snap.data!.docs : [];
        if (docs.isEmpty) {
          return _GlassPane(
            child: const Center(
              child: Text('No reports in database', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.1,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) => _TriageImageCard(doc: docs[i]),
        );
      },
    );
  }
}

class _TriageImageCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _TriageImageCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl']?.toString() ?? '';
    final severity = _parseSeverity(data['severityScore']);
    final bool isCritical = severity > 75;
    final glowColor = isCritical ? Colors.redAccent : Colors.orangeAccent;
    final severityLabel = isCritical ? 'CRITICAL' : severity > 40 ? 'HIGH' : 'MODERATE';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withValues(alpha: 0.06),
                    child: const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 28),
                  ),
                )
              : Container(
                  color: Colors.white.withValues(alpha: 0.06),
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 28),
                ),
          // Dark gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          // Severity badge
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$severity% $severityLabel',
                  style: GoogleFonts.outfit(
                    color: glowColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: glowColor.withValues(alpha: 0.8), blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
          // Tap to view details
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ReportDetailsDialog(reportData: data),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Telemetry Row (right panel top)
// ─────────────────────────────────────────────────────────
class _TelemetryRow extends StatelessWidget {
  const _TelemetryRow();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, snap) {
        final docs = snap.hasData ? snap.data!.docs : [];
        final criticalCount = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return _parseSeverity(data['severityScore']) > 75;
        }).length;

        return Row(
          children: [
            Expanded(
              child: _TelemetryCard(
                label: 'CRITICAL',
                value: '$criticalCount',
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: _TelemetryCard(
                label: 'CREWS',
                value: '8',
                icon: Icons.groups_outlined,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: _TelemetryCard(
                label: 'CLEARED',
                value: '64%',
                icon: Icons.check_circle_outline,
                color: Colors.greenAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _TelemetryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 8,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Priority Dispatch Queue (right panel bottom)
// ─────────────────────────────────────────────────────────
class _DispatchQueue extends StatelessWidget {
  const _DispatchQueue();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('severityScore', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2));
        }

        final allDocs = snap.hasData ? snap.data!.docs : [];
        // Client-side filter: severity > 75 AND not already dispatched
        final filtered = allDocs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final score = _parseSeverity(data['severityScore']);
          final status = data['status']?.toString() ?? '';
          return score > 75 && status != 'Dispatched';
        }).toList();

        if (filtered.isEmpty) {
          return _GlassPane(
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
                  SizedBox(height: 8),
                  Text('All clear — no critical reports', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        return _GlassPane(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (_, i) => _DispatchCard(doc: filtered[i]),
          ),
        );
      },
    );
  }
}

class _DispatchCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _DispatchCard({required this.doc});

  Future<void> _dispatch() async {
    await doc.reference.update({'status': 'Dispatched'});
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final severity = _parseSeverity(data['severityScore']);
    final location = data['location']?.toString() ?? data['zone']?.toString() ?? 'Unknown';
    final type = data['floodType']?.toString() ?? data['type']?.toString() ?? 'Flood Report';
    final imageUrl = data['imageUrl']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'SEVERITY $severity%',
                    style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Dispatch button
          GestureDetector(
            onTap: _dispatch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              child: Text(
                'DISPATCH',
                style: GoogleFonts.outfit(
                  color: Colors.cyanAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 44, height: 44,
    color: Colors.white.withValues(alpha: 0.06),
    child: const Icon(Icons.water_damage_outlined, color: Colors.white24, size: 20),
  );
}

// ─────────────────────────────────────────────────────────
//  Shared glassmorphic pane
// ─────────────────────────────────────────────────────────
class _GlassPane extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassPane({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}