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

  // Verification
  int userVerifications; // 3 needed for full user verification
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
    this.userVerifications = 0,
    this.adminVerified = false,
    this.aiVerified = false,
    this.repostedBy,
  });

  bool get userVerified => userVerifications >= 3;

  bool get fullyVerified => userVerified && adminVerified && aiVerified;

  factory Post.fromCsvRow(List<dynamic> row) {
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
      userVerifications: int.tryParse(row.length > 10 ? row[10].toString() : '0') ?? 0,
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
      userVerifications: userVerifications,
      adminVerified: adminVerified,
      aiVerified: aiVerified,
      repostedBy: repostedByUser,
    );
  }
}
