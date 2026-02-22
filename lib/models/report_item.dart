import 'dart:typed_data';

class ReportItem {
  final Uint8List imageBytes;
  final String severity;
  final String debrisType;
  final DateTime timestamp;

  ReportItem({
    required this.imageBytes,
    required this.severity,
    required this.debrisType,
    required this.timestamp,
  });
}
