import 'package:allycall/pages/video_edit_page.dart';
import 'package:allycall/pages/video_player_page.dart';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:iconify_flutter/icons/heroicons.dart';

final api = ApiService();
const svgVideo =
    '''<svg width="12" height="10" viewBox="0 0 12 10" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4.27734 3.54199V6.45866" stroke="white" stroke-width="0.875" stroke-miterlimit="10" stroke-linecap="round"/>
<path d="M5.61511 4.7696L4.46769 3.62218C4.44277 3.59723 4.41317 3.57743 4.38059 3.56392C4.34801 3.55041 4.31309 3.54346 4.27782 3.54346C4.24255 3.54346 4.20762 3.55041 4.17504 3.56392C4.14246 3.57743 4.11286 3.59723 4.08794 3.62218L2.93994 4.7696" stroke="white" stroke-width="0.875" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.00017 1.10352H2.55558C2.2798 1.10352 2.00672 1.15791 1.75199 1.26359C1.49725 1.36927 1.26586 1.52416 1.07107 1.71939C0.876277 1.91461 0.721904 2.14634 0.616791 2.40131C0.511677 2.65628 0.457888 2.92948 0.458501 3.20527V6.79977C0.458501 7.35595 0.679443 7.88935 1.07272 8.28263C1.26745 8.47736 1.49864 8.63183 1.75307 8.73722C2.0075 8.84261 2.28019 8.89685 2.55558 8.89685H6.00017C6.55635 8.89685 7.08975 8.67591 7.48303 8.28263C7.87631 7.88935 8.09725 7.35595 8.09725 6.79977V3.20585C8.09802 2.92999 8.04434 2.6567 7.93929 2.40163C7.83423 2.14656 7.67988 1.91472 7.48506 1.71942C7.29024 1.52412 7.0588 1.36918 6.80399 1.26349C6.54918 1.1578 6.27602 1.10344 6.00017 1.10352ZM11.5418 3.50568V6.5011C11.5418 6.64693 11.5004 6.79043 11.4223 6.9141C11.3431 7.03813 11.231 7.1377 11.0985 7.20168C10.9669 7.26756 10.8186 7.29274 10.6727 7.27402C10.5288 7.25677 10.3922 7.20072 10.2778 7.11185L8.3965 5.60218C8.30614 5.52782 8.23308 5.43466 8.1824 5.32918C8.13173 5.2237 8.10466 5.10844 8.10308 4.99143C8.10308 4.87477 8.12933 4.76043 8.18067 4.65602C8.23433 4.55802 8.30783 4.47227 8.3965 4.40402L10.2778 2.9066C10.3923 2.81738 10.5291 2.76128 10.6733 2.74443C10.8191 2.72577 10.9673 2.75085 11.0985 2.81677C11.2293 2.8788 11.3402 2.97619 11.4185 3.09794C11.4969 3.21968 11.5396 3.36092 11.5418 3.50568Z" stroke="white" stroke-width="0.875" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class VideoDetailPage extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _video;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _fetchVideo();
  }

  Future<void> _fetchVideo() async {
    final id = widget.video['id'];
    final data = await api.get('videos/$id');
    setState(() {
      _video = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _video?['users']['id'] == AuthService().getUserId();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
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
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoEditPage(video: _video!),
                        ),
                      );

                      if (result == true) {
                        await _fetchVideo();
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
          'Video Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[_buildVideo(_video!), _buildMainContent(_video!)],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildVideo(video) {
    final thumbnail = video['thumbnail_url'] as String?;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.40,
          10,
          MediaQuery.of(context).size.width * 0.40,
          10,
        ),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              child:
                  thumbnail != null && thumbnail.isNotEmpty
                      ? Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image)),
                        loadingBuilder:
                            (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                      )
                      : const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMainContent(video) {
    final author = video['users']['username'] ?? 'Guest';
    final screenHeight = MediaQuery.of(context).size.height;
    final reservedHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight + 16 + 180;

    return SliverToBoxAdapter(
      child: Container(
        constraints: BoxConstraints(minHeight: screenHeight - reservedHeight),
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final videoUrl = video['video_url'] as String?;
                  if (videoUrl != null && videoUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(videoUrl: videoUrl),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No video available.')),
                    );
                  }
                },
                icon: const Iconify(Heroicons.play_solid, color: Colors.white),
                label: const Text(
                  'Start Fake Call',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF6E56C9),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(3),
                  child: Iconify(
                    Gg.profile,
                    size: 10,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Expanded(
                  child: Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.label, size: 16, color: Color(0xFF6E56C9)),
                const SizedBox(width: 6),
                Text(
                  video['tag'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E56C9),
                  ),
                ),
              ],
            ),
            Text(
              video['title'] ?? 'Untitled Report',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFF8A8A8A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formatDate(video['created_at']),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              video['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
