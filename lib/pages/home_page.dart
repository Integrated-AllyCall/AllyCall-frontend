import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ant_design.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:allycall/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:allycall/widgets/legal_card.dart';
import 'package:allycall/pages/legal_detail_page.dart';

final api = ApiService();

const svgPhone = '''
<svg width="20" height="25" viewBox="0 0 20 25" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9.58327 8.43654L7.58468 10.2297C7.84888 11.134 8.21791 12.0043 8.68427 12.8228C9.17071 13.6354 9.75687 14.3839 10.4291 15.051L13.0174 14.2535C14.4674 13.8064 16.0503 14.2655 17.0145 15.4135L18.4887 17.168C19.0855 17.8723 19.3848 18.7813 19.323 19.7025C19.2612 20.6236 18.8432 21.4845 18.1576 22.1028C15.753 24.2971 12.0507 25.039 9.27877 22.8616C6.84148 20.9446 4.78 18.593 3.19843 15.9258C1.61285 13.2717 0.551271 10.338 0.0712686 7.28379C-0.460398 3.84729 2.05535 1.09713 5.19219 0.159461C7.06269 -0.401206 9.05885 0.560628 9.74518 2.35379L10.5548 4.46838C11.0864 5.86038 10.7046 7.43121 9.58327 8.43654Z" fill="white"/>
</svg>
''';
const svgBulb =
    '''<svg width="14" height="15" viewBox="0 0 14 15" fill="none" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#clip0_31_286)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M8.5225 13.7205C8.04773 13.9499 7.52727 14.069 7 14.069C6.47273 14.069 5.95227 13.9499 5.4775 13.7205L5.36375 13.6654C5.06758 13.5223 4.81773 13.2986 4.64285 13.0201C4.46797 12.7415 4.37514 12.4193 4.375 12.0904V11.6809C4.375 10.4979 3.696 9.44349 3.0275 8.46699C2.53309 7.744 2.24538 6.89979 2.19535 6.02534C2.14533 5.15089 2.3349 4.27938 2.74363 3.50472C3.15236 2.73006 3.76475 2.08163 4.5148 1.62933C5.26485 1.17702 6.12412 0.937988 7 0.937988C7.87587 0.937988 8.73514 1.17702 9.48519 1.62933C10.2352 2.08163 10.8476 2.73006 11.2564 3.50472C11.6651 4.27938 11.8547 5.15089 11.8046 6.02534C11.7546 6.89979 11.4669 7.744 10.9725 8.46699C10.304 9.44349 9.625 10.4979 9.625 11.6817V12.0904C9.62502 12.4194 9.53226 12.7418 9.35737 13.0206C9.18248 13.2993 8.93255 13.5231 8.63625 13.6662L8.5225 13.7205ZM6.048 12.5392L5.93425 12.4832C5.86029 12.4474 5.79792 12.3915 5.75428 12.3218C5.71064 12.2522 5.68749 12.1717 5.6875 12.0895V11.6809C5.6875 11.5321 5.68021 11.3863 5.66562 11.2434C6.53622 11.5033 7.46378 11.5033 8.33437 11.2434C8.32037 11.3863 8.31308 11.5321 8.3125 11.6809V12.0895C8.3125 12.1717 8.28936 12.2522 8.24572 12.3218C8.20208 12.3915 8.13971 12.4474 8.06575 12.4832L7.952 12.5384C7.65515 12.6819 7.32971 12.7564 7 12.7564C6.67029 12.7564 6.34485 12.6827 6.048 12.5392ZM9.88925 7.72499C9.5445 8.22899 9.10962 8.86424 8.78412 9.60449C8.25122 9.94461 7.63219 10.1253 7 10.1253C6.3678 10.1253 5.74878 9.94461 5.21587 9.60449C4.89037 8.86424 4.4555 8.22899 4.10987 7.72499C3.75051 7.19914 3.54146 6.58521 3.50523 5.94933C3.469 5.31345 3.60697 4.67973 3.90427 4.11647C4.20157 3.55321 4.64693 3.08174 5.19237 2.75288C5.73781 2.42402 6.36265 2.25023 6.99956 2.25023C7.63647 2.25023 8.26131 2.42402 8.80675 2.75288C9.35219 3.08174 9.79755 3.55321 10.0949 4.11647C10.3922 4.67973 10.5301 5.31345 10.4939 5.94933C10.4577 6.58521 10.2486 7.19914 9.88925 7.72499Z" fill="#6E56C9"/>
<path d="M7 3.5625C7.17405 3.5625 7.34097 3.63164 7.46404 3.75471C7.58711 3.87778 7.65625 4.0447 7.65625 4.21875C7.65625 4.3928 7.58711 4.55972 7.46404 4.68279C7.34097 4.80586 7.17405 4.875 7 4.875C6.76794 4.875 6.54538 4.96719 6.38128 5.13128C6.21719 5.29538 6.125 5.51794 6.125 5.75C6.125 5.92405 6.05586 6.09097 5.93279 6.21404C5.80972 6.33711 5.6428 6.40625 5.46875 6.40625C5.2947 6.40625 5.12778 6.33711 5.00471 6.21404C4.88164 6.09097 4.8125 5.92405 4.8125 5.75C4.8125 5.16984 5.04297 4.61344 5.4532 4.2032C5.86344 3.79297 6.41984 3.5625 7 3.5625Z" fill="#6E56C9"/>
</g>
<defs>
<clipPath id="clip0_31_286">
<rect width="14" height="14" fill="white" transform="matrix(-1 0 0 1 14 0.5)"/>
</clipPath>
</defs>
</svg>
''';

