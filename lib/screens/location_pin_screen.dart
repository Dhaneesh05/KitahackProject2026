import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Resident confirmation screen: shows a full-screen Google Map centered on
/// the device's GPS location. The pin stays fixed at the center while the user
/// drags the map to select the exact flood/drain location.
/// Pops with a [LatLng?] result when the user taps "Confirm Location".
class LocationPinScreen extends StatefulWidget {
  /// The AI analysis future — passed through so we can hand it off to the
  /// result sheet after the user confirms the location.
  final Future<Map<String, dynamic>>? analysisFuture;

  /// The captured image — passed through to the result sheet.
  final XFile? imageFile;

  const LocationPinScreen({
    super.key,
    this.analysisFuture,
    this.imageFile,
  });

  @override
  State<LocationPinScreen> createState() => _LocationPinScreenState();
}

class _LocationPinScreenState extends State<LocationPinScreen> {
  GoogleMapController? _mapController;

  // Current center of the camera (where the pin is pointing)
  LatLng _pinPosition = const LatLng(3.1390, 101.6869); // KL default
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 8));
      if (mounted) {
        setState(() {
          _pinPosition = LatLng(pos.latitude, pos.longitude);
          _isLoadingLocation = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_pinPosition, 17),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }


  void _onCameraMove(CameraPosition pos) {
    setState(() => _pinPosition = pos.target);
  }


  void _confirm() {
    Navigator.of(context).pop(_pinPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Full-screen Google Map ──────────────────────────
          GoogleMap(
            onMapCreated: (ctrl) => _mapController = ctrl,
            initialCameraPosition: CameraPosition(
              target: _pinPosition,
              zoom: 16,
            ),
            onCameraMove: _onCameraMove,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
          ),

          // ── Fixed center pin ─────────────────────────────────
          // The pin is permanently centered — the map moves under it.
          IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3FC9A8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3FC9A8).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(2, 12),
                  painter: _StemPainter(),
                ),
              ],
            ),
          ),

          // ── Top SafeArea back button ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(null),
                            child: Icon(Icons.arrow_back_rounded,
                                color: AppColors.of(context).textPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pin the exact location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.of(context).textPrimary,
                                  ),
                                ),
                                Text(
                                  'Drag the map to move the pin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.of(context).textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingLocation)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.of(context).teal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom coordinate + confirm panel ────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Coordinate display
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).tealLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.location_on_rounded,
                                    color: AppColors.of(context).teal, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.of(context).textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_pinPosition.latitude.toStringAsFixed(5)}, '
                                      '${_pinPosition.longitude.toStringAsFixed(5)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.of(context).textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Confirm button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.of(context).teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Confirm Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small stem line below pin dot ─────────────────────────────────────────────
class _StemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = const Color(0xFF3FC9A8)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
