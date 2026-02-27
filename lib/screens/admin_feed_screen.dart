import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../widgets/firestore_report_card.dart';
import '../theme/app_theme.dart';

/// The admin's version of the feed — live from Firestore with admin filter tabs.
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
        child: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService().getActiveReports(),
          builder: (context, snapshot) {
            final allDocs = snapshot.data?.docs ?? [];
            final pendingDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['status']?.toString().toLowerCase() ?? '') == 'pending';
            }).toList();
            final alertDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final s = data['severityScore']?.toString().toLowerCase() ?? '';
              return s == 'danger' || s == 'high';
            }).toList();

            return Column(
              children: [
                // ── Header ────────────────────────────────────
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
                              child: const Icon(Icons.admin_panel_settings_rounded,
                                  color: Color(0xFF1E3A3A), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Admin Feed',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.of(context).textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Spacer(),
                            if (pendingDocs.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${pendingDocs.length} Pending',
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
                        labelColor: AppColors.of(context).textPrimary,
                        unselectedLabelColor: AppColors.of(context).textMuted,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: [
                          Tab(text: 'All (${allDocs.length})'),
                          Tab(text: 'Pending (${pendingDocs.length})'),
                          const Tab(text: 'Alerts 🚨'),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Tab Content ───────────────────────────────
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator(
                          color: const Color(0xFF1E3A3A), strokeWidth: 2))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _AdminReportList(docs: allDocs),
                            _AdminReportList(docs: pendingDocs, emptyLabel: 'No pending reports'),
                            _AdminReportList(docs: alertDocs, emptyLabel: 'No active alerts'),
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

// ── Admin Report List ──────────────────────────────────────────────────────────
class _AdminReportList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final String emptyLabel;
  const _AdminReportList({required this.docs, this.emptyLabel = 'No reports'});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 52, color: AppColors.of(context).textMuted),
          const SizedBox(height: 12),
          Text(emptyLabel,
              style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ]),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return FirestoreReportCard(
              data: data,
              docId: docs[i].id,
              isAdmin: true,
            );
          },
        ),
      ),
    );
  }
}
