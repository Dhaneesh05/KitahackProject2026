import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_store.dart';
import '../models/admin_store.dart';
import '../theme/app_theme.dart';

/// A post card specifically for the Admin feed, with inline admin actions.
class AdminPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onDeleted;
  final VoidCallback? onStatusChanged;
  const AdminPostCard({super.key, required this.post, this.onDeleted, this.onStatusChanged});

  @override
  State<AdminPostCard> createState() => _AdminPostCardState();
}

class _AdminPostCardState extends State<AdminPostCard> {
  final _store = PostStore();
  final _admin = AdminStore();

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger': return Colors.red.shade500;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue.shade400;
      case 'clear': return AppColors.teal;
      default: return AppColors.textMuted;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
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

  // ─── Admin Actions ────────────────────────────────────────────────────────

  void _verifyPost() {
    setState(() => _admin.verifyPost(widget.post));
    widget.onStatusChanged?.call();
    _showSnack('Post verified ✅');
  }

  void _sendDispatch() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text('Send Dispatch', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Internal notes (visible to admins only):',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Send 2 boats to north side...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.teal, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _admin.sendDispatch(widget.post, controller.text.trim()));
                widget.onStatusChanged?.call();
                Navigator.pop(ctx);
                _showSnack('Dispatch sent 🚒');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send Dispatch', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _overrideSeverity() {
    final severities = ['Clear', 'Low', 'Medium', 'Danger'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                const Text('Override Severity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Current: ${widget.post.effectiveSeverity}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (widget.post.originalSeverity != null)
              Text('Original (user-reported): ${widget.post.originalSeverity}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),
            ...severities.map((s) {
              final isActive = widget.post.effectiveSeverity.toLowerCase() == s.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: isActive ? null : () {
                    setState(() => _admin.overrideSeverity(widget.post, s));
                    widget.onStatusChanged?.call();
                    Navigator.pop(ctx);
                    _showSnack('Severity overridden to $s ⚠️');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive ? _severityColor(s).withValues(alpha: 0.12) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? _severityColor(s) : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(_severityIcon(s), color: _severityColor(s), size: 20),
                        const SizedBox(width: 12),
                        Text(s, style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15,
                          color: isActive ? _severityColor(s) : Colors.grey.shade800,
                        )),
                        if (isActive) ...[
                          const Spacer(),
                          Icon(Icons.check_circle_rounded, color: _severityColor(s), size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _changeStatus() {
    final statuses = [
      PostStatus.verified,
      PostStatus.beingResolved,
      PostStatus.weatherHindrance,
      PostStatus.resolved,
      PostStatus.notFlooded,
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Current: ${widget.post.status.adminLabel}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              final isActive = widget.post.status == s;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: isActive ? null : () {
                    setState(() => _admin.updateStatus(widget.post, s));
                    widget.onStatusChanged?.call();
                    Navigator.pop(ctx);
                    _showSnack('Status: ${s.adminLabel}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive ? _statusColor(s).withValues(alpha: 0.12) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? _statusColor(s) : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(s), color: _statusColor(s), size: 20),
                        const SizedBox(width: 12),
                        Text(s.adminLabel, style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15,
                          color: isActive ? _statusColor(s) : Colors.grey.shade800,
                        )),
                        if (isActive) ...[
                          const Spacer(),
                          Icon(Icons.check_circle_rounded, color: _statusColor(s), size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _viewDispatchNotes() {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Text('Dispatch Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('ADMIN ONLY', style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800, color: Colors.orange.shade700,
                      letterSpacing: 1,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.post.dispatchNotes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('No dispatch notes yet.',
                        style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.post.dispatchNotes.length,
                    itemBuilder: (_, i) {
                      final note = widget.post.dispatchNotes[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(note.adminName, style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12, color: Colors.orange.shade700,
                                )),
                                const Spacer(),
                                Text(_formatTime(note.timestamp), style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500,
                                )),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(note.message, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (noteController.text.trim().isNotEmpty) {
                        setState(() => _admin.addDispatchNote(widget.post, noteController.text.trim()));
                        setSheetState(() {}); // rebuild bottom sheet
                        noteController.clear();
                      }
                    },
                    icon: Icon(Icons.send_rounded, color: Colors.orange),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Delete Post', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('This will permanently remove this post from the feed. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              _admin.deletePost(widget.post, _store.posts);
              Navigator.pop(ctx);
              widget.onDeleted?.call();
              _showSnack('Post deleted 🗑️');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _banUser() {
    if (_admin.bannedHandles.contains(widget.post.authorHandle)) {
      _showSnack('User already banned');
      return;
    }
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.person_off_rounded, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            const Text('Ban User', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ban ${widget.post.authorName} (${widget.post.authorHandle})?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for ban...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _admin.banUser(
                  widget.post.authorName,
                  widget.post.authorHandle,
                  controller.text.trim(),
                ));
                Navigator.pop(ctx);
                _showSnack('${widget.post.authorName} banned 🚫');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ban User', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFF1A3636),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final severity = post.effectiveSeverity;
    final isBanned = _admin.bannedHandles.contains(post.authorHandle);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
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
                  Text(post.status.adminLabel, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: _statusColor(post.status),
                  )),
                  if (post.currentSeverity != null && post.originalSeverity != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Severity overridden',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── Main content ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
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
                          : Text(_initials, style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    if (isBanned)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 8),
                        ),
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
                                  child: Text(post.authorName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 15,
                                      color: isBanned ? Colors.red.shade300 : const Color(0xFF0F1419),
                                      decoration: isBanned ? TextDecoration.lineThrough : null,
                                    )),
                                ),
                                if (post.fullyVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded, size: 16, color: Colors.blue.shade600),
                                ],
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text('${post.authorHandle} · ${post.timestamp}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Content
                      Text(post.content, style: const TextStyle(
                        fontSize: 15, color: Color(0xFF0F1419), height: 1.4)),
                      const SizedBox(height: 10),
                      // Image + severity badge
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.network(
                              post.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity, height: 200,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200, color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48)),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(height: 200, color: Colors.grey.shade100,
                                  child: Center(child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.teal)));
                              },
                            ),
                            Positioned(
                              top: 10, left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _severityColor(severity).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(
                                    color: _severityColor(severity).withValues(alpha: 0.4),
                                    blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_severityIcon(severity), color: Colors.white, size: 13),
                                    const SizedBox(width: 4),
                                    Text(severity.toUpperCase(), style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w800,
                                      fontSize: 11, letterSpacing: 0.8)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Admin action bar ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                // Row 1: Primary actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AdminActionBtn(
                      icon: Icons.verified_outlined,
                      label: 'Verify',
                      color: Colors.blue,
                      isActive: post.adminVerified,
                      onTap: post.adminVerified ? null : _verifyPost,
                    ),
                    _AdminActionBtn(
                      icon: Icons.local_shipping_outlined,
                      label: 'Dispatch',
                      color: Colors.orange,
                      onTap: _sendDispatch,
                    ),
                    _AdminActionBtn(
                      icon: Icons.sync_rounded,
                      label: 'Status',
                      color: AppColors.teal,
                      onTap: _changeStatus,
                    ),
                    _AdminActionBtn(
                      icon: Icons.warning_amber_rounded,
                      label: 'Severity',
                      color: Colors.red,
                      onTap: _overrideSeverity,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Row 2: Secondary actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AdminActionBtn(
                      icon: Icons.message_outlined,
                      label: 'Notes',
                      color: Colors.deepOrange,
                      badge: post.dispatchNotes.isNotEmpty ? post.dispatchNotes.length.toString() : null,
                      onTap: _viewDispatchNotes,
                    ),
                    _AdminActionBtn(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      color: Colors.red.shade700,
                      onTap: _deletePost,
                    ),
                    _AdminActionBtn(
                      icon: Icons.person_off_outlined,
                      label: isBanned ? 'Banned' : 'Ban',
                      color: Colors.red.shade700,
                      isActive: isBanned,
                      onTap: isBanned ? null : _banUser,
                    ),
                    const SizedBox(width: 60), // spacer
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;
  final String? badge;

  const _AdminActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null && !isActive ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: isActive ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5) : null,
                    ),
                    child: Icon(
                      isActive ? Icons.check_circle_rounded : icon,
                      size: 18,
                      color: isActive ? color : color.withValues(alpha: 0.8),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Text(badge!, style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey.shade600,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
