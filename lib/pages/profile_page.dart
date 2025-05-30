import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';

final api = ApiService();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  Widget? _profileImage;
  late final TabController _tabController;
  List<Map<String, dynamic>> videos = [];

  void loadProfileImage() async {
    final image = await AuthService().getProfileImage(size: 80);
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _fetchVideo() async {
    final response = await api.get('videos/user/${AuthService().getUserId()}');
    setState(() {
      videos = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadProfileImage();
    _fetchVideo();
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
                child: ThumbnailGrid(videos: videos, crossAxisCount: 3, onRefresh: _fetchVideo),
              ),
              const Center(child: Text('Report History')),
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
