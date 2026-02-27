import 'package:flutter/material.dart';
import '../models/post_store.dart';

import '../theme/app_theme.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  final _store = PostStore();
  late AnimationController _animController;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _countAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _rewards = [
    {'name': 'RM10 Touch \'n Go eWallet', 'desc': 'Instant credit to your TnG eWallet', 'cost': 200, 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF1565C0)},
    {'name': '1-Month RapidKL Pass', 'desc': 'Unlimited public transport in KL', 'cost': 500, 'icon': Icons.directions_bus_rounded, 'color': Color(0xFF2E7D32)},
    {'name': '10% TNB Utility Rebate', 'desc': 'Applied to your next electricity bill', 'cost': 800, 'icon': Icons.bolt_rounded, 'color': Color(0xFFF57F17)},
    {'name': 'Flood Emergency Kit', 'desc': 'Torch, first aid, water purification tablets', 'cost': 1200, 'icon': Icons.medical_services_rounded, 'color': Color(0xFFC62828)},
    {'name': 'RM50 MyDebit Cash Rebate', 'desc': 'Government e-rebate for your bank', 'cost': 1500, 'icon': Icons.credit_card_rounded, 'color': Color(0xFF6A1B9A)},
    {'name': 'Flood Relief Tax Credit', 'desc': 'RM200 reduction on annual income tax', 'cost': 3000, 'icon': Icons.receipt_long_rounded, 'color': Color(0xFF00695C)},
  ];

  String get _rank => _store.getRank(_store.currentUser);

  Color get _rankColor {
    switch (_rank) {
      case 'Platinum': return const Color(0xFF78909C);
      case 'Gold':     return const Color(0xFFF9A825);
      case 'Silver':   return const Color(0xFF78909C);
      default:         return const Color(0xFF8D6E63); // Bronze
    }
  }

  IconData get _rankIcon {
    switch (_rank) {
      case 'Platinum': return Icons.diamond_rounded;
      case 'Gold':     return Icons.emoji_events_rounded;
      case 'Silver':   return Icons.workspace_premium_rounded;
      default:         return Icons.military_tech_rounded;
    }
  }

  int get _points => _store.getPoints(_store.currentUser);
  int get _threshold => _store.getRankThreshold(_store.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: AppColors.of(context).scaffoldBg,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.of(context).teal, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle),
                    child: Icon(Icons.emoji_events_rounded, color: AppColors.of(context).scaffoldBg, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Rewards Centre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary, letterSpacing: -0.5)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildHowToEarnCard(),
                  const SizedBox(height: 20),
                  _buildRewardsCatalog(),
                  const SizedBox(height: 20),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final lifetime = _store.userLifetimePoints[_store.currentUser] ?? 0;
    final progress = (_points > _threshold) ? 1.0 : (_points / _threshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF006D5B), AppColors.of(context).teal, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.of(context).teal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(_rankIcon, color: _rankColor, size: 16),
                    const SizedBox(width: 6),
                    Text(_rank, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _countAnim,
            builder: (_, __) {
              final displayedPoints = (_countAnim.value * _points).round();
              return Text('$displayedPoints', style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2));
            },
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('HydroCoins', style: TextStyle(color: AppColors.of(context).scaffoldBg, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress to next rank
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress to next rank', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  Text('$lifetime / $_threshold pts', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AnimatedBuilder(
                  animation: _countAnim,
                  builder: (_, __) => LinearProgressIndicator(
                    value: progress * _countAnim.value,
                    backgroundColor: AppColors.of(context).scaffoldBg.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.of(context).scaffoldBg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.of(context).shadow, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to Earn HydroCoins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary)),
          const SizedBox(height: 12),
          _earnRow(Icons.add_photo_alternate_rounded, Colors.blue, 'Submit a flood report', '+50 pts'),
          _earnRow(Icons.verified_user_rounded, Colors.green, 'Verify someone\'s report', '+10 pts'),
          _earnRow(Icons.where_to_vote_rounded, AppColors.of(context).teal, 'Your report gets verified', '+10 pts each'),
          _earnRow(Icons.star_rounded, Colors.orange, 'First report of the day', '+25 bonus pts'),
        ],
      ),
    );
  }

  Widget _earnRow(IconData icon, Color color, String label, String pts) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.of(context).textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(pts, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Redeem Rewards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary)),
        const SizedBox(height: 4),
        Text('Government & community incentives', style: TextStyle(fontSize: 14, color: AppColors.of(context).textMuted)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _rewards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _RewardCard(
              reward: _rewards[i],
              userPoints: _points,
              onRedeem: () {
                final success = _store.redeemPoints(_store.currentUser, _rewards[i]['cost'] as int, _rewards[i]['name'] as String);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? '🎉 Redeemed: ${_rewards[i]['name']}!' : '❌ Not enough HydroCoins.'),
                  backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final history = _store.getHistory(_store.currentUser);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Points History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.of(context).textPrimary)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Center(child: Text('No activity yet. Start reporting!', style: TextStyle(color: AppColors.of(context).textMuted))),
        ...history.map((tx) => _ActivityRow(transaction: tx)),
      ],
    );
  }
}

// ── Reward Card ───────────────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int userPoints;
  final VoidCallback onRedeem;
  const _RewardCard({required this.reward, required this.userPoints, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final cost = reward['cost'] as int;
    final canAfford = userPoints >= cost;
    final color = reward['color'] as Color;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.of(context).shadow, blurRadius: 8, offset: const Offset(0, 4))],
        border: canAfford ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(reward['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(reward['name'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.of(context).textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.toll_rounded, size: 14, color: canAfford ? AppColors.of(context).teal : Colors.grey),
              const SizedBox(width: 3),
              Text('$cost', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: canAfford ? AppColors.of(context).teal : Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canAfford ? onRedeem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? color : AppColors.of(context).divider,
                foregroundColor: canAfford ? Colors.white : AppColors.of(context).textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(canAfford ? 'Redeem' : 'Locked', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity Row ──────────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final PointTransaction transaction;
  const _ActivityRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.amount > 0;
    final color = isEarned ? Colors.green.shade600 : Colors.red.shade500;
    final diff = DateTime.now().difference(transaction.timestamp);
    final timeLabel = diff.inMinutes < 1 ? 'just now' : diff.inHours < 1 ? '${diff.inMinutes}m ago' : diff.inDays < 1 ? '${diff.inHours}h ago' : '${diff.inDays}d ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.of(context).shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(isEarned ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.reason, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.of(context).textPrimary)),
                Text(timeLabel, style: TextStyle(fontSize: 12, color: AppColors.of(context).textMuted)),
              ],
            ),
          ),
          Text('${isEarned ? '+' : ''}${transaction.amount}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
