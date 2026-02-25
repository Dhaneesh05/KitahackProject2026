import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/ai_vision_service.dart';
import 'glass_card.dart';

class ReportDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportDetailsDialog({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = reportData['imageUrl'] ?? '';
    final String material = reportData['debrisType'] ?? 'Unknown';
    
    // Severity mapping
    final dynamic rawScore = reportData['severityScore'];
    int score = 0;
    if (rawScore is int) score = rawScore;
    else if (rawScore is String) {
      if (rawScore.toLowerCase() == 'high') score = 85;
      else if (rawScore.toLowerCase() == 'medium') score = 65;
      else if (rawScore.toLowerCase() == 'low') score = 30;
      else score = int.tryParse(rawScore) ?? 0;
    } 
    else if (rawScore is double) score = rawScore.toInt();

    Color severityColor = Colors.green;
    String severityText = 'Minor';
    if (score >= 80) {
      severityColor = Colors.redAccent;
      severityText = 'Critical';
    } else if (score >= 60) {
      severityColor = Colors.orange;
      severityText = 'High';
    }

    // Time parsing
    String timeAgo = 'Just now';
    final timestamp = reportData['timestamp'];
    if (timestamp is Timestamp) {
      final diff = DateTime.now().difference(timestamp.toDate());
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
      } else if (diff.inMinutes > 0) {
        timeAgo = '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Header
                  Stack(
                    children: [
                      if (imageUrl.isNotEmpty)
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imageUrl.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(imageUrl.split(',').last),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.black12,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                                        SizedBox(height: 8),
                                        Text('Image Decoding Failed', style: TextStyle(color: Colors.white54)),
                                      ],
                                    ),
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.black12,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.of(context).teal,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => _SummaryFallback(material: material),
                                ),
                        )
                      else
                        _SummaryFallback(material: material),
                      
                    ],
                  ),
                  
                  // Details Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: severityColor.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                severityText.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: severityColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              timeAgo,
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'AI Analysis Report',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Glass Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 16,
                                color: Colors.white.withValues(alpha: 0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Probable Cause', style: TextStyle(fontSize: 11, color: AppColors.of(context).textSecondary)),
                                    const SizedBox(height: 6),
                                    Text(
                                      material,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.of(context).textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 16,
                                color: Colors.white.withValues(alpha: 0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('AI Severity', style: TextStyle(fontSize: 11, color: AppColors.of(context).textSecondary)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$score / 100',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: severityColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white30, width: 1),
                              ),
                            ),
                            child: const Text('Close Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryFallback extends StatefulWidget {
  final String material;
  const _SummaryFallback({required this.material});

  @override
  State<_SummaryFallback> createState() => _SummaryFallbackState();
}

class _SummaryFallbackState extends State<_SummaryFallback> {
  late Future<String> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = AiVisionService().generateReportSummary(widget.material);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
      decoration: const BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: FutureBuilder<String>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutSine,
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.of(context).teal),
                        const SizedBox(height: 16),
                        const Text('Generating Engineering Insights...', style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 0.5)),
                      ],
                    ),
                  );
                }
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.of(context).tealLight, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GEMINI AI INSIGHT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.of(context).tealLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  snapshot.data ?? 'Summary unavailable.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}

