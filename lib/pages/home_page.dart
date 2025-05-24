import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ant_design.dart';
import 'package:iconify_flutter/icons/gg.dart';

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

class HomePage extends StatefulWidget {
  final TabController tabController;
  const HomePage({super.key, required this.tabController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget? _profileImage;
  List<Map<String, dynamic>> videos = [];
  Future<void> fetchVideo() async {
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
  void initState() {
    fetchVideo();
    loadProfileImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xFF7C55D4), // Purple background
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  forceMaterialTransparency: true,
                  expandedHeight: 160,
                  floating: false,
                  pinned: true,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Graphic
                          Image.asset(
                            'assets/graphic.png',
                            // height: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Iconify(
                                svgPhone,
                                color: Color(0xFF6F55D3),
                                size: 15,
                              ),
                            ),
                            Text(
                              'Fake a Call Now',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed:
                                  () => widget.tabController.animateTo(2),
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF8A8A8A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
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
                          ],
                        ),
                        SizedBox(
                          height: 320,
                          child: ThumbnailGrid(
                            videos: videos,
                            crossAxisCount: 3,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Iconify(
                                AntDesign.alert_filled,
                                color: Color(0xFF6F55D3),
                                size: 18,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Nearby Reports',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Bangkok, Thailand',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Iconify(
                                svgBulb,
                                color: Color(0xFF6F55D3),
                                size: 18,
                              ),
                            ),
                            Text(
                              'Your Legal Safety Guide',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
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
}
