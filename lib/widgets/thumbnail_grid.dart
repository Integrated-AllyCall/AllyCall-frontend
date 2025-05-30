import 'package:allycall/pages/video_detail_page.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';

class ThumbnailGrid extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final int crossAxisCount;
  final Future<void> Function()? onRefresh;

  const ThumbnailGrid({
    super.key,
    required this.videos,
    required this.crossAxisCount,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 2 ? 9 / 19 : 9 / 20,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnail = video['thumbnail_url'] as String?;
        final title = video['title'] ?? '';
        final author = video['users']['username'] ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoDetailPage(video: video),
                  ),
                );
                if(result == true && onRefresh != null){
                  print("onRefresh triggered");
                  await onRefresh!();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    thumbnail != null && thumbnail.isNotEmpty
                        ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                          loadingBuilder:
                              (context, child, loadingProgress) =>
                                  loadingProgress == null
                                      ? child
                                      : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Author with icon
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3),
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
                ),

                // Duration
                Text(
                  formatDuration(video['duration'] ?? 0),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
