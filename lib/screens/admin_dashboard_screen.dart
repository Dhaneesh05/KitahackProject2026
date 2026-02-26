import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../widgets/report_details_dialog.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Command Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Darker Command Center Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: [
                  const Color(0xFF1E3A3A), // Deep teal
                  const Color(0xFF0F172A), // Slate dark
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Alert Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('system_alerts').doc('current_forecast').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              height: 80,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final bool isCritical = data['is_critical'] ?? false;
                      final String expectedRain = data['expected_rain'] ?? '';
                      final String date = data['date'] ?? '';

                      if (isCritical) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PREDICTIVE ALERT',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'High Flood Risk. $expectedRain of rain expected $date. Route crews to high-risk zones immediately.',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SYSTEM STATUS',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Forecast: Normal conditions expected.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                
                // Map Placeholder
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 0.2,
                                child: Icon(Icons.map_outlined, size: 120, color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Live Threat Map Initializing...',
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Active Reports Section
                Expanded(
                  flex: 4,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getActiveReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: CircularProgressIndicator(color: AppColors.of(context).teal),
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading reports.', style: TextStyle(color: Colors.redAccent)),
                        );
                      }

                      final docs = snapshot.hasData ? snapshot.data!.docs : [];

                      return Column(
                        children: [
                          // Active Reports Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                const Text(
                                  'ACTIVE AI REPORTS',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const Spacer(),
                                if (docs.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('${docs.length} ACTV', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Bottom Reports List
                          Expanded(
                            child: docs.isEmpty
                                ? const Center(child: Text('No active reports', style: TextStyle(color: Colors.white54, fontSize: 14)))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      
                                      final String zone = data['zone'] ?? 'Reported Location';
                                      final String material = data['debrisType'] ?? 'Unknown';
                                      
                                      final dynamic rawScore = data['severityScore'];
                                      int score = 0;
                                      if (rawScore is int) {
                                        score = rawScore;
                                      } else if (rawScore is String) {
                                        if (rawScore.toLowerCase() == 'high') {
                                          score = 85;
                                        } else if (rawScore.toLowerCase() == 'medium') {
                                          score = 65;
                                        } else if (rawScore.toLowerCase() == 'low') {
                                          score = 30;
                                        } else {
                                          score = int.tryParse(rawScore) ?? 0;
                                        }
                                      } else if (rawScore is double) {
                                        score = rawScore.toInt();
                                      }

                                      String severityText = 'Minor';
                                      Color severityColor = Colors.green;
                                      if (score >= 80) {
                                        severityText = 'Critical: $score%';
                                        severityColor = Colors.redAccent;
                                      } else if (score >= 60) {
                                        severityText = 'High: $score%';
                                        severityColor = Colors.orange;
                                      } else {
                                        severityText = 'Minor: $score%';
                                        severityColor = Colors.green;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => ReportDetailsDialog(reportData: data),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Warning Icon
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: severityColor.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(14),
                                                    ),
                                                    child: Icon(Icons.warning_amber_rounded, color: severityColor, size: 24),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          zone,
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              severityText,
                                                              style: TextStyle(color: severityColor, fontWeight: FontWeight.w800, fontSize: 12),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            const Text('•', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              material,
                                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Dispatch Button
                                                  ElevatedButton(
                                                    onPressed: () {},
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.of(context).teal,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text('DISPATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  ),
                          ),
                        ],
                      );
                    }
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