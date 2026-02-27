import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// Rich bottom sheet shown when an admin taps a map marker.
/// Displays the live report image, severity, material, description, and time.
class ReportMapBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportMapBottomSheet({super.key, required this.data});

  static void show(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportMapBottomSheet(data: data),
    );
  }

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'danger':
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue.shade400;
      default:
        return const Color(0xFF3FC9A8);
    }
  }

  IconData _severityIcon(String s) {
    switch (s.toLowerCase()) {
      case 'danger':
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.water_rounded;
      case 'low':
        return Icons.water_drop_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return 'Unknown time';
    if (ts is! Timestamp) return 'Unknown time';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = data['imageUrl'] ?? '';
    final String severity = data['severityScore']?.toString() ?? 'Unknown';
    final String material = data['debrisType'] ?? 'Unknown';
    final String description = data['description'] ?? '';
    final String status = data['status'] ?? 'Pending';
    final Color sColor = _severityColor(severity);

    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Report image ─────────────────────────────
                  if (imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              imageUrl.startsWith('data:image')
                                  ? Image.memory(
                                      Uri.parse(imageUrl).data!.contentAsBytes(),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (_, child, progress) =>
                                          progress == null
                                              ? child
                                              : Container(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Color(0xFF3FC9A8),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        child: const Center(
                                          child: Icon(Icons.broken_image_outlined,
                                              color: Colors.white30, size: 48),
                                        ),
                                      ),
                                    ),
                              // Gradient overlay
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Severity badge
                              Positioned(
                                bottom: 10,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: sColor.withValues(alpha: 0.90),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_severityIcon(severity), color: Colors.white, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        severity.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Details ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Material + time + status row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: sColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                material,
                                style: TextStyle(
                                  color: sColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time_rounded,
                                size: 13, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo(data['timestamp']),
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),

                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Location
                        if (data['location'] is GeoPoint) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Color(0xFF3FC9A8), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '${(data['location'] as GeoPoint).latitude.toStringAsFixed(5)}, '
                                  '${(data['location'] as GeoPoint).longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
}
