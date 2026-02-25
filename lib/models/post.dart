/// Status of a flood report as managed by admins.
enum PostStatus {
  pending,
  verified,
  dispatchSent,
  beingResolved,
  weatherHindrance,
  resolved,
  notFlooded,
}

extension PostStatusExt on PostStatus {
  String get label {
    switch (this) {
      case PostStatus.pending:
        return 'Under Review';
      case PostStatus.verified:
        return 'Verified';
      case PostStatus.dispatchSent:
        return 'Help is on the way';
      case PostStatus.beingResolved:
        return 'Being Resolved';
      case PostStatus.weatherHindrance:
        return 'Weather Hindrance';
      case PostStatus.resolved:
        return 'Resolved';
      case PostStatus.notFlooded:
        return 'Not Flooded';
    }
  }

  String get adminLabel {
    switch (this) {
      case PostStatus.pending:
        return 'Pending';
      case PostStatus.verified:
        return 'Verified (Active)';
      case PostStatus.dispatchSent:
        return 'Dispatch Sent';
      case PostStatus.beingResolved:
        return 'Being Resolved';
      case PostStatus.weatherHindrance:
        return 'Weather Hindrance';
      case PostStatus.resolved:
        return 'Resolved';
      case PostStatus.notFlooded:
        return 'False Alarm';
    }
  }
}

/// A single dispatch note (admin-only chat thread on a post).
class DispatchNote {
  final String adminName;
  final String message;
  final DateTime timestamp;

  DispatchNote({
    required this.adminName,
    required this.message,
    required this.timestamp,
  });
}

class Post {
  final String id;
  final String authorName;
  final String authorHandle;
  final String content;
  final String imageUrl;
  final String timestamp;
  int likes;
  int comments;
  int reposts;
  final String floodSeverity;

  // ── Admin fields ──────────────────────────────────────────────────────────
  PostStatus status;
  String? currentSeverity;     // Admin override — if null, uses floodSeverity
  String? originalSeverity;    // Snapshot of user-reported severity before override
  String? severityOverriddenBy;
  final List<DispatchNote> dispatchNotes;
  bool isDeleted;

  // Verification — stores handles of users who verified this post
  final Set<String> verifiedByUsers;
  bool adminVerified;
  bool aiVerified;

  // Repost meta — non-null if this is a repost
  String? repostedBy;

  Post({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.floodSeverity,
    Set<String>? verifiedByUsers,
    this.adminVerified = false,
    this.aiVerified = false,
    this.repostedBy,
    this.status = PostStatus.pending,
    this.currentSeverity,
    this.originalSeverity,
    this.severityOverriddenBy,
    List<DispatchNote>? dispatchNotes,
    this.isDeleted = false,
  })  : verifiedByUsers = verifiedByUsers ?? {},
        dispatchNotes = dispatchNotes ?? [];

  /// The effective severity shown in the UI (admin override takes priority).
  String get effectiveSeverity => currentSeverity ?? floodSeverity;

  /// At least 3 distinct users have verified this post
  bool get userVerified => verifiedByUsers.length >= 3;

  /// Count of user verifications
  int get userVerificationCount => verifiedByUsers.length;

  bool get fullyVerified => userVerified && adminVerified && aiVerified;

  factory Post.fromCsvRow(List<dynamic> row) {
    // Parse legacy int field for userVerifications (cols[10]) to seed a set
    final verifiedCount = int.tryParse(row.length > 10 ? row[10].toString() : '0') ?? 0;
    // Seed with placeholder names so pre-existing CSV verifications display correctly
    final Set<String> verifiedSet = {};
    for (int i = 0; i < verifiedCount && i < 3; i++) {
      verifiedSet.add('@seed_user_$i');
    }

    // Parse admin columns if present (cols 14-16)
    PostStatus parsedStatus = PostStatus.pending;
    if (row.length > 14 && row[14].toString().trim().isNotEmpty) {
      final statusStr = row[14].toString().trim();
      parsedStatus = PostStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => PostStatus.pending,
      );
    }
    String? parsedCurrentSeverity;
    if (row.length > 15 && row[15].toString().trim().isNotEmpty) {
      parsedCurrentSeverity = row[15].toString().trim();
    }
    bool parsedIsDeleted = false;
    if (row.length > 16) {
      parsedIsDeleted = row[16].toString().trim().toLowerCase() == 'true';
    }

    return Post(
      id: row[0].toString(),
      authorName: row[1].toString(),
      authorHandle: row[2].toString(),
      content: row[3].toString(),
      imageUrl: row[4].toString(),
      timestamp: row[5].toString(),
      likes: int.tryParse(row[6].toString()) ?? 0,
      comments: int.tryParse(row[7].toString()) ?? 0,
      reposts: int.tryParse(row[8].toString()) ?? 0,
      floodSeverity: row[9].toString(),
      verifiedByUsers: verifiedSet,
      adminVerified: (row.length > 11 ? row[11].toString().toLowerCase() : 'false') == 'true',
      aiVerified: (row.length > 12 ? row[12].toString().toLowerCase() : 'false') == 'true',
      repostedBy: (row.length > 13 && row[13].toString().trim().isNotEmpty) ? row[13].toString() : null,
      status: parsedStatus,
      currentSeverity: parsedCurrentSeverity,
      isDeleted: parsedIsDeleted,
    );
  }

  /// Converts this Post back to a CSV row list for persistence.
  /// Column order: id, authorName, authorHandle, content, imageUrl, timestamp,
  ///               likes, comments, reposts, floodSeverity, userVerifications,
  ///               adminVerified, aiVerified, repostedBy,
  ///               status, currentSeverity, isDeleted
  List<dynamic> toCsvRow() {
    return [
      id,
      authorName,
      authorHandle,
      content,
      imageUrl,
      timestamp,
      likes,
      comments,
      reposts,
      floodSeverity,
      verifiedByUsers.length,
      adminVerified,
      aiVerified,
      repostedBy ?? '',
      status.name,
      currentSeverity ?? '',
      isDeleted,
    ];
  }

  Post copyWithRepost(String repostedByUser) {
    return Post(
      id: '${id}_repost_$repostedByUser',
      authorName: authorName,
      authorHandle: authorHandle,
      content: content,
      imageUrl: imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
      reposts: reposts,
      floodSeverity: floodSeverity,
      verifiedByUsers: Set.from(verifiedByUsers),
      adminVerified: adminVerified,
      aiVerified: aiVerified,
      repostedBy: repostedByUser,
      status: status,
      currentSeverity: currentSeverity,
      originalSeverity: originalSeverity,
      severityOverriddenBy: severityOverriddenBy,
      dispatchNotes: List.from(dispatchNotes),
    );
  }
}
