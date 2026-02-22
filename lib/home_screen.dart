import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'report_summary.dart';
import 'services/ai_service.dart';
import 'models/report_item.dart';
import 'widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _riskLevel = 'Green'; // Green, Yellow, Red
  bool _isScanning = false;
  final List<ReportItem>? _recentReports = [];
  
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  Future<void> _onScanPressed() async {
    if (_isScanning) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera); // or ImageSource.gallery if preferred by the user but usually camera is expected

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }

      final aiService = AIService();
      final results = await aiService.analyzeImage(pickedFile);

      if (mounted) {
        setState(() {
          _isScanning = false;
          
          if (results != null && results['is_drain'] == true) {
            final severity = results['severity'] as String? ?? 'Unknown';
            final debrisType = results['debris'] as String? ?? 'Unknown';
            // We use image bytes because XFile path is not always reliable on the Web. 
            // We load bytes async and add the report item.
            pickedFile.readAsBytes().then((bytes) {
              if (mounted) {
                setState(() {
                  _recentReports?.insert(0, ReportItem(
                    imageBytes: bytes,
                    severity: severity,
                    debrisType: debrisType,
                    timestamp: DateTime.now(),
                  ));
                  if ((_recentReports?.length ?? 0) > 5) {
                    _recentReports?.removeLast();
                  }
                });
              }
            });
          }
        });

        // Show ReportSummary BottomSheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // For custom shape
          builder: (context) => ReportSummaryBottomSheet(aiResults: results),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HUD // HYDRO_VISION'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background grid pattern can be added here if desired

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'SYSTEM STATUS // RISK ANALYSIS',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF00E5FF)),
                  ),
                  const SizedBox(height: 16),
                  FloodRiskCard(
                    riskLevel: _riskLevel,
                    onTap: () {
                      setState(() {
                        if (_riskLevel == 'Green') _riskLevel = 'Yellow';
                        else if (_riskLevel == 'Yellow') _riskLevel = 'Red';
                        else _riskLevel = 'Green';
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const RadarWidget(),
                        if (_isScanning)
                          const SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: AnimatedBuilder(
                      animation: _heartbeatAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartbeatAnimation.value,
                          child: child,
                        );
                      },
                      child: _ReportButton(onTap: _onScanPressed),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'RECENT ACTIVITY // HISTORY',
                    style: GoogleFonts.shareTechMono(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFF00E5FF)),
                  ),
                  const SizedBox(height: 16),
                  if (_recentReports?.isEmpty ?? true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'No recent scans. System standby...',
                        style: GoogleFonts.shareTechMono(color: Colors.white54, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentReports?.length ?? 0,
                      itemBuilder: (context, index) {
                        final report = _recentReports![index];
                        final dateStr = '${report.timestamp.hour.toString().padLeft(2, '0')}:${report.timestamp.minute.toString().padLeft(2, '0')} // ${report.timestamp.day}/${report.timestamp.month}';
                        
                        Color badgeColor;
                        switch (report.severity.toLowerCase()) {
                          case 'high': badgeColor = Colors.redAccent; break;
                          case 'medium': badgeColor = const Color(0xFFFFC400); break;
                          case 'low': badgeColor = Colors.greenAccent; break;
                          default: badgeColor = const Color(0xFF00E5FF);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _RecentReportItem(
                            icon: Icons.warning_amber_rounded,
                            title: '${report.severity.toUpperCase()} ALERT: ${report.debrisType}',
                            subtitle: dateStr,
                            color: badgeColor,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_recentReports != null && _recentReports!.isNotEmpty) {
                          final latest = _recentReports!.first;
                          final reportText = '''
🚨 *HYDRO_VISION OFFICIAL REPORT* 🚨
📍 Location: 3.1412 N, 101.6865 E (Kuala Lumpur)
⚠️ Last Scan Severity: ${latest.severity}
🗑️ Debris Detected: ${latest.debrisType}
''';
                          Share.share(reportText);
                        } else {
                          final reportText = '''
🚨 *HYDRO_VISION OFFICIAL REPORT* 🚨
📍 Location: 3.1412 N, 101.6865 E (Kuala Lumpur)
⚠️ Status: System standby. No anomalies detected.
''';
                          Share.share(reportText);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('OFFICIAL REPORT', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
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

class FloodRiskCard extends StatelessWidget {
  final String riskLevel;
  final VoidCallback onTap;

  const FloodRiskCard({
    super.key,
    required this.riskLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData riskIcon;
    String statusText;

    switch (riskLevel.toLowerCase()) {
      case 'red':
        cardColor = Colors.redAccent;
        riskIcon = Icons.warning_amber_rounded;
        statusText = 'CRITICAL RISK';
        break;
      case 'yellow':
        cardColor = const Color(0xFFFFC400); // Amber
        riskIcon = Icons.error_outline_rounded;
        statusText = 'ELEVATED RISK';
        break;
      case 'green':
      default:
        cardColor = const Color(0xFF00E5FF); // Neon Cyan
        riskIcon = Icons.check_circle_outline_rounded;
        statusText = 'NOMINAL';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cardColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(riskIcon, color: cardColor, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: cardColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SYS_MSG // tap to simulate status override',
                        style: TextStyle(
                          color: cardColor.withOpacity(0.7),
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadarWidget extends StatefulWidget {
  const RadarWidget({super.key});

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: RadarPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double rotation;
  RadarPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final cyanColor = const Color(0xFF00E5FF);

    final linePaint = Paint()
      ..color = cyanColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles
    canvas.drawCircle(center, radius, linePaint);
    canvas.drawCircle(center, radius * 0.66, linePaint);
    canvas.drawCircle(center, radius * 0.33, linePaint);
    
    // Draw crosshairs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // Draw the sweeping gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          cyanColor.withOpacity(0.0),
          cyanColor.withOpacity(0.5),
        ],
        stops: const [0.7, 1.0],
        transform: GradientRotation(rotation * 2 * 3.1415926535),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * 3.1415926535,
      true,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => oldDelegate.rotation != rotation;
}

// ─────────────────────────────────────────────────────
//  Report Button
// ─────────────────────────────────────────────────────
class _ReportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00E5FF);
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
              color: primaryColor.withOpacity(0.15),
            ),
          ),
          // Inner button
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [primaryColor, Color(0xFF00838F)],
                center: Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 28),
                const SizedBox(height: 4),
                Text(
                  'SCAN',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.black,
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
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
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.shareTechMono(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white54),
        ],
      ),
    );
  }
}
