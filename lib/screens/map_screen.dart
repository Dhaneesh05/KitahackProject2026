import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/report_map_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _center = LatLng(3.1390, 101.6869);

  final Map<String, BitmapDescriptor> _icons = {};
  bool _iconsReady = false;

  @override
  void initState() {
    super.initState();
    _buildIcons();
  }

  Future<void> _buildIcons() async {
    _icons['danger'] = await _circleIcon(Colors.redAccent, 44);
    _icons['high'] = await _circleIcon(Colors.red, 44);
    _icons['medium'] = await _circleIcon(Colors.orange, 44);
    _icons['low'] = await _circleIcon(Colors.blue.shade400, 44);
    _icons['clear'] = await _circleIcon(const Color(0xFF3FC9A8), 44);
    _icons['default'] = await _circleIcon(Colors.grey, 44);
    if (mounted) setState(() => _iconsReady = true);
  }

  Future<BitmapDescriptor> _circleIcon(Color color, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final r = size / 2;

    // Halo
    canvas.drawCircle(Offset(r, r), r, Paint()..color = color.withValues(alpha: 0.3));
    // Body
    canvas.drawCircle(Offset(r, r), r * 0.6, Paint()..color = color);
    // White center
    canvas.drawCircle(Offset(r, r), r * 0.3, Paint()..color = Colors.white);

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  BitmapDescriptor _iconForSeverity(String severity) {
    final key = severity.toLowerCase();
    return _icons[key] ?? _icons['default']!;
  }

  Set<Marker> _buildMarkers(List<QueryDocumentSnapshot> docs) {
    final markers = <Marker>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'];
      if (location == null || location is! GeoPoint) continue;

      final severity = data['severityScore']?.toString() ?? 'default';
      final markerId = MarkerId(doc.id);

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(location.latitude, location.longitude),
          icon: _iconsReady ? _iconForSeverity(severity) : BitmapDescriptor.defaultMarker,
          onTap: () => ReportMapBottomSheet.show(context, data),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getActiveReports(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final markers = _iconsReady ? _buildMarkers(docs) : <Marker>{};

          return Stack(
            children: [
              // ── Google Map ────────────────────────────────────
              GoogleMap(
                onMapCreated: (_) {},
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: 13.5,
                ),
                markers: markers,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),

              // ── Top glass header ─────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Icon(Icons.layers_outlined, color: AppColors.of(context).teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Live Flood Reports',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: AppColors.of(context).textPrimary,
                              ),
                            ),
                          ),
                          // Live count badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).tealLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.of(context).teal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  snapshot.connectionState == ConnectionState.waiting
                                      ? 'LIVE'
                                      : '${docs.length} LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.of(context).teal,
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

              // ── Bottom legend ─────────────────────────────────
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  borderRadius: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LegendDot(color: AppColors.of(context).teal, label: 'Clear'),
                      _LegendDot(color: Colors.blue.shade400, label: 'Low'),
                      _LegendDot(color: Colors.orange, label: 'Medium'),
                      _LegendDot(color: Colors.redAccent, label: 'Danger'),
                      _LegendDot(color: AppColors.of(context).textMuted, label: 'Unknown'),
                    ],
                  ),
                ),
              ),

              // ── Loading overlay (icon building) ───────────────
              if (!_iconsReady)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.of(context).teal,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.of(context).textSecondary)),
      ],
    );
  }
}
