import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  static const String _mapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#9e9e9e"}]},
    {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#bdbdbd"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#181818"}]},
    {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
    {"featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [{"color": "#1b1b1b"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#373737"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [{"color": "#4e4e4e"}]},
    {"featureType": "road.local", "elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
    {"featureType": "transit", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]},
    {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3d3d3d"}]}
  ]
  ''';

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TACTICAL MAP // HYDRO_VISION'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: {
               Marker(
                 markerId: const MarkerId('m1'),
                 position: _center,
                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
               ),
               Marker(
                 markerId: const MarkerId('m2'),
                 position: const LatLng(45.54, -122.65),
                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
               ),
               Marker(
                 markerId: const MarkerId('m3'),
                 position: const LatLng(45.51, -122.69),
                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
               ),
            },
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
                      const Icon(Icons.radar, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 12),
                      Text(
                        'SYS_MAP // SENSOR GRID',
                        style: GoogleFonts.shareTechMono(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                        ),
                        child: Text(
                          'LIVE',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Glass legend replacing basic container
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: 20,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   MapMarkerLegend(markerType: MarkerType.safe),
                   MapMarkerLegend(markerType: MarkerType.warning),
                   MapMarkerLegend(markerType: MarkerType.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MarkerType { safe, warning, danger }

class MapMarkerLegend extends StatelessWidget {
  final MarkerType markerType;

  const MapMarkerLegend({super.key, required this.markerType});

  @override
  Widget build(BuildContext context) {
    Color markerColor;
    IconData iconData;
    String label;

    switch (markerType) {
      case MarkerType.safe:
        markerColor = const Color(0xFF00E5FF); // Neon Cyan
        iconData = Icons.water_drop;
        label = 'NOMINAL';
        break;
      case MarkerType.warning:
        markerColor = const Color(0xFFFFC400); // Amber
        iconData = Icons.warning;
        label = 'ELEVATED';
        break;
      case MarkerType.danger:
        markerColor = Colors.redAccent;
        iconData = Icons.dangerous;
        label = 'CRITICAL';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: markerColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: markerColor, width: 2),
          ),
          child: Center(
            child: Icon(
              iconData,
              color: markerColor,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: markerColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
