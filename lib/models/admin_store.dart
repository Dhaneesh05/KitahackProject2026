import 'post.dart';
import 'post_store.dart';

/// Types of actions an admin can take.
enum AdminActionType {
  verifiedPost,
  dispatchSent,
  statusChanged,
  severityOverride,
  deletedPost,
  bannedUser,
  resolvedPost,
  weatherHindrance,
  markedNotFlooded,
}

extension AdminActionTypeExt on AdminActionType {
  String get label {
    switch (this) {
      case AdminActionType.verifiedPost:
        return 'Verified Post';
      case AdminActionType.dispatchSent:
        return 'Dispatch Sent';
      case AdminActionType.statusChanged:
        return 'Status Changed';
      case AdminActionType.severityOverride:
        return 'Severity Override';
      case AdminActionType.deletedPost:
        return 'Deleted Post';
      case AdminActionType.bannedUser:
        return 'Banned User';
      case AdminActionType.resolvedPost:
        return 'Resolved Post';
      case AdminActionType.weatherHindrance:
        return 'Weather Hindrance';
      case AdminActionType.markedNotFlooded:
        return 'Marked Not Flooded';
    }
  }

  String get icon {
    switch (this) {
      case AdminActionType.verifiedPost:
        return '✅';
      case AdminActionType.dispatchSent:
        return '🚒';
      case AdminActionType.statusChanged:
        return '🔄';
      case AdminActionType.severityOverride:
        return '⚠️';
      case AdminActionType.deletedPost:
        return '🗑️';
      case AdminActionType.bannedUser:
        return '🚫';
      case AdminActionType.resolvedPost:
        return '✓';
      case AdminActionType.weatherHindrance:
        return '🌧️';
      case AdminActionType.markedNotFlooded:
        return '❌';
    }
  }
}

/// Record of a single admin action for the audit trail.
class AdminAction {
  final String id;
  final AdminActionType type;
  final String adminName;
  final String? postId;
  final String? targetUsername;
  final String? details;
  final DateTime timestamp;

  AdminAction({
    required this.id,
    required this.type,
    required this.adminName,
    this.postId,
    this.targetUsername,
    this.details,
    required this.timestamp,
  });
}

/// Record of a banned user.
class BannedUser {
  final String username;
  final String handle;
  final String reason;
  final String bannedBy;
  final DateTime bannedAt;
  final bool isPermanent;

  BannedUser({
    required this.username,
    required this.handle,
    required this.reason,
    required this.bannedBy,
    required this.bannedAt,
    this.isPermanent = true,
  });
}

/// Singleton store for all admin-related state.
class AdminStore {
  static final AdminStore _instance = AdminStore._internal();
  factory AdminStore() => _instance;
  AdminStore._internal();

  // ─── Identity ──────────────────────────────────────────────────────────────
  final String adminName = 'City Council Admin';
  final String adminHandle = '@cityhall';

  // ─── Action history (audit trail) ─────────────────────────────────────────
  final List<AdminAction> actionHistory = [];

  // ─── Banned users ─────────────────────────────────────────────────────────
  final List<BannedUser> bannedUsers = [];
  final Set<String> bannedHandles = {};

  // ─── Deleted posts ────────────────────────────────────────────────────────
  final List<Post> deletedPosts = [];

  // ─── Helper: log an action ────────────────────────────────────────────────
  void logAction(AdminActionType type, {String? postId, String? targetUser, String? details}) {
    actionHistory.insert(0, AdminAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      adminName: adminName,
      postId: postId,
      targetUsername: targetUser,
      details: details,
      timestamp: DateTime.now(),
    ));
  }

  // ─── Post actions ─────────────────────────────────────────────────────────

  void verifyPost(Post post) {
    post.adminVerified = true;
    post.status = PostStatus.verified;
    logAction(AdminActionType.verifiedPost, postId: post.id, details: 'Verified: ${post.content.substring(0, post.content.length > 40 ? 40 : post.content.length)}...');
    _persist();
  }

  void sendDispatch(Post post, String note) {
    post.status = PostStatus.dispatchSent;
    post.dispatchNotes.add(DispatchNote(
      adminName: adminName,
      message: note,
      timestamp: DateTime.now(),
    ));
    logAction(AdminActionType.dispatchSent, postId: post.id, details: note);
    _persist();
  }

  void updateStatus(Post post, PostStatus newStatus) {
    final oldStatus = post.status;
    post.status = newStatus;

    AdminActionType actionType;
    switch (newStatus) {
      case PostStatus.resolved:
        actionType = AdminActionType.resolvedPost;
        break;
      case PostStatus.weatherHindrance:
        actionType = AdminActionType.weatherHindrance;
        break;
      case PostStatus.notFlooded:
        actionType = AdminActionType.markedNotFlooded;
        break;
      default:
        actionType = AdminActionType.statusChanged;
    }
    logAction(actionType, postId: post.id, details: '${oldStatus.adminLabel} → ${newStatus.adminLabel}');
    _persist();
  }

  void overrideSeverity(Post post, String newSeverity) {
    post.originalSeverity ??= post.floodSeverity;
    final oldSeverity = post.effectiveSeverity;
    post.currentSeverity = newSeverity;
    post.severityOverriddenBy = adminName;
    logAction(AdminActionType.severityOverride, postId: post.id, details: '$oldSeverity → $newSeverity');
    _persist();
  }

  void deletePost(Post post, List<Post> allPosts) {
    post.isDeleted = true;
    deletedPosts.add(post);
    allPosts.remove(post);
    logAction(AdminActionType.deletedPost, postId: post.id, details: 'Deleted: ${post.content.substring(0, post.content.length > 40 ? 40 : post.content.length)}...');
    _persist();
  }

  void banUser(String username, String handle, String reason) {
    bannedUsers.add(BannedUser(
      username: username,
      handle: handle,
      reason: reason,
      bannedBy: adminName,
      bannedAt: DateTime.now(),
    ));
    bannedHandles.add(handle);
    logAction(AdminActionType.bannedUser, targetUser: handle, details: reason);
    _persist();
  }

  void addDispatchNote(Post post, String note) {
    post.dispatchNotes.add(DispatchNote(
      adminName: adminName,
      message: note,
      timestamp: DateTime.now(),
    ));
    _persist();
  }

  /// Persist all posts to local CSV after any mutation.
  void _persist() {
    PostStore().savePostsToCsv();
  }

  // ─── Filtered history helpers ─────────────────────────────────────────────

  List<AdminAction> getHistory(AdminActionType type) =>
      actionHistory.where((a) => a.type == type).toList();

  List<AdminAction> get verifiedHistory => getHistory(AdminActionType.verifiedPost);
  List<AdminAction> get dispatchHistory => getHistory(AdminActionType.dispatchSent);
  List<AdminAction> get resolvedHistory => getHistory(AdminActionType.resolvedPost);
  List<AdminAction> get deletedHistory => getHistory(AdminActionType.deletedPost);
  List<AdminAction> get bannedHistory => getHistory(AdminActionType.bannedUser);
  List<AdminAction> get weatherHistory => getHistory(AdminActionType.weatherHindrance);
  List<AdminAction> get severityOverrideHistory => getHistory(AdminActionType.severityOverride);

  // ─── Stats ────────────────────────────────────────────────────────────────

  int get totalActions => actionHistory.length;
  int get activeDispatches => actionHistory.where((a) => a.type == AdminActionType.dispatchSent).length;
  int get totalResolved => resolvedHistory.length;
  int get totalBanned => bannedUsers.length;
}
