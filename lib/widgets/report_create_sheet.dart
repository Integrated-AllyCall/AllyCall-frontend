import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/message_dialog.dart';
import 'package:allycall/widgets/places_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final api = ApiService();

class ReportCreateSheet extends StatefulWidget {
  final LatLng? initialLatLng;
  const ReportCreateSheet({super.key, this.initialLatLng});

  @override
  State<ReportCreateSheet> createState() => _ReportCreateSheetState();
}

class _ReportCreateSheetState extends State<ReportCreateSheet> {
  late GoogleMapController _mapController;
  late LatLng _selectedLatLng = const LatLng(13.7563, 100.5018);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  List<String> _tags = [];
  String? _selectedTag;
  bool isLoadingTags = true;
  DateTime selectedDate = DateTime.now();
  bool isSubmitting = false;

  @override
  void initState() {
    _selectedLatLng = widget.initialLatLng ?? const LatLng(13.7563, 100.5018);
    super.initState();
    _fetchReportTags();
  }

  Future<void> _fetchReportTags() async {
    try {
      final tagResponse = await api.get('reports/tags');
      setState(() {
        _tags = List<String>.from(tagResponse);
        _selectedTag = _tags.isNotEmpty ? _tags.first : null;
        isLoadingTags = false;
      });
    } catch (e) {
      debugPrint("Error loading tags: $e");
      setState(() {
        isLoadingTags = false;
      });
    }
  }

  Future<void> _showMessageDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => MessageDialog(
            title: title,
            content: content,
            onContinue: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _submitReport() async {
    final userId = await AuthService().getUserId();
    print('User ID: $userId');
    setState(() => isSubmitting = true);

    final reportData = {
      "tag": _selectedTag,
      "title": _titleController.text.isEmpty ? 'Untitled Report' : _titleController.text,
      "description": _detailController.text,
      "latitude": _selectedLatLng.latitude,
      "longitude": _selectedLatLng.longitude,
      "user_id": userId,
    };

    try {
      await api.post('reports', reportData);
      if (mounted) {
        await _showMessageDialog(context,'Success', 'Report submitted successfully!');
        Navigator.pop(context, _selectedLatLng);
      }
    } catch (e) {
      debugPrint('Error: $e');
      await _showMessageDialog(
        context,
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
                  icon: const Icon(Icons.close, color: Colors.black),
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
                    onMapCreated: (c) => _mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLatLng,
                      zoom: 15,
                    ),
                    onCameraMove: (pos) {
                      setState(() {
                        _selectedLatLng = pos.target;
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('report_location'),
                        position: _selectedLatLng,
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
                        _selectedLatLng = latLng;
                      });
                      _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(latLng, 15),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_selectedLatLng.latitude.toStringAsFixed(6)}, '
              'Lng: ${_selectedLatLng.longitude.toStringAsFixed(6)}',
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
                  value: _selectedTag,
                  items:
                      _tags
                          .map(
                            (tag) => DropdownMenuItem(
                              value: tag,
                              child: Text(tag.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedTag = val!),
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
