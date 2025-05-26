import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:iconify_flutter/icons/uil.dart';

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

  Future<void> fetchVideo() async {
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
    fetchVideo();
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
              const Center(child: Text('Report History')),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: false,
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 300,
      title: Column(
        children: [
          Container(
            alignment: AlignmentDirectional.topCenter,
            decoration: const BoxDecoration(
              color: Color(0xFF6F55D3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: const Text(
                'Your Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _profileImage ??
              Iconify(Gg.profile, size: 80, color: Color(0xFF8A8A8A)),
          Text(AuthService().getUserName(), style: TextStyle(fontSize: 16)),
          Text(
            AuthService().getUserEmail(),
            style: TextStyle(color: Color(0xFF8A8A8A)),
          ),
          SizedBox(height: 15),
          FloatingActionButton.extended(
            onPressed: () {
              // TODO: handle profile setting
              print("Profile Setting Click");
            },
            icon: const Iconify(Uil.setting, color: Colors.white),
            label: const Text(
              'Profile Setting',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFA587E7),
          ),
          TextButton.icon(
            onPressed: AuthService().signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ],
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
