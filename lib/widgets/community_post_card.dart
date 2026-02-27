
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

/// Social-style card that renders a Firestore `community_feed` document.
/// Mirrors the PostCard layout but works directly with Firestore map data.
class CommunityPostCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const CommunityPostCard({super.key, required this.data, required this.docId});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool _liked = false;
  bool _reposted = false;
  late int _likes;
  late int _reposts;

  @override
  void initState() {
    super.initState();
    _likes = widget.data['likes'] as int? ?? 0;
    _reposts = widget.data['reposts'] as int? ?? 0;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'danger': return Colors.red.shade500;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue.shade400;
      case 'clear': return const Color(0xFF3FC9A8);
      default: return Colors.grey;
    }
  }

  IconData _severityIcon(String s) {
    switch (s.toLowerCase()) {
      case 'danger': return Icons.warning_amber_rounded;
      case 'medium': return Icons.water_rounded;
      case 'low': return Icons.water_drop_outlined;
      case 'clear': return Icons.check_circle_outline_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String get _initials {
    final name = (widget.data['authorName'] as String? ?? 'U').trim();
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Color _avatarColor() {
    final colors = [
      const Color(0xFF00897B), const Color(0xFF1E88E5), const Color(0xFF8E24AA),
      const Color(0xFFD81B60), const Color(0xFF00ACC1), const Color(0xFF43A047),
    ];
    final name = widget.data['authorName'] as String? ?? '';
    return colors[name.hashCode.abs() % colors.length];
  }



  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    // Optimistic Firestore update
    FirebaseFirestore.instance.collection('community_feed').doc(widget.docId).update({'likes': _likes});
  }

  void _toggleRepost() {
    setState(() {
      _reposted = !_reposted;
      _reposts += _reposted ? 1 : -1;
    });
    FirebaseFirestore.instance.collection('community_feed').doc(widget.docId).update({'reposts': _reposts});
  }

  @override
  Widget build(BuildContext context) {
    final String authorName   = widget.data['authorName']  as String? ?? 'Unknown';
    final String authorHandle = widget.data['authorHandle'] as String? ?? '@user';
    final String content      = widget.data['content']     as String? ?? '';
    final String imageUrl     = widget.data['imageUrl']    as String? ?? '';
    final String timestamp    = widget.data['timestamp']   as String? ?? '';
    final String severity     = widget.data['floodSeverity'] as String? ?? 'Low';
    final int    comments     = widget.data['comments']   as int? ?? 0;
    final bool   adminVerified = widget.data['adminVerified'] as bool? ?? false;
    final bool   aiVerified    = widget.data['aiVerified']    as bool? ?? false;
    final int    userVerifs    = widget.data['userVerifications'] as int? ?? 0;

    final Color sColor = _severityColor(severity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBg,
        border: Border(bottom: BorderSide(color: AppColors.of(context).divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ───────────────────────────────────────────────
            CircleAvatar(
              radius: 22,
              backgroundColor: _avatarColor(),
              child: Text(_initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const SizedBox(width: 12),

            // ── Content column ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(
                    children: [
                      Flexible(
                        child: Text(authorName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.of(context).textPrimary)),
                      ),
                      if (adminVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 15, color: Colors.blue.shade600),
                      ],
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text('$authorHandle · $timestamp',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: AppColors.of(context).textMuted)),
                      ),
                      const Spacer(),
                      Icon(Icons.more_horiz, color: AppColors.of(context).textMuted, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Post content
                  Text(content,
                    style: TextStyle(fontSize: 15, color: AppColors.of(context).textPrimary, height: 1.4)),
                  const SizedBox(height: 10),

                  // Image + severity badge
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) => progress == null
                                  ? child
                                  : Container(
                                      color: Colors.grey.shade100,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: AppColors.of(context).teal))),
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image_outlined,
                                    color: Colors.grey.shade400, size: 48)),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: sColor.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: sColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_severityIcon(severity), color: Colors.white, size: 13),
                                    const SizedBox(width: 4),
                                    Text(severity.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8)),
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
                  Container(
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
                            if (adminVerified && aiVerified && userVerifs >= 3) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade300)),
                                child: Text('✓ Fully Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(children: [
                          _VerifChip(label: 'Users $userVerifs/3', icon: Icons.people_outline_rounded, done: userVerifs >= 3, color: Colors.blue),
                          const SizedBox(width: 6),
                          _VerifChip(label: 'Admin', icon: Icons.admin_panel_settings_outlined, done: adminVerified, color: Colors.purple),
                          const SizedBox(width: 6),
                          _VerifChip(label: 'AI', icon: Icons.smart_toy_outlined, done: aiVerified, color: Colors.orange),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionBtn(icon: Icons.chat_bubble_outline_rounded, count: comments, activeColor: Colors.blue.shade400, onTap: () {}),
                      _ActionBtn(icon: Icons.repeat_rounded, count: _reposts, activeColor: Colors.green.shade500, isActive: _reposted, onTap: _toggleRepost),
                      _ActionBtn(icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, count: _likes, activeColor: Colors.red.shade400, isActive: _liked, onTap: _toggleLike),
                      _ActionBtn(icon: Icons.bar_chart_rounded, count: _likes * 3 + _reposts * 5, activeColor: Colors.blue.shade400, onTap: () {}),
                      _ActionBtn(icon: Icons.share_outlined, count: -1, activeColor: Colors.blue.shade400, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini helpers ───────────────────────────────────────────────────────────────

class _VerifChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final Color color;
  const _VerifChip({required this.label, required this.icon, required this.done, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: 0.12) : AppColors.of(context).divider,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: done ? color.withValues(alpha: 0.5) : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(done ? Icons.check_circle_rounded : icon, size: 12,
              color: done ? color : AppColors.of(context).textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: done ? color : AppColors.of(context).textMuted, fontWeight: done ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

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
        child: Row(children: [
          Icon(icon, size: 18, color: isActive ? activeColor : AppColors.of(context).textMuted),
          if (count >= 0) ...[
            const SizedBox(width: 4),
            Text(_fmt(count), style: TextStyle(fontSize: 13, color: isActive ? activeColor : AppColors.of(context).textMuted, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
          ],
        ]),
      ),
    );
  }
}
