import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/admin_post_card.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';

/// The admin's version of the feed — powered by Firebase Firestore.
class AdminFeedScreen extends StatefulWidget {
  const AdminFeedScreen({super.key});

  @override
  State<AdminFeedScreen> createState() => _AdminFeedScreenState();
}

class _AdminFeedScreenState extends State<AdminFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: DatabaseService().getFeedPostsStream(),
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? [];
            final pendingPosts =
                allPosts.where((p) => p.status == PostStatus.pending).toList();
            final alertPosts = allPosts
                .where((p) =>
                    p.effectiveSeverity.toLowerCase() == 'danger')
                .toList();

            return Column(
              children: [
                // ── Header ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A3A)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: const Color(0xFF1E3A3A),
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('Admin Feed',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5)),
                            const Spacer(),
                            // Live pending count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${pendingPosts.length} Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
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
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: const [
                          Tab(text: 'All Reports'),
                          Tab(text: 'Pending'),
                          Tab(text: 'Alerts 🚨'),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Content ───────────────────────────────────────────
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? Center(
                          child: CircularProgressIndicator(
                              color: const Color(0xFF1E3A3A), strokeWidth: 2))
                      : snapshot.hasError
                          ? _ErrorView(error: snapshot.error.toString())
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _AdminPostList(posts: allPosts),
                                _AdminPostList(posts: pendingPosts),
                                _AdminPostList(posts: alertPosts),
                              ],
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Post list ───────────────────────────────────────────────────────────────

class _AdminPostList extends StatelessWidget {
  final List<Post> posts;
  const _AdminPostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No reports',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ]),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) => AdminPostCard(post: posts[i]),
        ),
      ),
    );
  }
}

// ─── Error view ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Could not load posts',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}
