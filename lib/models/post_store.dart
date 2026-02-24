import 'post.dart';

/// A point transaction entry
class PointTransaction {
  final String reason;
  final int amount; // positive = earned, negative = spent
  final DateTime timestamp;
  final String? relatedPostId;

  PointTransaction({
    required this.reason,
    required this.amount,
    required this.timestamp,
    this.relatedPostId,
  });
}

/// Singleton store for all in-memory app state.
class PostStore {
  static final PostStore _instance = PostStore._internal();
  factory PostStore() => _instance;
  PostStore._internal();

  // ─── Identity ──────────────────────────────────────────────────────────────
  final String currentUser = 'You';
  final String currentHandle = '@you';

  // ─── Feed state ────────────────────────────────────────────────────────────
  List<Post> posts = [];
  final Set<String> likedPostIds = {};
  final Set<String> repostedPostIds = {};
  final List<Post> reposts = [];

  // ─── Points: all users ─────────────────────────────────────────────────────
  /// Current point balance per user (keyed by username)
  final Map<String, int> userPoints = {
    'You': 80,
    'Ahmad Razif': 320,
    'Nurul Izzah': 150,
    'Haziq Farouk': 220,
    'Sarah Lim': 95,
    'Reza Amsyar': 450,
    'Priya Nair': 60,
    'Wong Kah Fai': 130,
  };

  /// Transaction history per user (keyed by username)
  final Map<String, List<PointTransaction>> userPointHistory = {
    'You': [
      PointTransaction(reason: 'Welcome bonus 🎉', amount: 50, timestamp: DateTime.now().subtract(const Duration(days: 3))),
      PointTransaction(reason: 'Submitted flood report', amount: 50, timestamp: DateTime.now().subtract(const Duration(hours: 10))),
      PointTransaction(reason: 'Post verified by community', amount: 10, timestamp: DateTime.now().subtract(const Duration(hours: 8))),
      PointTransaction(reason: 'Verified a report', amount: 10, timestamp: DateTime.now().subtract(const Duration(hours: 5))),
      PointTransaction(reason: 'Verified a report', amount: 10, timestamp: DateTime.now().subtract(const Duration(hours: 3))),
      PointTransaction(reason: 'Redeemed: RM10 Touch \'n Go eWallet', amount: -50, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    ],
  };

  // ─── Lifetime points (for rank calculation) ────────────────────────────────
  final Map<String, int> userLifetimePoints = {
    'You': 130,
  };

  // ─── Point methods ─────────────────────────────────────────────────────────

  int getPoints(String username) => userPoints[username] ?? 0;

  List<PointTransaction> getHistory(String username) =>
      List.unmodifiable(userPointHistory[username]?.reversed.toList() ?? []);

  void addPoints(String username, int amount, String reason, {String? relatedPostId}) {
    userPoints[username] = (userPoints[username] ?? 0) + amount;
    userLifetimePoints[username] = (userLifetimePoints[username] ?? 0) + amount;
    userPointHistory.putIfAbsent(username, () => []).add(
      PointTransaction(reason: reason, amount: amount, timestamp: DateTime.now(), relatedPostId: relatedPostId),
    );
  }

  /// Returns true if redemption succeeded, false if not enough points.
  bool redeemPoints(String username, int cost, String rewardName) {
    final balance = userPoints[username] ?? 0;
    if (balance < cost) return false;
    userPoints[username] = balance - cost;
    userPointHistory.putIfAbsent(username, () => []).add(
      PointTransaction(reason: 'Redeemed: $rewardName', amount: -cost, timestamp: DateTime.now()),
    );
    return true;
  }

  /// Rank based on lifetime points earned
  String getRank(String username) {
    final lifetime = userLifetimePoints[username] ?? 0;
    if (lifetime >= 2000) return 'Platinum';
    if (lifetime >= 1000) return 'Gold';
    if (lifetime >= 300) return 'Silver';
    return 'Bronze';
  }

  int getRankThreshold(String username) {
    final lifetime = userLifetimePoints[username] ?? 0;
    if (lifetime >= 2000) return 2000;
    if (lifetime >= 1000) return 2000;
    if (lifetime >= 300) return 1000;
    return 300;
  }
}
