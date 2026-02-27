import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/report_details_dialog.dart';

/// A card widget that displays a single Firestore `reports` document.
/// Used by both the Resident FeedScreen and AdminFeedScreen.
class FirestoreReportCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool isAdmin;

  const FirestoreReportCard({
    super.key,
    required this.data,
    required this.docId,
    this.isAdmin = false,
  });

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
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

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
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

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'just now';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else {
      return 'just now';
    }
    final diff = DateTime.now().difference(dt);
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

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => ReportDetailsDialog(reportData: data),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.of(context).glassBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.of(context).glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Report image ────────────────────────────
                if (imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: imageUrl.startsWith('data:image')
                              ? Image.memory(
                                  Uri.parse(imageUrl).data!.contentAsBytes(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) => progress == null
                                      ? child
                                      : Container(
                                          color: AppColors.of(context).tealLight,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.of(context).teal,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                  errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                                ),
                        ),
                      ),
                      // Severity badge overlay
                      Positioned(
                        top: 10,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: sColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: sColor.withValues(alpha: 0.4), blurRadius: 8)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_severityIcon(severity), color: Colors.white, size: 12),
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
                      // Admin status badge
                      if (isAdmin)
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),

                // ── Body ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Material + time row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).tealLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              material,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.of(context).teal,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.of(context).textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _timeAgo(data['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.of(context).textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.of(context).textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.of(context).textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _locationLabel(data['location']),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.of(context).textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: AppColors.of(context).textMuted),
                        ],
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

  String _locationLabel(dynamic location) {
    if (location == null) return 'Unknown location';
    if (location is GeoPoint) {
      return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    }
    return 'Unknown location';
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: AppColors.of(context).tealLight,
      child: Center(
        child: Icon(Icons.image_outlined,
            color: AppColors.of(context).teal, size: 48),
      ),
    );
  }
}
