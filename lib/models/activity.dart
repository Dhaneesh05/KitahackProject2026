import 'package:flutter/material.dart';

/// The type of activity that occurred.
enum ActivityType {
  youVerified,       // You verified someone else's post
  yourPostVerified,  // Another user verified your post
  adminVerified,     // An admin verified your post
  statusChanged,     // Admin changed the status of your post
  severityChanged,   // Admin overrode the severity of your post
  youPosted,         // You submitted a new report
  pointsEarned,      // You earned points
}

/// A single item in the activity feed.
class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? relatedPostId;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.relatedPostId,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.youVerified:
        return Icons.verified_user_outlined;
      case ActivityType.yourPostVerified:
        return Icons.thumb_up_alt_outlined;
      case ActivityType.adminVerified:
        return Icons.admin_panel_settings_outlined;
      case ActivityType.statusChanged:
        return Icons.sync_rounded;
      case ActivityType.severityChanged:
        return Icons.warning_amber_rounded;
      case ActivityType.youPosted:
        return Icons.water_drop_outlined;
      case ActivityType.pointsEarned:
        return Icons.emoji_events_outlined;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.youVerified:
        return Colors.blue;
      case ActivityType.yourPostVerified:
        return Colors.green;
      case ActivityType.adminVerified:
        return const Color(0xFF1E3A3A);
      case ActivityType.statusChanged:
        return Colors.teal;
      case ActivityType.severityChanged:
        return Colors.orange;
      case ActivityType.youPosted:
        return Colors.teal;
      case ActivityType.pointsEarned:
        return Colors.amber;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