const svgAim =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none"><path d="m12.593 23.258l-.011.002l-.071.035l-.02.004l-.014-.004l-.071-.035q-.016-.005-.024.005l-.004.01l-.017.428l.005.02l.01.013l.104.074l.015.004l.012-.004l.104-.074l.012-.016l.004-.017l-.017-.427q-.004-.016-.017-.018m.265-.113l-.013.002l-.185.093l-.01.01l-.003.011l.018.43l.005.012l.008.007l.201.093q.019.005.029-.008l.004-.014l-.034-.614q-.005-.018-.02-.022m-.715.002a.02.02 0 0 0-.027.006l-.006.014l-.034.614q.001.018.017.024l.015-.002l.201-.093l.01-.008l.004-.011l.017-.43l-.003-.012l-.01-.01z"/><path fill="currentColor" d="M12 2a1 1 0 0 1 1 1v.055A9.004 9.004 0 0 1 20.945 11H21a1 1 0 1 1 0 2h-.055A9.004 9.004 0 0 1 13 20.945V21a1 1 0 1 1-2 0v-.055A9.004 9.004 0 0 1 3.055 13H3a1 1 0 1 1 0-2h.055A9.004 9.004 0 0 1 11 3.055V3a1 1 0 0 1 1-1m1 3.07V6a1 1 0 0 1-1.993.117L11 6v-.93a7.01 7.01 0 0 0-5.888 5.676L5.071 11H6a1 1 0 0 1 .117 1.993L6 13h-.93a7.01 7.01 0 0 0 5.676 5.888l.254.041V18a1 1 0 0 1 1.993-.117L13 18v.93a7.01 7.01 0 0 0 5.888-5.676l.041-.254H18a1 1 0 0 1-.117-1.993L18 11h.93a7.01 7.01 0 0 0-5.676-5.888zm-1 5.43a1.5 1.5 0 1 1 0 3a1.5 1.5 0 0 1 0-3"/></g></svg>''';

