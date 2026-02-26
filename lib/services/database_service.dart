import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ─── Feed Posts Stream ────────────────────────────────────────────────────

  /// Returns a real-time stream of all non-deleted feed posts from Firestore,
  /// ordered by timestamp descending (newest first).
  Stream<List<Post>> getFeedPostsStream() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Post.fromFirestore(doc);
                } catch (e) {
                  debugPrint('Error parsing post ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Post>()
              .where((post) => !post.isDeleted) // Filter client-side to avoid composite index requirement
              .toList();
        });
  }

  // ─── Submit a New Report ──────────────────────────────────────────────────

  /// Submits a new post/report to Firestore.
  /// Returns the newly created Firestore document ID.
  Future<String> submitReport(Map<String, dynamic> reportData) async {
    try {
      // Validate required fields
      if (!reportData.containsKey('imageUrl') ||
          !reportData.containsKey('severityScore')) {
        throw Exception('Incomplete report data provided.');
      }

      // Set server-managed defaults
      reportData['isDeleted'] = reportData['isDeleted'] ?? false;
      reportData['adminVerified'] = reportData['adminVerified'] ?? false;
      reportData['aiVerified'] = reportData['aiVerified'] ?? false;
      reportData['likes'] = reportData['likes'] ?? 0;
      reportData['comments'] = reportData['comments'] ?? 0;
      reportData['reposts'] = reportData['reposts'] ?? 0;
      reportData['status'] = reportData['status'] ?? 'pending';
      reportData['verifiedByUsers'] = reportData['verifiedByUsers'] ?? [];
      reportData['timestamp'] = FieldValue.serverTimestamp();

      // Build GeoPoint from latitude/longitude if provided
      final double? lat = reportData.remove('latitude');
      final double? lng = reportData.remove('longitude');
      if (lat != null && lng != null) {
        reportData['location'] = GeoPoint(lat, lng);
      }

      final docRef = await _firestore.collection('reports').add(reportData);
      return docRef.id;
    } catch (e) {
      debugPrint('Database Error: $e');
      rethrow;
    }
  }

  // ─── Admin Operations ─────────────────────────────────────────────────────

  /// Updates a specific field on a post document.
  Future<void> updatePost(String docId, Map<String, dynamic> updates) async {
    await _firestore.collection('reports').doc(docId).update(updates);
  }

  /// Soft-deletes a post by setting isDeleted=true.
  Future<void> deletePost(String docId) async {
    await _firestore.collection('reports').doc(docId).update({'isDeleted': true});
  }
}
