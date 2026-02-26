import 'package:flutter/foundation.dart';
import 'activity.dart';

/// Singleton that holds the global activity feed.
/// Extends ChangeNotifier so widgets can listen for updates.
class ActivityStore extends ChangeNotifier {
  static final ActivityStore _instance = ActivityStore._internal();
  factory ActivityStore() => _instance;
  ActivityStore._internal() {
    _seedInitialActivities();
  }

  final List<Activity> _activities = [];

  /// Returns the most recent [limit] activities.
  List<Activity> getRecent({int limit = 3}) {
    return _activities.take(limit).toList();
  }

  /// Adds a new activity to the top of the feed, capped at 20 entries.
  void addActivity(Activity activity) {
    _activities.insert(0, activity);
    if (_activities.length > 20) _activities.removeLast();
    notifyListeners();
  }

  // ─── Seed some mock activities for first-run ─────────────────────────────
  void _seedInitialActivities() {
    _activities.addAll([
      Activity(
        id: 'seed_1',
        type: ActivityType.yourPostVerified,
        title: 'Your report was verified',
        subtitle: 'Community verified your Jalan Ampang post',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        relatedPostId: null,
      ),
      Activity(
        id: 'seed_2',
        type: ActivityType.youVerified,
        title: 'You verified a flood report',
        subtitle: 'Bangsar flash flood • 2h ago',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        relatedPostId: null,
      ),
      Activity(
        id: 'seed_3',
        type: ActivityType.pointsEarned,
        title: 'Badge Earned: Water Guardian',
        subtitle: 'Keep verifying to maintain your rank',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        relatedPostId: null,
      ),
    ]);
  }
}
