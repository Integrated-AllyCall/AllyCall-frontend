import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/location_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:allycall/widgets/places_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await api.get('reports/nearby?lat=$lat&lng=$lng');
      final List<dynamic> data = response['reports'] ?? [];

      final markerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/marker.png',
      );

      final newMarkers = Set<Marker>.from(
        _markers.where((m) => m.markerId.value == 'current_location'),
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
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: userLatLng,
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      });

      _fetchNearbyReport(userLatLng.latitude, userLatLng.longitude);
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 14));
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
            child: const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
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
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
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
              onPressed: () async {
                final LatLng? reportLocation =
                    await showModalBottomSheet<LatLng>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => const AddReportSheet(),
                    );

                if (reportLocation != null) {
                  setState(() {
                    _markers
                      ..clear()
                      ..add(
                        Marker(
                          markerId: const MarkerId(
                            'current_location',
                          ), // important!
                          position: reportLocation,
                          infoWindow: const InfoWindow(title: 'Your Report'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                        ),
                      );
                  });

                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(reportLocation, 15),
                  );

                  _fetchNearbyReport(
                    reportLocation.latitude,
                    reportLocation.longitude,
                  );
                }
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

class AddReportSheet extends StatefulWidget {
  const AddReportSheet({super.key});

  @override
  State<AddReportSheet> createState() => _AddReportSheetState();
}

class _AddReportSheetState extends State<AddReportSheet> {
  late GoogleMapController mapController;
  LatLng selectedLatLng = const LatLng(13.7563, 100.5018);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  List<String> tags = [];
  String selectedTag = '';
  bool isLoadingTags = true;
  DateTime selectedDate = DateTime.now();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/reports/tags'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> tagList = json.decode(response.body);
        setState(() {
          tags = tagList.map((t) => t.toString()).toList();
          selectedTag = tags.isNotEmpty ? tags.first : '';
          isLoadingTags = false;
        });
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      print('Error fetching tags: $e');
      setState(() {
        tags = ['Harassment'];
        selectedTag = 'Harassment';
        isLoadingTags = false;
      });
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _showMessageDialog(String title, String content) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitReport() async {
    final userId = await AuthService().getUserId();
    print('User ID: $userId');
    if (userId == null ||
        _titleController.text.isEmpty ||
        _detailController.text.isEmpty) {
      await _showMessageDialog(
        'Incomplete Form',
        'Please complete all fields and make sure you are signed in.',
      );
      return;
    }

    setState(() => isSubmitting = true);

    final reportData = {
      "tag": selectedTag,
      "title": _titleController.text,
      "description": _detailController.text,
      "latitude": selectedLatLng.latitude,
      "longitude": selectedLatLng.longitude,
      "user_id": userId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/reports'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reportData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, selectedLatLng); // close modal first
          await Future.delayed(const Duration(milliseconds: 300));
          await _showMessageDialog('Success', 'Report submitted successfully!');
        }
      } else {
        debugPrint('Failed with status: ${response.statusCode}');
        await _showMessageDialog(
          'Error',
          'Failed to submit report: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      await _showMessageDialog(
        'Error',
        'Something went wrong during submission.',
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Report Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Move the map to select a location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (c) => mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: selectedLatLng,
                      zoom: 15,
                    ),
                    onCameraMove: (pos) {
                      setState(() {
                        selectedLatLng = pos.target;
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('report_location'),
                        position: selectedLatLng,
                      ),
                    },
                    myLocationButtonEnabled: false,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: CustomPlacesSearchBar(
                    onPlaceSelected: (lat, lng, desc) {
                      final latLng = LatLng(lat, lng);
                      setState(() {
                        selectedLatLng = latLng;
                      });
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(latLng, 15),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${selectedLatLng.latitude.toStringAsFixed(6)}, '
              'Lng: ${selectedLatLng.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const Text('Report Title'),
            const SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter report title',
              ),
            ),
            const SizedBox(height: 16),

            const Text('Tag'),
            const SizedBox(height: 4),
            isLoadingTags
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                  value: selectedTag,
                  items:
                      tags
                          .map(
                            (tag) => DropdownMenuItem(
                              value: tag,
                              child: Text(tag.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => selectedTag = val!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
            const SizedBox(height: 16),

            const Text('Report Detail'),
            const SizedBox(height: 4),
            TextField(
              controller: _detailController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe what happened...',
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitReport,
                icon: const Icon(Icons.send),
                label: Text(isSubmitting ? 'Submitting...' : 'Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F55D3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
