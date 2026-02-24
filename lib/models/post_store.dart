import 'post.dart';

/// Singleton store for all posts and user state in memory.

/// This acts as our in-memory state management layer.
class PostStore {
  static final PostStore _instance = PostStore._internal();
  factory PostStore() => _instance;
  PostStore._internal();

  List<Post> posts = [];
  final String currentUser = 'You';
  final String currentHandle = '@you';
  final Set<String> likedPostIds = {};
  final Set<String> repostedPostIds = {};
  final List<Post> reposts = []; // posts reposted by current user
}
