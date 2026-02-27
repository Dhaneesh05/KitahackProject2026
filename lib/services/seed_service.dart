import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Seeds realistic mock flood reports into Firestore for demo purposes.
/// Only runs if the reports collection has fewer than [minCount] documents.
class SeedService {
  static final _db = FirebaseFirestore.instance;

  static const _mockReports = [
    {
      'userId': 'demo_user_1',
      'imageUrl': 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400',
      'severityScore': 90,
      'debrisType': 'Flash Flood',
      'floodType': 'Flash Flood',
      'zone': 'Klang Valley',
      'location': 'Jalan Ampang, KL',
      'status': 'Pending',
      'description': 'Severe flash flooding on main arterial road. Water level above knee height.',
    },
    {
      'userId': 'demo_user_2',
      'imageUrl': 'https://images.unsplash.com/photo-1612095836874-5b1a1a67e5c2?w=400',
      'severityScore': 82,
      'debrisType': 'Debris Flow',
      'floodType': 'Urban Flood',
      'zone': 'Petaling Jaya',
      'location': 'SS2, Petaling Jaya',
      'status': 'Pending',
      'description': 'Heavy debris and sediment blocking storm drains causing overflow.',
    },
    {
      'userId': 'demo_user_3',
      'imageUrl': 'https://images.unsplash.com/photo-1601599561213-832382fd07ba?w=400',
      'severityScore': 78,
      'debrisType': 'Storm Surge',
      'floodType': 'Coastal Flood',
      'zone': 'Port Klang',
      'location': 'Port Klang, Selangor',
      'status': 'Pending',
      'description': 'Storm surge pushing water inland. Coastal settlements at risk.',
    },
    {
      'userId': 'demo_user_4',
      'imageUrl': 'https://images.unsplash.com/photo-1548684505-b3a4aa5d21e4?w=400',
      'severityScore': 85,
      'debrisType': 'Riverine Flood',
      'floodType': 'River Overflow',
      'zone': 'Shah Alam',
      'location': 'Bukit Cherakah, Shah Alam',
      'status': 'Pending',
      'description': 'Klang river overflowing its banks. Riverside households evacuated.',
    },
    {
      'userId': 'demo_user_5',
      'imageUrl': 'https://images.unsplash.com/photo-1598965402089-897ce52e8355?w=400',
      'severityScore': 60,
      'debrisType': 'Road Flooding',
      'floodType': 'Surface Water',
      'zone': 'Subang Jaya',
      'location': 'USJ 9, Subang Jaya',
      'status': 'Pending',
      'description': 'Significant ponding on low-lying roads, traffic severely disrupted.',
    },
    {
      'userId': 'demo_user_6',
      'imageUrl': 'https://images.unsplash.com/photo-1584677626646-7c8f83690304?w=400',
      'severityScore': 55,
      'debrisType': 'Drain Overflow',
      'floodType': 'Drain Overflow',
      'zone': 'Cheras',
      'location': 'Taman Mutiara, Cheras',
      'status': 'Pending',
      'description': 'Blocked storm drains causing overflow into residential area.',
    },
    {
      'userId': 'demo_user_7',
      'imageUrl': 'https://images.unsplash.com/photo-1527482797697-8795b05a13fe?w=400',
      'severityScore': 88,
      'debrisType': 'Infrastructure Damage',
      'floodType': 'Flash Flood',
      'zone': 'Bangsar',
      'location': 'Bangsar Baru, KL',
      'status': 'Pending',
      'description': 'Bridge approach flooded, infrastructure integrity at risk.',
    },
    {
      'userId': 'demo_user_8',
      'imageUrl': 'https://images.unsplash.com/photo-1580977251946-6b84f4c46e7e?w=400',
      'severityScore': 45,
      'debrisType': 'Minor Flooding',
      'floodType': 'Localized Flood',
      'zone': 'Mont Kiara',
      'location': 'Desa Sri Hartamas, KL',
      'status': 'Pending',
      'description': 'Localized minor flooding. Water draining slowly.',
    },
    {
      'userId': 'demo_user_9',
      'imageUrl': 'https://images.unsplash.com/photo-1571992124602-1e8fd29b9ad4?w=400',
      'severityScore': 92,
      'debrisType': 'Extreme Flash Flood',
      'floodType': 'Flash Flood',
      'zone': 'Jalan Duta',
      'location': 'Jalan Duta, KL',
      'status': 'Pending',
      'description': 'Extreme flash flood. Buildings inundated, emergency evacuation required.',
    },
    {
      'userId': 'demo_user_10',
      'imageUrl': 'https://images.unsplash.com/photo-1523568114750-b593de7602b8?w=400',
      'severityScore': 70,
      'debrisType': 'Sewage Overflow',
      'floodType': 'Urban Flood',
      'zone': 'Sentul',
      'location': 'Taman Sentul, KL',
      'status': 'Pending',
      'description': 'Combined sewage overflow creating health hazard in residential streets.',
    },
    {
      'userId': 'demo_user_11',
      'imageUrl': 'https://images.unsplash.com/photo-1501707259872-88f1a2bca40c?w=400',
      'severityScore': 80,
      'debrisType': 'Landslide Risk',
      'floodType': 'Slope Saturation',
      'zone': 'Bukit Antarabangsa',
      'location': 'Bukit Antarabangsa, Ampang',
      'status': 'Pending',
      'description': 'Saturated hill slopes showing signs of instability. Landslide risk elevated.',
    },
    {
      'userId': 'demo_user_12',
      'imageUrl': 'https://images.unsplash.com/photo-1553434212-b27b3f8d0b77?w=400',
      'severityScore': 50,
      'debrisType': 'Blocked Drain',
      'floodType': 'Surface Water',
      'zone': 'Kepong',
      'location': 'Kepong Baru, KL',
      'status': 'Pending',
      'description': 'Large debris blocking primary drain. Water level rising steadily.',
    },
  ];

