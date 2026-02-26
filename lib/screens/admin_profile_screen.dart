import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/admin_store.dart';
import '../theme/app_theme.dart';

/// The admin's private profile screen with action history & metrics.
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _admin = AdminStore();

  final List<_HistoryTab> _tabs = [
    _HistoryTab('All', null, Icons.history_rounded),
    _HistoryTab('Verified', AdminActionType.verifiedPost, Icons.verified_rounded),
    _HistoryTab('Dispatched', AdminActionType.dispatchSent, Icons.local_shipping_rounded),
    _HistoryTab('Resolved', AdminActionType.resolvedPost, Icons.check_circle_rounded),
    _HistoryTab('Weather', AdminActionType.weatherHindrance, Icons.thunderstorm_rounded),
    _HistoryTab('Deleted', AdminActionType.deletedPost, Icons.delete_rounded),
    _HistoryTab('Banned', AdminActionType.bannedUser, Icons.person_off_rounded),
    _HistoryTab('Severity', AdminActionType.severityOverride, Icons.warning_amber_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AdminAction> _getFilteredHistory(_HistoryTab tab) {
    if (tab.type == null) return _admin.actionHistory;
    return _admin.getHistory(tab.type!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.8),
                radius: 1.5,
                colors: [
                  const Color(0xFF1E3A3A),
                  const Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Profile header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFF00897B), const Color(0xFF004D40)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00897B).withValues(alpha: 0.4),
                                  blurRadius: 16, offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_admin.adminName, style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                Text(_admin.adminHandle, style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.4)),
                            ),
                            child: Text('ADMIN', style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w800,
                              color: const Color(0xFF00897B), letterSpacing: 1.5,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Metric Cards ──────────────────────────────────────
                      Row(
                        children: [
                          _MetricCard(label: 'Actions', value: '${_admin.totalActions}', icon: Icons.bolt_rounded, color: Colors.amber),
                          const SizedBox(width: 10),
                          _MetricCard(label: 'Dispatches', value: '${_admin.activeDispatches}', icon: Icons.local_shipping_rounded, color: Colors.orange),
                          const SizedBox(width: 10),
                          _MetricCard(label: 'Resolved', value: '${_admin.totalResolved}', icon: Icons.check_circle_rounded, color: Colors.green),
                          const SizedBox(width: 10),
                          _MetricCard(label: 'Banned', value: '${_admin.totalBanned}', icon: Icons.person_off_rounded, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── History tabs ─────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: const Color(0xFF00897B),
                    indicatorWeight: 2.5,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    tabAlignment: TabAlignment.start,
                    tabs: _tabs.map((t) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 14),
                          const SizedBox(width: 6),
                          Text(t.label),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                // ── History list ─────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      return _HistoryList(
                        actions: _getFilteredHistory(tab),
                        emptyLabel: tab.label == 'All' ? 'No actions yet' : 'No ${tab.label.toLowerCase()} history',
                      );
                    }).toList(),
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

class _HistoryTab {
  final String label;
  final AdminActionType? type;
  final IconData icon;
  const _HistoryTab(this.label, this.type, this.icon);
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<AdminAction> actions;
  final String emptyLabel;
  const _HistoryList({required this.actions, required this.emptyLabel});

  Color _actionColor(AdminActionType type) {
    switch (type) {
      case AdminActionType.verifiedPost: return Colors.blue;
      case AdminActionType.dispatchSent: return Colors.orange;
      case AdminActionType.statusChanged: return AppColors.teal;
      case AdminActionType.severityOverride: return Colors.red;
      case AdminActionType.deletedPost: return Colors.red.shade700;
      case AdminActionType.bannedUser: return Colors.red.shade800;
      case AdminActionType.resolvedPost: return Colors.green;
      case AdminActionType.weatherHindrance: return Colors.deepPurple;
      case AdminActionType.markedNotFlooded: return Colors.grey;
    }
  }

  IconData _actionIcon(AdminActionType type) {
    switch (type) {
      case AdminActionType.verifiedPost: return Icons.verified_rounded;
      case AdminActionType.dispatchSent: return Icons.local_shipping_rounded;
      case AdminActionType.statusChanged: return Icons.sync_rounded;
      case AdminActionType.severityOverride: return Icons.warning_amber_rounded;
      case AdminActionType.deletedPost: return Icons.delete_rounded;
      case AdminActionType.bannedUser: return Icons.person_off_rounded;
      case AdminActionType.resolvedPost: return Icons.check_circle_rounded;
      case AdminActionType.weatherHindrance: return Icons.thunderstorm_rounded;
      case AdminActionType.markedNotFlooded: return Icons.cancel_rounded;
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(emptyLabel, style: TextStyle(
            color: Colors.white38, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Actions will appear here as you manage posts.', style: TextStyle(
            color: Colors.white24, fontSize: 12)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final action = actions[i];
        final color = _actionColor(action.type);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_actionIcon(action.type), color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(action.type.label, style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                              Text(_timeAgo(action.timestamp), style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                            ],
                          ),
                          if (action.details != null) ...[
                            const SizedBox(height: 3),
                            Text(action.details!, style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                          if (action.targetUsername != null) ...[
                            const SizedBox(height: 3),
                            Text('User: ${action.targetUsername}', style: TextStyle(
                              color: color.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
