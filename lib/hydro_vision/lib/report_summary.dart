import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/glass_card.dart';

class ReportSummaryBottomSheet extends StatelessWidget {
  final Map<String, dynamic>? aiResults;

  const ReportSummaryBottomSheet({super.key, this.aiResults});

  @override
  Widget build(BuildContext context) {
    
    // Parse the results with fallbacks
    final isDrain = aiResults?['is_drain'] ?? false;
    final severity = aiResults?['severity'] as String? ?? 'Unknown';
    final debris = aiResults?['debris'] as String? ?? 'N/A';
    final percentage = (aiResults?['percentage'] as num?)?.toInt() ?? 0;

    if (aiResults == null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYS_MSG // NO DATA',
                    style: GoogleFonts.shareTechMono(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Awaiting telemetry from scanner array...',
                style: GoogleFonts.shareTechMono(color: Colors.white70),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    if (!isDrain) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ANALYSIS // FAILED',
                    style: GoogleFonts.shareTechMono(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Target object not recognized as a drainage system. Please recalibrate scanner and try again.',
                style: GoogleFonts.shareTechMono(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ANALYSIS // COMPLETE',
                  style: GoogleFonts.shareTechMono(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            // Severity
            Row(
              children: [
                Text(
                  'THREAT LEVEL:',
                  style: GoogleFonts.shareTechMono(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getSeverityColor(severity).withOpacity(0.5)),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, color: _getSeverityColor(severity)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'DEBRIS SIGNATURE',
              style: GoogleFonts.shareTechMono(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
            ),
            const SizedBox(height: 4),
            Text(
              debris,
              style: GoogleFonts.shareTechMono(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'BLOCKAGE COEFFICIENT',
              style: GoogleFonts.shareTechMono(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100.0,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(_getSeverityColor(severity)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$percentage%',
                  style: GoogleFonts.shareTechMono(fontSize: 16, fontWeight: FontWeight.bold, color: _getSeverityColor(severity)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                child: Text('DISMISS //', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final reportText = '''
🚨 *HYDRO_VISION OFFICIAL REPORT* 🚨
📍 Location: 3.1412 N, 101.6865 E (Kuala Lumpur)
⚠️ Severity: $severity
🗑️ Debris Detected: $debris
🌊 Blockage Level: $percentage%
''';
                  Share.share(reportText);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                  ),
                ),
                child: Text('TRANSMIT REPORT //', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.cyan.shade400;
    }
  }
}
