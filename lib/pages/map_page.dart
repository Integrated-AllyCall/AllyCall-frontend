import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/location_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:allycall/widgets/places_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final api = ApiService();

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(13.7563, 100.5018);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _fetchNearbyReport(double lat, double lng) async {
    try {
      final data = await api.get('reports/nearby?lat=$lat&lng=$lng');

      final markerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/marker.png',
      );

      final newMarkers = Set<Marker>.from(
        _markers.where((m) => m.markerId.value == 'selected_place'),
      );

      for (final report in data) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('report_${report['id']}'),
            position: LatLng(report['latitude'], report['longitude']),
            infoWindow: InfoWindow(
              title: report['tag'],
              snippet: '${report['long_address']} · Tap to see more',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => buildReportBottomSheet(context, report),
                );
              },
            ),
            icon: markerIcon,
          ),
        );
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  Future<void> _initLocation() async {
    try {
      final position = await getCurrentLocation();
      final userLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _center = userLatLng;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map in background
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
            myLocationEnabled: true,
            markers: _markers,
          ),

          Container(
            alignment: AlignmentDirectional.topCenter,
            decoration: const BoxDecoration(
              color: Color(0xFF6F55D3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: const Text(
                'Unsafe Spots',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 60, left: 20, right: 20),
            alignment: Alignment.topCenter,
            child: CustomPlacesSearchBar(
              onPlaceSelected: (lat, lng, desc) {
                final selectedLatLng = LatLng(lat, lng);

                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: const MarkerId('selected_place'),
                      position: selectedLatLng,
                      infoWindow: InfoWindow(title: desc),
                    ),
                  );
                });
                _fetchNearbyReport(lat, lng);

                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(selectedLatLng, 14),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                // TODO: handle add report action
                print("Add Report clicked");
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Report',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFA587E7),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildReportBottomSheet(
  BuildContext context,
  Map<String, dynamic> report,
) {
  return SizedBox(
    height: 350,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),

          Row(
            children: [
              const Icon(Icons.label, size: 16, color: Color(0xFF6E56C9)),
              const SizedBox(width: 6),
              Text(
                report['tag'] ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6E56C9)),
              ),
            ],
          ),
          Text(
            report['title'] ?? 'Untitled Report',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, size: 16, color: Color(0xFF8A8A8A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  report['long_address'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFF8A8A8A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatDate(report['created_at']),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report['description'] ?? 'No description available.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
