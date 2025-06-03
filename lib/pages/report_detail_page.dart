import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:allycall/widgets/places_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final api = ApiService();

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late LatLng selectedLatLng;
  late GoogleMapController mapController;
  List<String> _tags = [];
  String? _selectedTag;
  bool isLoadingTags = true;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _fetchReportTags() async {
    try {
      final tagResponse = await api.get('reports/tags');
      setState(() {
        _tags = List<String>.from(tagResponse);
        _selectedTag = _tags.isNotEmpty ? widget.report['tag'] : _tags.first;
        isLoadingTags = false;
      });
    } catch (e) {
      debugPrint("Error loading tags: $e");
      setState(() {
        isLoadingTags = false;
      });
    }
  }

  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Report'),
            content: const Text('Are you sure you want to delete this report?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: Colors.black87),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF6F55D3),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await api.delete('reports/${widget.report['id']}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully')),
      );
      Navigator.pop(context, 'deleted');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete report: $e')));
    }
  }

  @override
  void initState() {
    _fetchReportTags();
    super.initState();
    _titleController.text = widget.report['title'] ?? 'Untitled Report';
    _descController.text =
        widget.report['description'] ?? 'No description provided.';
    _selectedTag = widget.report['tag'];
    selectedLatLng = LatLng(
      double.tryParse(widget.report['latitude'].toString()) ?? 0,
      double.tryParse(widget.report['longitude'].toString()) ?? 0,
    );
  }

  Future<dynamic> _openEditModal() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Edit Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context, false),
                          icon: Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text('Report Location'),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              mapController = controller;
                            },
                            initialCameraPosition: CameraPosition(
                              target: selectedLatLng,
                              zoom: 15,
                            ),
                            onCameraMove: (position) {
                              setModalState(() {
                                selectedLatLng = position.target;
                              });
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('report_location'),
                                position: selectedLatLng,
                              ),
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: CustomPlacesSearchBar(
                            onPlaceSelected: (lat, lng, desc) {
                              final newPos = LatLng(lat, lng);
                              setModalState(() {
                                selectedLatLng = newPos;
                              });
                              mapController.animateCamera(
                                CameraUpdate.newLatLngZoom(newPos, 15),
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
                          onChanged:
                              (val) => setState(() => _selectedTag = val!),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                    const SizedBox(height: 16),
                    const Text('Report Detail'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describe what happened...',
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _deleteReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA587E7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Delete'),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final updatedReport = {
                                  "tag": _selectedTag,
                                  "title": _titleController.text,
                                  "description": _descController.text,
                                  "name": widget.report['name'] ?? '',
                                  "latitude": selectedLatLng.latitude,
                                  "longitude": selectedLatLng.longitude,
                                  "shortAddress":
                                      widget.report['short_address'] ?? '',
                                  "longAddress":
                                      widget.report['long_address'] ?? '',
                                };

                                final reportId = widget.report['id'].toString();
                                try {
                                  await api.put(
                                    'reports/$reportId',
                                    updatedReport,
                                  );
                                  if (!mounted) return;
                                  setState(() {
                                    widget.report['tag'] = _selectedTag;
                                    widget.report['title'] =
                                        _titleController.text;
                                    widget.report['description'] =
                                        _descController.text;
                                    widget.report['latitude'] =
                                        selectedLatLng.latitude;
                                    widget.report['longitude'] =
                                        selectedLatLng.longitude;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Report updated successfully',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context, 'updated');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update report: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6F55D3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Save'),
                                  SizedBox(width: 8),
                                  Icon(Icons.save),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.report['users']['id'] == AuthService().getUserId();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context, true),
        ),
        actions:
            isOwner
                ? [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final result = await _openEditModal();
                      if (result == 'deleted') {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ]
                : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: const Text(
          'Report Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(Icons.label, size: 16, color: Color(0xFF6E56C9)),
                const SizedBox(width: 6),
                Text(
                  widget.report['tag'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E56C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _titleController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Report Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLatLng,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('report_location'),
                    position: selectedLatLng,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  formatDate(widget.report['created_at']),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.report['long_address'] ?? 'Unknown location',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _descController.text,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
