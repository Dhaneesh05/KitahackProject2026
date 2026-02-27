import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_store.dart';
import '../services/database_service.dart';
import '../widgets/post_card.dart';
import '../theme/app_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = PostStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).scaffoldBg,
                border: Border(bottom: BorderSide(color: AppColors.of(context).divider)),
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
                          decoration: BoxDecoration(color: AppColors.of(context).tealLight, shape: BoxShape.circle),
                          child: Icon(Icons.water_drop_rounded, color: AppColors.of(context).teal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Flood Reports',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary, letterSpacing: -0.5)),
                        const Spacer(),
                        Icon(Icons.tune_rounded, color: AppColors.of(context).textMuted, size: 22),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.of(context).teal,
                    indicatorWeight: 2.5,
                    labelColor: AppColors.of(context).textPrimary,
                    unselectedLabelColor: AppColors.of(context).textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    tabs: const [Tab(text: 'For You'), Tab(text: 'Alerts 🚨')],
                  ),
                ],
              ),
            ),

            // ── Live Feed via Firestore Stream ──────────────────────
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: DatabaseService().getFeedPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: AppColors.of(context).teal, strokeWidth: 2));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.of(context).textMuted),
                            const SizedBox(height: 12),
                            Text('Could not load posts',
                                style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('${snapshot.error}', style: TextStyle(color: AppColors.of(context).textMuted, fontSize: 12), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }

                  final allPosts = snapshot.data ?? [];
                  final alertPosts = allPosts.where((p) => p.effectiveSeverity.toLowerCase() == 'danger').toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _PostList(posts: allPosts),
                      _PostList(posts: alertPosts),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context),
        backgroundColor: AppColors.of(context).teal,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: AppColors.of(context).scaffoldBg, size: 28),
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).scaffoldBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _NewPostSheet(onPost: (post) {
        // Points awarded on submission
        _store.addPoints(_store.currentUser, 50, 'Submitted a flood report', relatedPostId: post.id);
      }),
    );
  }
}

// ─── Post List Widget ─────────────────────────────────────────────────────────
class _PostList extends StatelessWidget {
  final List<Post> posts;
  const _PostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.water_drop_outlined, size: 52, color: AppColors.of(context).textMuted),
          const SizedBox(height: 12),
          Text('No reports yet', style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Be the first to report a flood!', style: TextStyle(color: AppColors.of(context).textMuted, fontSize: 13)),
        ]),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: posts.length,
          itemBuilder: (_, i) => PostCard(post: posts[i]),
        ),
      ),
    );
  }
}

class _NewPostSheet extends StatefulWidget {
  final void Function(Post) onPost;
  const _NewPostSheet({required this.onPost});
  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _controller = TextEditingController();
  String _severity = 'Low';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final severities = [
      {'label': 'Clear', 'color': AppColors.of(context).teal},
      {'label': 'Low', 'color': Colors.blue},
      {'label': 'Medium', 'color': Colors.orange},
      {'label': 'Danger', 'color': Colors.red},
    ];
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textMuted))),
              const Spacer(),
              const Text('New Report',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).teal,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    elevation: 0),
                child: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "What's happening with floods near you?",
              hintStyle: TextStyle(color: AppColors.of(context).textMuted, fontSize: 16),
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 16, color: AppColors.of(context).textPrimary),
          ),
          const SizedBox(height: 8),
          Text('Flood Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.of(context).textMuted)),
          const SizedBox(height: 8),
          Row(
            children: severities.map((s) {
              final isSelected = _severity == s['label'];
              final color = s['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _severity = s['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.12) : AppColors.of(context).divider,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                    ),
                    child: Text(s['label'] as String,
                        style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(children: [Icon(Icons.image_outlined, color: AppColors.of(context).teal), const SizedBox(width: 16), Icon(Icons.location_on_outlined, color: AppColors.of(context).teal)]),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submitPost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);
    final store = PostStore();

    try {
      final docId = await DatabaseService().submitReport({
        'authorName': store.currentUser,
        'authorHandle': store.currentHandle,
        'description': text,
        'content': text,
        'imageUrl': '',
        'severityScore': _severity,
        'floodSeverity': _severity,
      });

      // Build a local Post for the points callback
      final post = Post(
        id: docId,
        authorName: store.currentUser,
        authorHandle: store.currentHandle,
        content: text,
        imageUrl: '',
        timestamp: 'just now',
        likes: 0,
        comments: 0,
        reposts: 0,
        floodSeverity: _severity,
      );

      widget.onPost(post);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error posting: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
