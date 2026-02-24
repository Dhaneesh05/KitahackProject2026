import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center map on Kuala Lumpur as an example
  static const LatLng _center = LatLng(3.1390, 101.6869);
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  Future<void> _initMarkers() async {
    // On the web, defaultMarkerWithHue often defaults to red. 
    // We create custom circular bitmaps programmatically to ensure correct colors.
    final azureIcon = await _getCircleBitmap(Colors.blue, 40);
    final orangeIcon = await _getCircleBitmap(Colors.orange, 40);
    final redIcon = await _getCircleBitmap(Colors.red.shade400, 40);

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('sensor_1'),
          position: const LatLng(3.1415, 101.6865),
          icon: azureIcon,
          infoWindow: const InfoWindow(title: 'Sensor #1042', snippet: 'Status: Clear'),
        ),
        Marker(
          markerId: const MarkerId('sensor_2'),
          position: const LatLng(3.1350, 101.6900),
          icon: orangeIcon,
          infoWindow: const InfoWindow(title: 'Sensor #2031', snippet: 'Status: Warning (85% capacity)'),
        ),
        Marker(
          markerId: const MarkerId('sensor_3'),
          position: const LatLng(3.1450, 101.6800),
          icon: redIcon,
          infoWindow: const InfoWindow(title: 'Sensor #4055', snippet: 'Status: Flood Risk (102% capacity)'),
        ),
      };
    });
  }

  Future<BitmapDescriptor> _getCircleBitmap(Color color, double size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final double radius = size / 2;

    // Draw an inner circle and an outer semi-transparent halo
    canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(Offset(radius, radius), radius * 0.6, paint);
    canvas.drawCircle(Offset(radius, radius), radius * 0.4, Paint()..color = Colors.white);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          // Google Map implementation
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 13.5,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top glass header
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
                      Icon(Icons.layers_outlined, color: AppColors.teal),
                      const SizedBox(width: 12),
                      Text(
                        'Flood Monitoring Map',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tealLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom glass legend
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendDot(color: AppColors.teal, label: 'Clear'),
                  _LegendDot(color: Colors.orange, label: 'Warning'),
                  _LegendDot(color: Colors.red.shade400, label: 'Flood Risk'),
                  _LegendDot(color: AppColors.textMuted, label: 'Offline'),
                ],
              ),
            ),
          ),
        ],
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
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
