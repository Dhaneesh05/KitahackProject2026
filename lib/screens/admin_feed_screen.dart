import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_store.dart';
import '../widgets/admin_post_card.dart';
import '../theme/app_theme.dart';

/// The admin's version of the feed — same posts but with admin controls.
class AdminFeedScreen extends StatefulWidget {
  const AdminFeedScreen({super.key});

  @override
  State<AdminFeedScreen> createState() => _AdminFeedScreenState();
}

class _AdminFeedScreenState extends State<AdminFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = PostStore();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (_store.posts.isNotEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      await _store.loadPostsFromLocal();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    _store.posts.clear();
    await _loadPosts();
  }

  List<Post> get _allPosts => _store.posts.where((p) => !p.isDeleted).toList();
  List<Post> get _pendingPosts => _allPosts.where((p) => p.status == PostStatus.pending).toList();
  List<Post> get _alertPosts => _allPosts.where((p) => p.effectiveSeverity.toLowerCase() == 'danger').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A3A).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.admin_panel_settings_rounded, color: const Color(0xFF1E3A3A), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Admin Feed', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_pendingPosts.length} Pending',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF1E3A3A),
                    indicatorWeight: 2.5,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: const [
                      Tab(text: 'All Reports'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Alerts 🚨'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(
                      color: const Color(0xFF1E3A3A), strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _AdminPostList(posts: _allPosts, onRefresh: _refresh, onChanged: () => setState(() {})),
                        _AdminPostList(posts: _pendingPosts, onRefresh: _refresh, onChanged: () => setState(() {})),
                        _AdminPostList(posts: _alertPosts, onRefresh: _refresh, onChanged: () => setState(() {})),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPostList extends StatelessWidget {
  final List<Post> posts;
  final Future<void> Function() onRefresh;
  final VoidCallback onChanged;
  const _AdminPostList({required this.posts, required this.onRefresh, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No reports', style: TextStyle(
            color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF1E3A3A),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) => AdminPostCard(
              post: posts[i],
              onDeleted: onChanged,
              onStatusChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
