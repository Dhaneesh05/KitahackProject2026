import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_store.dart';
import '../models/admin_store.dart';
import '../models/activity.dart';
import '../models/activity_store.dart';
import '../theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _store = PostStore();
  late bool _liked;
  late bool _reposted;

  @override
  void initState() {
    super.initState();
    _liked = _store.likedPostIds.contains(widget.post.id);
    _reposted = _store.repostedPostIds.contains(widget.post.id);
  }

  Color get _severityColor {
    switch (widget.post.effectiveSeverity.toLowerCase()) {
      case 'danger': return Colors.red.shade500;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue.shade400;
      case 'clear': return AppColors.of(context).teal;
      default: return AppColors.of(context).textMuted;
    }
  }

  IconData get _severityIcon {
    switch (widget.post.effectiveSeverity.toLowerCase()) {
      case 'danger': return Icons.warning_amber_rounded;
      case 'medium': return Icons.water_rounded;
      case 'low': return Icons.water_drop_outlined;
      case 'clear': return Icons.check_circle_outline_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  Color _statusColor(PostStatus status) {
    switch (status) {
      case PostStatus.pending: return Colors.grey;
      case PostStatus.verified: return Colors.blue;
      case PostStatus.dispatchSent: return Colors.orange;
      case PostStatus.beingResolved: return Colors.amber.shade700;
      case PostStatus.weatherHindrance: return Colors.deepPurple;
      case PostStatus.resolved: return Colors.green;
      case PostStatus.notFlooded: return Colors.grey.shade600;
    }
  }

  IconData _statusIcon(PostStatus status) {
    switch (status) {
      case PostStatus.pending: return Icons.hourglass_empty_rounded;
      case PostStatus.verified: return Icons.verified_rounded;
      case PostStatus.dispatchSent: return Icons.local_shipping_rounded;
      case PostStatus.beingResolved: return Icons.build_circle_rounded;
      case PostStatus.weatherHindrance: return Icons.thunderstorm_rounded;
      case PostStatus.resolved: return Icons.check_circle_rounded;
      case PostStatus.notFlooded: return Icons.cancel_rounded;
    }
  }

  String get _initials {
    final parts = widget.post.authorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Color _avatarBgColor() {
    final colors = [
      const Color(0xFF00897B), const Color(0xFF1E88E5), const Color(0xFF8E24AA),
      const Color(0xFFD81B60), const Color(0xFF00ACC1), const Color(0xFF43A047),
    ];
    return colors[widget.post.authorName.hashCode.abs() % colors.length];
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_liked) {
        widget.post.likes++;
        _store.likedPostIds.add(widget.post.id);
      } else {
        widget.post.likes--;
        _store.likedPostIds.remove(widget.post.id);
      }
    });
    _store.savePostsToCsv();
  }

  void _toggleRepost() {
    setState(() {
      _reposted = !_reposted;
      if (_reposted) {
        widget.post.reposts++;
        _store.repostedPostIds.add(widget.post.id);
        final repost = widget.post.copyWithRepost(_store.currentUser);
        if (!_store.reposts.any((r) => r.id == repost.id)) {
          _store.reposts.add(repost);
        }
      } else {
        widget.post.reposts--;
        _store.repostedPostIds.remove(widget.post.id);
        _store.reposts.removeWhere((r) => r.id == '${widget.post.id}_repost_${_store.currentUser}');
      }
    });
    _store.savePostsToCsv();
  }

  /// Adds current user's verification to this post (with duplicate + self-post guards)
  void _addUserVerification() {
    final handle = _store.currentHandle;
    // Prevent verifying own post
    if (widget.post.authorHandle == handle) return;
    // Prevent double-verifying
    if (widget.post.verifiedByUsers.contains(handle)) return;

    setState(() {
      widget.post.verifiedByUsers.add(handle);
    });
    // Award points to the verifier
    _store.addPoints(
      _store.currentUser, 10, 'Verified a flood report',
      relatedPostId: widget.post.id,
    );
    _store.addPoints(
      widget.post.authorName, 10, 'Your post was verified by ${_store.currentUser}',
      relatedPostId: widget.post.id,
    );
    // Log activity
    ActivityStore().addActivity(Activity(
      id: 'verify_${widget.post.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.youVerified,
      title: 'You verified a flood report',
      subtitle: '${widget.post.authorName}\'s post • ${widget.post.content.length > 40 ? '${widget.post.content.substring(0, 40)}…' : widget.post.content}',
      timestamp: DateTime.now(),
      relatedPostId: widget.post.id,
    ));
    _store.savePostsToCsv();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyVerified = widget.post.verifiedByUsers.contains(_store.currentHandle);
    final isOwnPost = widget.post.authorHandle == _store.currentHandle;
    final isBanned = AdminStore().bannedHandles.contains(widget.post.authorHandle);
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBg,
        border: Border(bottom: BorderSide(color: AppColors.of(context).divider, width: 1)),
      ),
      child: Column(
        children: [
          // ── Status badge at top ──────────────────────────────────
          if (post.status != PostStatus.pending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _statusColor(post.status).withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(_statusIcon(post.status), size: 16, color: _statusColor(post.status)),
                  const SizedBox(width: 8),
                  Text(post.status.label, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: _statusColor(post.status),
                  )),
                ],
              ),
            ),
          // Repost header
          if (widget.post.repostedBy != null)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 10),
              child: Row(
                children: [
                  Icon(Icons.repeat_rounded, size: 14, color: AppColors.of(context).textMuted),
                  const SizedBox(width: 6),
                  Text('${widget.post.repostedBy} reposted',
                    style: TextStyle(fontSize: 13, color: AppColors.of(context).textMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isBanned ? Colors.red.shade100 : _avatarBgColor(),
                      child: isBanned
                          ? Icon(Icons.person_off_rounded, color: Colors.red.shade400, size: 20)
                          : Text(_initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author row
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(widget.post.authorName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 15,
                                      color: isBanned ? Colors.red.shade300 : AppColors.of(context).textPrimary,
                                      decoration: isBanned ? TextDecoration.lineThrough : null,
                                    )),
                                ),
                                if (widget.post.fullyVerified || widget.post.adminVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded, size: 16, color: Colors.blue.shade600),
                                ],
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text('${widget.post.authorHandle} · ${widget.post.timestamp}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: AppColors.of(context).textMuted)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.more_horiz, color: AppColors.of(context).textMuted, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Content
                      Text(widget.post.content, style: TextStyle(fontSize: 15, color: AppColors.of(context).textPrimary, height: 1.4)),
                      const SizedBox(height: 10),
                      // Image + severity badge
                      if (widget.post.imageUrl.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 380, minHeight: 120),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.black,
                                  width: double.infinity,
                                  child: widget.post.imageUrl.startsWith('assets/')
                                      ? Image.asset(
                                          widget.post.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 200,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48)),
                                        )
                                      : Image.network(
                                          widget.post.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 200,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48)),
                                          loadingBuilder: (_, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              height: 200,
                                              color: Colors.grey.shade100,
                                              child: Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.of(context).teal)),
                                            );
                                          },
                                        ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _severityColor
                                          .withValues(alpha: 0.92),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                            color: _severityColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3))
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_severityIcon,
                                            color: Colors.white, size: 13),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.post.effectiveSeverity
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                              letterSpacing: 0.8),
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Verification bar
                      _VerificationBar(
                        post: widget.post,
                        onUserVerify: _addUserVerification,
                        canVerify: !alreadyVerified && !isOwnPost && !widget.post.userVerified,
                        alreadyVerified: alreadyVerified,
                      ),
                      const SizedBox(height: 10),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ActionBtn(icon: Icons.chat_bubble_outline_rounded, count: widget.post.comments, activeColor: Colors.blue.shade400, onTap: () {}),
                          _ActionBtn(icon: Icons.repeat_rounded, count: widget.post.reposts, activeColor: Colors.green.shade500, isActive: _reposted, onTap: _toggleRepost),
                          _ActionBtn(icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, count: widget.post.likes, activeColor: Colors.red.shade400, isActive: _liked, onTap: _toggleLike),
                          _ActionBtn(icon: Icons.bar_chart_rounded, count: widget.post.likes * 3 + widget.post.reposts * 5, activeColor: Colors.blue.shade400, onTap: () {}),
                          _ActionBtn(icon: Icons.share_outlined, count: -1, activeColor: Colors.blue.shade400, onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verification Bar ──────────────────────────────────────────────────────────
class _VerificationBar extends StatelessWidget {
  final Post post;
  final VoidCallback onUserVerify;
  final bool canVerify;
  final bool alreadyVerified;
  const _VerificationBar({required this.post, required this.onUserVerify, required this.canVerify, required this.alreadyVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.of(context).glassBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.of(context).divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 13, color: AppColors.of(context).textMuted),
              const SizedBox(width: 4),
              Text('Verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.of(context).textSecondary)),
              const Spacer(),
              if (post.fullyVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade300)),
                  child: Text('✓ Fully Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              // User chip
              _VerifChip(
                label: 'Users ${post.userVerificationCount}/3',
                subLabel: alreadyVerified ? 'You verified' : (canVerify ? 'Tap +10 pts' : null),
                icon: Icons.people_outline_rounded,
                done: post.userVerified,
                color: Colors.blue,
                onTap: canVerify ? onUserVerify : null,
              ),
              const SizedBox(width: 6),
              _VerifChip(label: 'Admin', icon: Icons.admin_panel_settings_outlined, done: post.adminVerified, color: Colors.purple),
              const SizedBox(width: 6),
              _VerifChip(label: 'AI', icon: Icons.smart_toy_outlined, done: post.aiVerified, color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifChip extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData icon;
  final bool done;
  final Color color;
  final VoidCallback? onTap;
  const _VerifChip({required this.label, required this.icon, required this.done, required this.color, this.onTap, this.subLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: done ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: done ? color.withValues(alpha: 0.12) : (onTap != null ? color.withValues(alpha: 0.06) : AppColors.of(context).divider),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: done ? color.withValues(alpha: 0.5) : (onTap != null ? color.withValues(alpha: 0.4) : Colors.grey.shade300), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(done ? Icons.check_circle_rounded : icon, size: 12, color: done ? color : (onTap != null ? color : AppColors.of(context).textMuted)),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 11, color: done ? color : (onTap != null ? color : AppColors.of(context).textMuted), fontWeight: done ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
            if (subLabel != null) ...[
              Text(subLabel!, style: TextStyle(fontSize: 9, color: done ? Colors.green.shade600 : color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            ]
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.count, required this.activeColor, required this.onTap, this.isActive = false});

  String _fmt(int n) {
    if (n < 0) return '';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? activeColor : AppColors.of(context).textMuted),
            if (count >= 0) ...[
              const SizedBox(width: 4),
              Text(_fmt(count), style: TextStyle(fontSize: 13, color: isActive ? activeColor : AppColors.of(context).textMuted, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
            ],
          ],
        ),
      ),
    );
  }
}