class HomePage extends StatefulWidget {
  final TabController tabController;
  const HomePage({super.key, required this.tabController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget? _profileImage;
  List<Map<String, dynamic>> videos = [];
  List<dynamic> _legalList = [];
  bool _isLoadingLocation = true;
  String? _countryName;
  List<Map<String, dynamic>> nearbyReports = [];
  String? _cityName;

  @override
  void initState() {
    super.initState();
    _fetchVideo();
    loadProfileImage();
    _fetchCountryFromCoordinates();
    _fetchNearbyReports();
  }

  Future<void> _fetchCountryFromCoordinates() async {
    try {
      final position = await getCurrentLocation();
      final lat = position.latitude;
      final lng = position.longitude;

      final response = await ApiService().get('legals/here?lat=$lat&lng=$lng');

      setState(() {
        _countryName = response['name'] ?? 'Unknown country';
        _legalList = response['legal'] ?? [];
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error fetching country: $e');
      setState(() {
        _countryName = 'Location unavailable';
        _legalList = [];
        _isLoadingLocation = false;
      });
    }
  }

  final Map<String, dynamic> tagIcons = {
    'Harassment': Icons.do_not_touch,
    'Stalking': Icons.directions_walk,
    'Catcalling': Icons.record_voice_over,
    'Unsafe Area': Icons.dangerous_rounded,
    'Assault': svgAim,
    'Suspicious Activity': Icons.visibility_outlined,
  };
  final Map<String, String> displayTags = {
    'Unsafe_Area': 'Unsafe Area',
    'Suspicious_Activity': 'Suspicious Activity',
  };
  Future<void> _fetchNearbyReports() async {
    try {
      final position = await getCurrentLocation();
      final lat = position.latitude;
      final lng = position.longitude;

      final response = await api.get('reports/nearby?lat=$lat&lng=$lng');
      final reports = response['reports'] as List<dynamic>? ?? [];
      final city = response['city'] ?? 'Unknown Area';

      // Sort and take 5 most recent
      reports.sort(
        (a, b) => DateTime.parse(
          b['created_at'],
        ).compareTo(DateTime.parse(a['created_at'])),
      );

      setState(() {
        _cityName = city;
        nearbyReports = List<Map<String, dynamic>>.from(reports.take(5));
      });
    } catch (e) {
      print("Failed to fetch reports: $e");
    }
  }

  Future<void> _fetchVideo() async {
    final response = await api.get('videos?num=3');
    setState(() {
      videos = List<Map<String, dynamic>>.from(response);
    });
  }

  void loadProfileImage() async {
    final image = await AuthService().getProfileImage(size: 40);
    setState(() {
      _profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF7C55D4),
            child: CustomScrollView(
              slivers: [_buildAppBar(), _buildMainContent()],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      forceMaterialTransparency: true,
      expandedHeight: 160,
      floating: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _profileImage ?? Iconify(Gg.profile, size: 40),
                    const SizedBox(height: 4),
                    Text(
                      "Hello, ${AuthService().getUserName()}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Out alone today? AllyCall got your back",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Image.asset('assets/graphic.png'),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMainContent() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: svgPhone,
              title: 'Fake a Call Now',
              trailing: TextButton(
                onPressed: () => widget.tabController.animateTo(2),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8A8A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('See more'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            ThumbnailGrid(videos: videos, crossAxisCount: 3, onRefresh: _fetchVideo),
            const SizedBox(height: 10),
            _buildSectionHeader(
              icon: AntDesign.alert_filled,
              title: 'Nearby Reports',
              subtitle:
                  _isLoadingLocation
                      ? 'Loading location...'
                      : _cityName ?? 'Unknown Area',
              trailing: TextButton(
                onPressed: () => widget.tabController.animateTo(1),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8A8A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('See more'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...nearbyReports.map(_buildReportCard).toList(),
            const SizedBox(height: 24),
            _buildSectionHeader(
              icon: svgBulb,
              title: 'Your Legal Safety Guide',
              subtitle:
                  _isLoadingLocation
                      ? 'Loading location...'
                      : _countryName ?? 'Unknown location',
              trailing: TextButton(
                onPressed: () => widget.tabController.animateTo(3),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8A8A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('See more'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _legalList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75, // Matches GuidePage style
              ),
              itemBuilder: (context, index) {
                final item = _legalList[index];
                return LegalCard(
                  countryName: _countryName ?? '',
                  title: item['title'] ?? '',
                  description: item['description'] ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => LegalDetailPage(
                              data: item,
                              countryName: _countryName ?? '',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required dynamic icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon on the left
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child:
                icon is IconData
                    ? Icon(icon, color: const Color(0xFF6F55D3), size: 20)
                    : Iconify(icon, color: const Color(0xFF6F55D3), size: 20),
          ),

          // Text (title + subtitle) and trailing on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final createdDate = DateTime.parse(report['created_at']);
    final formattedDate =
        '${createdDate.year}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.day.toString().padLeft(2, '0')}';

    final tag = report['tag'] ?? '';
    final icon = tagIcons[tag] ?? Icons.warning; // fallback if not found

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
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
            // Icon with background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    icon is IconData
                        ? Icon(icon, color: const Color(0xFF6F55D3), size: 22)
                        : Iconify(
                          icon,
                          color: const Color(0xFF6F55D3),
                          size: 22,
                        ),
              ),
            ),
            const SizedBox(width: 12),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F55D3),
                          ),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final double latitude = double.parse(report['latitude'].toString());
    final double longitude = double.parse(report['longitude'].toString());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
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
            // Tag
            Row(
              children: [
                const Icon(Icons.label, size: 16, color: Color(0xFF6E56C9)),
                const SizedBox(width: 6),
                Text(
                  report['tag'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E56C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              report['title'] ?? 'Untitled Report',
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
                  target: LatLng(latitude, longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('report_location'),
                    position: LatLng(latitude, longitude),
                    infoWindow: InfoWindow(title: report['title'] ?? 'Report'),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationEnabled: false,

                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
            const SizedBox(height: 8),
            // Date
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  report['created_at'],
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report['long_address'] ?? 'Unknown location',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              report['description'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 20),

            // Map
          ],
        ),
      ),
    );
  }
}
