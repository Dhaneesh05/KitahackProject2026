import 'package:flutter/material.dart';
import '../models/post_store.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'upload_mock_data_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = PostStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Post> get _myPosts => _store.posts.where((p) => p.authorHandle == _store.currentHandle && p.repostedBy == null).toList();
  List<Post> get _myReposts => _store.reposts.where((p) => p.repostedBy == _store.currentUser).toList();
  List<Post> get _myLikes => _store.posts.where((p) => _store.likedPostIds.contains(p.id)).toList();
  List<Post> get _mediaLikes => _myPosts.where((p) => p.imageUrl.isNotEmpty).toList();

  Color _avatarColor() {
    final colors = [
      const Color(0xFF00897B), const Color(0xFF1E88E5), const Color(0xFF8E24AA),
      const Color(0xFFD81B60), const Color(0xFF00ACC1), const Color(0xFF43A047),
    ];
    return colors[_store.currentUser.hashCode.abs() % colors.length];
  }

  void _handleLogout(BuildContext context) {
    _store.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(store: _store, avatarColor: _avatarColor()),
              collapseMode: CollapseMode.pin,
            ),
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: Container(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report_outlined, color: AppColors.textMuted),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadMockDataScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
                onPressed: () => _handleLogout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: _ProfileInfo(store: _store, myPostCount: _myPosts.length, myRepostCount: _myReposts.length),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.teal,
                indicatorWeight: 2.5,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Reposts'),
                  Tab(text: 'Media'),
                  Tab(text: 'Likes'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ProfilePostList(posts: _myPosts, emptyIcon: Icons.article_outlined, emptyText: 'No posts yet'),
            _ProfilePostList(posts: _myReposts, emptyIcon: Icons.repeat_rounded, emptyText: 'No reposts yet'),
            _ProfileMediaGrid(posts: _mediaLikes),
            _ProfilePostList(posts: _myLikes, emptyIcon: Icons.favorite_border_rounded, emptyText: 'No liked posts yet'),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header (Banner + Avatar) ─────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final PostStore store;
  final Color avatarColor;
  const _ProfileHeader({required this.store, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.teal, const Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Opacity(
            opacity: 0.15,
            child: Image.network(
              'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=800&fit=crop',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        // Overlapping avatar
        Positioned(
          left: 16,
          bottom: -40,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: avatarColor,
              child: Text(
                store.currentUser[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),
          ),
        ),
        // Edit profile button
        Positioned(
          right: 16,
          bottom: 0,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F1419), fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

// ── Profile Info Section ──────────────────────────────────────────────────────
class _ProfileInfo extends StatelessWidget {
  final PostStore store;
  final int myPostCount;
  final int myRepostCount;
  const _ProfileInfo({required this.store, required this.myPostCount, required this.myRepostCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.currentUser, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F1419))),
          const SizedBox(height: 2),
          Text(store.currentHandle, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text('Flood reporter & local hero 🌊 Keeping the community safe.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('Joined February 2026', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 10),
          // Verification stat summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.teal, size: 16),
                const SizedBox(width: 8),
                Text('${myPostCount + myRepostCount} total contributions  •  ${store.likedPostIds.length} verifications', style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Following / Followers
          Row(
            children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: '24 ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F1419))),
                TextSpan(text: 'Following', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              ])),
              const SizedBox(width: 16),
              RichText(text: TextSpan(children: [
                TextSpan(text: '8 ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F1419))),
                TextSpan(text: 'Followers', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              ])),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Tab Barr Delegate ─────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ── Profile Post List ─────────────────────────────────────────────────────────
class _ProfilePostList extends StatelessWidget {
  final List<Post> posts;
  final IconData emptyIcon;
  final String emptyText;
  const _ProfilePostList({required this.posts, required this.emptyIcon, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(emptyText, style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCard(post: posts[i]),
    );
  }
}

// ── Profile Media Grid ────────────────────────────────────────────────────────
class _ProfileMediaGrid extends StatelessWidget {
  final List<Post> posts;
  const _ProfileMediaGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('No media yet', style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        return Image.network(posts[i].imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200,
            child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400)));
      },
    );
  }
}
