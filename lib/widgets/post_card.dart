import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_store.dart';
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
    switch (widget.post.floodSeverity.toLowerCase()) {
      case 'danger': return Colors.red.shade500;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue.shade400;
      case 'clear': return AppColors.teal;
      default: return AppColors.textMuted;
    }
  }

  IconData get _severityIcon {
    switch (widget.post.floodSeverity.toLowerCase()) {
      case 'danger': return Icons.warning_amber_rounded;
      case 'medium': return Icons.water_rounded;
      case 'low': return Icons.water_drop_outlined;
      case 'clear': return Icons.check_circle_outline_rounded;
      default: return Icons.help_outline_rounded;
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
  }

  void _toggleRepost() {
    setState(() {
      _reposted = !_reposted;
      if (_reposted) {
        widget.post.reposts++;
        _store.repostedPostIds.add(widget.post.id);
        // Add repost to profile store
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
  }

  void _addUserVerification() {
    setState(() {
      if (widget.post.userVerifications < 3) {
        widget.post.userVerifications++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          // Repost header
          if (widget.post.repostedBy != null)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 10),
              child: Row(
                children: [
                  Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.post.repostedBy} reposted',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _avatarBgColor(),
                  child: Text(_initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.post.authorName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F1419)),
                                  ),
                                ),
                                // Verification checkmark
                                if (widget.post.fullyVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded, size: 16, color: Colors.blue.shade600),
                                ],
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${widget.post.authorHandle} · ${widget.post.timestamp}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.more_horiz, color: Colors.grey.shade500, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Content
                      Text(widget.post.content, style: const TextStyle(fontSize: 15, color: Color(0xFF0F1419), height: 1.4)),
                      const SizedBox(height: 10),
                      // Image + flood badge
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.network(
                              widget.post.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48),
                              ),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey.shade100,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                                );
                              },
                            ),
                            // Severity badge
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _severityColor.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: _severityColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_severityIcon, color: Colors.white, size: 13),
                                    const SizedBox(width: 4),
                                    Text(widget.post.floodSeverity.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Verification status bar
                      _VerificationBar(post: widget.post, onUserVerify: _addUserVerification),
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

// ── Verification Bar ─────────────────────────────────────────────────────────
class _VerificationBar extends StatelessWidget {
  final Post post;
  final VoidCallback onUserVerify;
  const _VerificationBar({required this.post, required this.onUserVerify});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 13, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('Verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
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
              // User verifications (3 needed)
              _VerifChip(
                label: 'Users ${post.userVerifications}/3',
                icon: Icons.people_outline_rounded,
                done: post.userVerified,
                color: Colors.blue,
                onTap: onUserVerify,
              ),
              const SizedBox(width: 6),
              // Admin
              _VerifChip(
                label: 'Admin',
                icon: Icons.admin_panel_settings_outlined,
                done: post.adminVerified,
                color: Colors.purple,
              ),
              const SizedBox(width: 6),
              // AI
              _VerifChip(
                label: 'AI',
                icon: Icons.smart_toy_outlined,
                done: post.aiVerified,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final Color color;
  final VoidCallback? onTap;
  const _VerifChip({required this.label, required this.icon, required this.done, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: done ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: done ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: done ? color.withValues(alpha: 0.5) : Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(done ? Icons.check_circle_rounded : icon, size: 12, color: done ? color : Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: done ? color : Colors.grey.shade600, fontWeight: done ? FontWeight.w700 : FontWeight.w500)),
            // Tap to verify hint
            if (!done && onTap != null) ...[
              const SizedBox(width: 3),
              Icon(Icons.add_circle_outline, size: 11, color: color),
            ],
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
            Icon(icon, size: 18, color: isActive ? activeColor : Colors.grey.shade500),
            if (count >= 0) ...[
              const SizedBox(width: 4),
              Text(_fmt(count), style: TextStyle(fontSize: 13, color: isActive ? activeColor : Colors.grey.shade600, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
            ],
          ],
        ),
      ),
    );
  }
}