  /// Seeds mock reports if fewer than [minCount] non-demo docs exist.
  /// Demo docs (userId starting with 'demo_user_') are placed 30+ days ago
  /// so that real user-submitted reports always appear first in the feed.
  static Future<void> seedIfEmpty({int minCount = 8}) async {
    try {
      // Count real (non-demo) reports
      final allSnap = await _db.collection('reports').limit(50).get();
      final realDocs = allSnap.docs.where((d) {
        final uid = (d.data())['userId']?.toString() ?? '';
        return !uid.startsWith('demo_user_');
      }).toList();

      // Remove stale demo docs that might have wrong timestamps
      final staleDemoDocs = allSnap.docs.where((d) {
        final uid = (d.data())['userId']?.toString() ?? '';
        return uid.startsWith('demo_user_');
      }).toList();

      if (staleDemoDocs.isNotEmpty) {
        final deleteBatch = _db.batch();
        for (final d in staleDemoDocs) { deleteBatch.delete(d.reference); }
        await deleteBatch.commit();
        debugPrint('SEED: Deleted ${staleDemoDocs.length} stale demo docs.');
      }

      // Reseed with timestamps 30-53 days ago (well behind any real reports)
      debugPrint('SEED: Seeding ${_mockReports.length} demo reports with past timestamps...');
      final seedBatch = _db.batch();
      final now = DateTime.now();
      for (int i = 0; i < _mockReports.length; i++) {
        final ref = _db.collection('reports').doc();
        final data = Map<String, dynamic>.from(_mockReports[i]);
        // Place 30 days ago, staggered by 2 hours each
        data['timestamp'] = Timestamp.fromDate(
          now.subtract(Duration(days: 30, hours: i * 2)),
        );
        seedBatch.set(ref, data);
      }
      await seedBatch.commit();
      debugPrint('SEED: Done. Real reports: ${realDocs.length}. Demo reports: ${_mockReports.length}.');
    } catch (e) {
      debugPrint('SEED ERROR: $e');
    }
  }
}
