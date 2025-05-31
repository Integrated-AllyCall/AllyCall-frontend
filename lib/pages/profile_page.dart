import 'package:allycall/pages/report_detail_page.dart';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';

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
  'Unsafe Area': Icons.dangerous_rounded,
  'Assault': svgAim,
  'Suspicious Activity': Icons.visibility_outlined,
};

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  Widget? _profileImage;
  late final TabController _tabController;
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _reports = [];
  void loadProfileImage() async {
    final image = await AuthService().getProfileImage(size: 80);
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _fetchVideo() async {
    final response = await api.get('videos/user/${AuthService().getUserId()}');
    setState(() {
      _videos = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _fetchReports() async {
    final userId = await AuthService().getUserId();
    final response = await api.get('reports/user/$userId');
    setState(() {
      _reports = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadProfileImage();
    _fetchVideo();
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F55D3),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [_buildAppBar(context)],
          body: TabBarView(
            controller: _tabController,
            children: [
               // VIdeo Tab
              Container(
                color: Color(0xFFF7F6FC),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ThumbnailGrid(
                    videos: _videos,
                    crossAxisCount: 3,
                    onRefresh: _fetchVideo,
                  ),
                ),
              ),

              // Report Tab
              Container(
                color: Color(0xFFF7F6FC),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children:
                        _reports.map((report) {
                          return ReportCard(
                            report: report,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ReportDetailPage(report: report),
                                ),
                              );
                              if (result == true) {
                                await _fetchReports();
                              }
                            },
                          );
                        }).toList(),
                  ),
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
              height: 55,
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
    final tag = report['tag'] ?? '';
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
              formatDate(report['created_at']),
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
