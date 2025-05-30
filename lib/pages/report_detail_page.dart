
import 'package:allycall/pages/profile_page.dart';
import 'package:allycall/services/api_service.dart';
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
  late String title;
  late String description;
  late LatLng selectedLatLng;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    title = widget.report['title'] ?? 'Untitled Report';
    description = widget.report['description'] ?? 'No description provided.';
    selectedLatLng = LatLng(
      double.tryParse(widget.report['latitude'].toString()) ?? 0,
      double.tryParse(widget.report['longitude'].toString()) ?? 0,
    );
  }

  void _openEditModal() {
    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);
    final List<String> tagLabels = enumTags.keys.toList();

    String selectedDisplayTag =
        displayTags[widget.report['tag']] ?? widget.report['tag'];

    showModalBottomSheet(
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
                    const Text(
                      'Edit Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    const Text('Tag'),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedDisplayTag,
                      items:
                          tagLabels
                              .map(
                                (label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedDisplayTag = val!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('Report Title'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter report title',
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('Report Detail'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descriptionController,
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
                        onPressed: () async {
                          setState(() {
                            title = titleController.text;
                            description = descriptionController.text;
                          });

                          final updatedReport = {
                            "tag":
                                enumTags[selectedDisplayTag] ??
                                selectedDisplayTag,
                            "title": titleController.text,
                            "description": descriptionController.text,
                            "name": widget.report['name'] ?? '',
                            "latitude": selectedLatLng.latitude,
                            "longitude": selectedLatLng.longitude,
                            "shortAddress":
                                widget.report['short_address'] ?? '',
                            "longAddress": widget.report['long_address'] ?? '',
                          };

                          final reportId = widget.report['id'].toString();
                          try {
                            await api.put('reports/$reportId', updatedReport);
                            if (!mounted) return;
                            setState(() {
                              widget.report['tag'] =
                                  enumTags[selectedDisplayTag] ??
                                  selectedDisplayTag;
                              widget.report['title'] = titleController.text;
                              widget.report['description'] =
                                  descriptionController.text;
                              widget.report['latitude'] =
                                  selectedLatLng.latitude;
                              widget.report['longitude'] =
                                  selectedLatLng.longitude;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Report updated successfully'),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update report: $e'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _openEditModal,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: const Text(''),
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
                  displayTags[widget.report['tag']] ?? widget.report['tag'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E56C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
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
              description,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
