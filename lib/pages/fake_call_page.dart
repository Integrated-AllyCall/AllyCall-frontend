import 'dart:io';

import 'package:allycall/pages/video_create_page.dart';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/widgets/thumbnail_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

final api = ApiService();
const svgVideo =
    '''<svg width="12" height="10" viewBox="0 0 12 10" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4.27734 3.54199V6.45866" stroke="white" stroke-width="0.875" stroke-miterlimit="10" stroke-linecap="round"/>
<path d="M5.61511 4.7696L4.46769 3.62218C4.44277 3.59723 4.41317 3.57743 4.38059 3.56392C4.34801 3.55041 4.31309 3.54346 4.27782 3.54346C4.24255 3.54346 4.20762 3.55041 4.17504 3.56392C4.14246 3.57743 4.11286 3.59723 4.08794 3.62218L2.93994 4.7696" stroke="white" stroke-width="0.875" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.00017 1.10352H2.55558C2.2798 1.10352 2.00672 1.15791 1.75199 1.26359C1.49725 1.36927 1.26586 1.52416 1.07107 1.71939C0.876277 1.91461 0.721904 2.14634 0.616791 2.40131C0.511677 2.65628 0.457888 2.92948 0.458501 3.20527V6.79977C0.458501 7.35595 0.679443 7.88935 1.07272 8.28263C1.26745 8.47736 1.49864 8.63183 1.75307 8.73722C2.0075 8.84261 2.28019 8.89685 2.55558 8.89685H6.00017C6.55635 8.89685 7.08975 8.67591 7.48303 8.28263C7.87631 7.88935 8.09725 7.35595 8.09725 6.79977V3.20585C8.09802 2.92999 8.04434 2.6567 7.93929 2.40163C7.83423 2.14656 7.67988 1.91472 7.48506 1.71942C7.29024 1.52412 7.0588 1.36918 6.80399 1.26349C6.54918 1.1578 6.27602 1.10344 6.00017 1.10352ZM11.5418 3.50568V6.5011C11.5418 6.64693 11.5004 6.79043 11.4223 6.9141C11.3431 7.03813 11.231 7.1377 11.0985 7.20168C10.9669 7.26756 10.8186 7.29274 10.6727 7.27402C10.5288 7.25677 10.3922 7.20072 10.2778 7.11185L8.3965 5.60218C8.30614 5.52782 8.23308 5.43466 8.1824 5.32918C8.13173 5.2237 8.10466 5.10844 8.10308 4.99143C8.10308 4.87477 8.12933 4.76043 8.18067 4.65602C8.23433 4.55802 8.30783 4.47227 8.3965 4.40402L10.2778 2.9066C10.3923 2.81738 10.5291 2.76128 10.6733 2.74443C10.8191 2.72577 10.9673 2.75085 11.0985 2.81677C11.2293 2.8788 11.3402 2.97619 11.4185 3.09794C11.4969 3.21968 11.5396 3.36092 11.5418 3.50568Z" stroke="white" stroke-width="0.875" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class FakeCallPage extends StatefulWidget {
  final TabController tabController;
  const FakeCallPage({super.key, required this.tabController});

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage>
    with SingleTickerProviderStateMixin {
  List<String> _tags = [];
  List<Map<String, dynamic>> videos = [];
  TabController? _tabController;
  bool _isLoading = true;
  String? selectedTag;

  Future<void> _initData() async {
    try {
      final tagResponse = await api.get('videos/tags');
      final newTags = ['All', ...List<String>.from(tagResponse)];

      _tabController = TabController(length: newTags.length, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) return;
        selectedTag =
            newTags[_tabController!.index] == 'All'
                ? null
                : newTags[_tabController!.index];
        _handleSearch();
      });

      setState(() {
        _tags = newTags;
        _isLoading = false;
      });
      _handleSearch();
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _handleSearch({String? search}) async {
    String query = '';
    if (search != null && search.isNotEmpty) {
      query += 'search=$search';
    }
    if (selectedTag != null && selectedTag!.isNotEmpty) {
      if (query.isNotEmpty) query += '&';
      query += 'tag=$selectedTag';
    }

    final response = await api.get('videos?$query');
    setState(() {
      videos = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F6FC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: ThumbnailGrid(videos: videos, crossAxisCount: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Color(0xFFF7F6FC),
      floating: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 70,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    width: 360,
                    child: TextField(
                      onSubmitted: (value) => _handleSearch(search: value),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Find a call scenario...",
                        hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                        prefixIcon: const Icon(Icons.search),
                        prefixIconColor: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      print('Picked file: ${file.path}');

      // Navigate to EditPostPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCreatePage(file: file),
        ),
      );
    } else {
      print('No file selected');
    }
  } catch (e) {
    print('Error picking file: $e');
  }
},


                  icon: Iconify(svgVideo, size: 14, color: Colors.white),
                  label: const Text(
                    'Upload',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFF6E56C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        isScrollable: true,
        indicatorColor: const Color(0xFF6E56C9),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF8A8A8A),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: _tags.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
