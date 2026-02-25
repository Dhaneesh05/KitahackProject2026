import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Submits a new drain report to the "reports" collection
  Future<void> submitReport(Map<String, dynamic> reportData) async {
    try {
      // Ensure specific fields exist
      if (!reportData.containsKey('userId') ||
          !reportData.containsKey('imageUrl') ||
          !reportData.containsKey('severityScore') ||
          !reportData.containsKey('debrisType')) {
        throw Exception('Incomplete report data provided.');
      }

      // Append backend-managed fields
      reportData['status'] = 'Pending';
      reportData['timestamp'] = FieldValue.serverTimestamp();

      // Dummy location since native geolocation is not fully implemented yet
      reportData['location'] = const GeoPoint(3.1390, 101.6869); // Default KL

      debugPrint('FIREBASE: Attempting to add report data: $reportData');
      final docRef = await _firestore.collection('reports').add(reportData);
      debugPrint('FIREBASE: Successfully added report with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('FIREBASE ERROR: Database Error during submit: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getActiveReports() {
    return _firestore
        .collection('reports')
        // Dropped the `.where('status', ...)` clause because compound queries
        // require a pre-built Firestore Composite Index which might be missing.
        // Once the index is built in the Firebase Console, this can be re-added.
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
