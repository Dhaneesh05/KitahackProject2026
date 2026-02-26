import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class UploadMockDataScreen extends StatefulWidget {
  const UploadMockDataScreen({super.key});

  @override
  State<UploadMockDataScreen> createState() => _UploadMockDataScreenState();
}

class _UploadMockDataScreenState extends State<UploadMockDataScreen> {
  bool _isUploading = false;
  String _status = "Ready to upload";

  Future<void> _uploadData() async {
    setState(() {
      _isUploading = true;
      _status = "Loading CSV...";
    });

    try {
      final String csvString = await rootBundle.loadString('assets/data/posts.csv');
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.length <= 1) {
        setState(() => _status = "CSV is empty.");
        return;
      }

      final firestore = FirebaseFirestore.instance;
      int count = 0;

      // Skip header row at index 0
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length < 14) continue;

        setState(() => _status = "Uploading post $i of ${rows.length - 1}...");

        // Determine ai/admin verified booleans
        bool adminVerified = row.length > 11 ? row[11].toString().toLowerCase() == 'true' : false;
        bool aiVerified = row.length > 12 ? row[12].toString().toLowerCase() == 'true' : false;
        
        // Build mock verifiedByUsers list based on count
        int verifiedCount = int.tryParse(row[10].toString()) ?? 0;
        List<String> verifiedUsers = [];
        for (int v = 0; v < verifiedCount; v++) {
          verifiedUsers.add('mock_user_$v');
        }

        await firestore.collection('reports').add({
          'authorName': row[1].toString(),
          'authorHandle': row[2].toString(),
          'description': row[3].toString(),
          'content': row[3].toString(),
          'imageUrl': row[4].toString(), // We keep the default unsplash URLs
          'timestamp': FieldValue.serverTimestamp(), // Use current time so they show up
          'likes': int.tryParse(row[6].toString()) ?? 0,
          'comments': int.tryParse(row[7].toString()) ?? 0,
          'reposts': int.tryParse(row[8].toString()) ?? 0,
          'severityScore': row[9].toString(),
          'floodSeverity': row[9].toString(),
          'aiSeverity': row[9].toString(), // Match real uploads
          'debrisType': 'Unknown', // Match real uploads
          'verifiedByUsers': verifiedUsers,
          'adminVerified': adminVerified,
          'aiVerified': aiVerified,
          'location': const GeoPoint(3.1390, 101.6869), // Added default mock location (KL)
          'status': 'pending', // consistently lowercase
          'isDeleted': false,
        });

        count++;
      }

      setState(() => _status = "Successfully uploaded $count posts! \nYou can now return to the Feed.");
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Upload Mock Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                "Upload Legacy CSV Posts to Firebase",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "This will read assets/data/posts.csv and push all 8 older posts into your live Firestore database so they appear in the new Feed.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (_isUploading) const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadData,
                icon: const Icon(Icons.upload),
                label: const Text('Start Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
