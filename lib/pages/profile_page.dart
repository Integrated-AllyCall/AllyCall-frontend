import 'package:allycall/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget? _profileImage;
  void loadProfileImage() async {
    final image = await AuthService().getProfileImage(size: 80);
    setState(() {
      _profileImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          const Text('Profile Page'),
          _profileImage ?? Iconify(Gg.profile, size: 80, color: Color(0xFF8A8A8A)),
          Text(AuthService().getUserName()),
          Text(AuthService().getUserEmail()),
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
    );
  }
}
