import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/post.dart';
import '../models/post_store.dart';
import '../widgets/post_card.dart';
import '../theme/app_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = PostStore();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    try {
      final rawCsv = await rootBundle.loadString('assets/data/posts.csv');
      final rows = const CsvToListConverter(eol: '\n').convert(rawCsv);
      final posts = rows.skip(1).where((r) => r.length >= 10).map((r) => Post.fromCsvRow(r)).toList();
      setState(() {
        _store.posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadPosts();
  }

  List<Post> get _alertPosts => _store.posts.where((p) => p.floodSeverity.toLowerCase() == 'danger').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(color: AppColors.of(context).scaffoldBg, border: Border(bottom: BorderSide(color: AppColors.of(context).divider))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.of(context).tealLight, shape: BoxShape.circle),
                          child: Icon(Icons.water_drop_rounded, color: AppColors.of(context).teal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Flood Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary, letterSpacing: -0.5)),
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
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    tabs: const [Tab(text: 'For You'), Tab(text: 'Alerts 🚨')],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.of(context).teal, strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _PostList(posts: _store.posts, onRefresh: _refresh),
                        _PostList(posts: _alertPosts, onRefresh: _refresh),
                      ],
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
        setState(() => _store.posts.insert(0, post));
        // Award points for submitting a report
        _store.addPoints(_store.currentUser, 50, 'Submitted a flood report', relatedPostId: post.id);
      }),
    );
  }
}

class _PostList extends StatelessWidget {
  final List<Post> posts;
  final Future<void> Function() onRefresh;
  const _PostList({required this.posts, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.water_drop_outlined, size: 52, color: AppColors.of(context).textMuted),
          const SizedBox(height: 12),
          Text('No reports yet', style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.of(context).teal,
      child: ListView.builder(itemCount: posts.length, itemBuilder: (_, i) => PostCard(post: posts[i])),
    );
  }
}

// ─── New Post Bottom Sheet ─────────────────────────────────────────────────────
class _NewPostSheet extends StatefulWidget {
  final void Function(Post) onPost;
  const _NewPostSheet({required this.onPost});
  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _controller = TextEditingController();
  String _severity = 'Low';



  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _severities = [
      {'label': 'Clear', 'color': AppColors.of(context).teal},
      {'label': 'Low', 'color': Colors.blue},
      {'label': 'Medium', 'color': Colors.orange},
      {'label': 'Danger', 'color': Colors.red},
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textMuted))),
              const Spacer(),
              const Text('New Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).teal, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), elevation: 0),
                child: const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
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
            children: _severities.map((s) {
              final isSelected = _severity == s['label'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _severity = s['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? (s['color'] as Color).withValues(alpha: 0.12) : AppColors.of(context).divider,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? (s['color'] as Color) : Colors.transparent, width: 1.5),
                    ),
                    child: Text(s['label'] as String, style: TextStyle(color: isSelected ? (s['color'] as Color) : Colors.grey, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
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

  void _submitPost() {
    if (_controller.text.trim().isEmpty) { Navigator.pop(context); return; }
    final store = PostStore();
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: store.currentUser,
      authorHandle: store.currentHandle,
      content: _controller.text.trim(),
      imageUrl: 'https://images.unsplash.com/photo-1561484930-998b6a7b22e8?w=600&fit=crop',
      timestamp: 'just now',
      likes: 0, comments: 0, reposts: 0,
      floodSeverity: _severity,
      adminVerified: false, aiVerified: false,
    );
    widget.onPost(post);
    Navigator.pop(context);
  }
}
