import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:allycall/widgets/places_search_bar.dart';

final api = ApiService();
const svgAim =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none"><path d="m12.593 23.258l-.011.002l-.071.035l-.02.004l-.014-.004l-.071-.035q-.016-.005-.024.005l-.004.01l-.017.428l.005.02l.01.013l.104.074l.015.004l.012-.004l.104-.074l.012-.016l.004-.017l-.017-.427q-.004-.016-.017-.018m.265-.113l-.013.002l-.185.093l-.01.01l-.003.011l.018.43l.005.012l.008.007l.201.093q.019.005.029-.008l.004-.014l-.034-.614q-.005-.018-.02-.022m-.715.002a.02.02 0 0 0-.027.006l-.006.014l-.034.614q.001.018.017.024l.015-.002l.201-.093l.01-.008l.004-.011l.017-.43l-.003-.012l-.01-.01z"/><path fill="currentColor" d="M12 2a1 1 0 0 1 1 1v.055A9.004 9.004 0 0 1 20.945 11H21a1 1 0 1 1 0 2h-.055A9.004 9.004 0 0 1 13 20.945V21a1 1 0 1 1-2 0v-.055A9.004 9.004 0 0 1 3.055 13H3a1 1 0 1 1 0-2h.055A9.004 9.004 0 0 1 11 3.055V3a1 1 0 0 1 1-1m1 3.07V6a1 1 0 0 1-1.993.117L11 6v-.93a7.01 7.01 0 0 0-5.888 5.676L5.071 11H6a1 1 0 0 1 .117 1.993L6 13h-.93a7.01 7.01 0 0 0 5.676 5.888l.254.041V18a1 1 0 0 1 1.993-.117L13 18v.93a7.01 7.01 0 0 0 5.888-5.676l.041-.254H18a1 1 0 0 1-.117-1.993L18 11h.93a7.01 7.01 0 0 0-5.676-5.888zm-1 5.43a1.5 1.5 0 1 1 0 3a1.5 1.5 0 0 1 0-3"/></g></svg>''';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final Map<String, dynamic> tagIcons = {
  'Harassment': Icons.do_not_touch,
  'Stalking': Icons.directions_walk,
  'Catcalling': Icons.record_voice_over,
  'Unsafe Area': Icons.dangerous_rounded, // fixed name
  'Assault': svgAim, // svgGun is a String, others are IconData
  'Suspicious Activity': Icons.visibility_outlined, // fixed name
};
final Map<String, String> displayTags = {
  'Harassment': 'Harassment',
  'Stalking': 'Stalking',
  'Catcalling': 'Catcalling',
  'Unsafe_Area': 'Unsafe Area',
  'Assault': 'Assault',
  'Suspicious_Activity': 'Suspicious Activity',
};

final Map<String, String> enumTags = {
  'Harassment': 'Harassment',
  'Stalking': 'Stalking',
  'Catcalling': 'Catcalling',
  'Unsafe Area': 'Unsafe_Area',
  'Assault': 'Assault',
  'Suspicious Activity': 'Suspicious_Activity',
};

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  Widget? _profileImage;
  late final TabController _tabController;
  List<Map<String, dynamic>> videos = [];
  List<Map<String, dynamic>> reports = [];
  void loadProfileImage() async {
    final image = await AuthService().getProfileImage(size: 80);
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> fetchVideo() async {
    final response = await api.get('videos/user/${AuthService().getUserId()}');
    setState(() {
      videos = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchReports() async {
    final userId = AuthService().getUserId();
    final response = await api.get('reports/user/$userId');
    setState(() {
      reports = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadProfileImage();
    fetchVideo();
    fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [_buildAppBar(context)],
          body: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ThumbnailGrid(videos: videos, crossAxisCount: 3),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children:
                      reports.map((report) {
                        return ReportCard(
                          report: report,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ReportDetailPage(report: report),
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Color(0xFFF7F6FC),
      expandedHeight: 320,
      pinned: true,
      floating: false,
      toolbarHeight: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF6F55D3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Your Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _profileImage ??
                const Iconify(Gg.profile, size: 80, color: Color(0xFF8A8A8A)),
            Text(
              AuthService().getUserName(),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              AuthService().getUserEmail(),
              style: const TextStyle(color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 15),
            FloatingActionButton.extended(
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text(
                          'Confirm Logout',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF6F55D3),
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );
                if (shouldLogout == true) {
                  await AuthService().signOut();
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFA587E7),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        indicatorColor: const Color(0xFF6E56C9),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF8A8A8A),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const <Widget>[Tab(text: 'Video'), Tab(text: 'Report')],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final createdDate =
        DateTime.tryParse(report['created_at'] ?? '') ?? DateTime.now();
    final formattedDate =
        '${createdDate.year}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.day.toString().padLeft(2, '0')}';

    final rawTag = report['tag'] ?? '';
    final tag = displayTags[rawTag] ?? rawTag;

    final icon = tagIcons[tag] ?? Icons.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2ECFF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child:
                  icon is IconData
                      ? Icon(icon, size: 22, color: const Color(0xFF6F55D3))
                      : Iconify(icon, size: 22, color: const Color(0xFF6F55D3)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6F55D3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report['short_address'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  widget.report['created_at'],
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
