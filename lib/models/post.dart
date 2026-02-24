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
  }) : verifiedByUsers = verifiedByUsers ?? {};

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
    );
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
    );
  }
}
