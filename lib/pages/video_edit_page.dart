import 'package:allycall/services/api_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

final api = ApiService();
final svgTrash = '''<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M1.3335 3.08333H10.6668M4.8335 5.41667V8.91667M7.16683 5.41667V8.91667M1.91683 3.08333L2.50016 10.0833C2.50016 10.3928 2.62308 10.6895 2.84187 10.9083C3.06066 11.1271 3.35741 11.25 3.66683 11.25H8.3335C8.64292 11.25 8.93966 11.1271 9.15845 10.9083C9.37725 10.6895 9.50016 10.3928 9.50016 10.0833L10.0835 3.08333M4.25016 3.08333V1.33333C4.25016 1.17862 4.31162 1.03025 4.42102 0.920854C4.53041 0.811458 4.67879 0.75 4.8335 0.75H7.16683C7.32154 0.75 7.46991 0.811458 7.57931 0.920854C7.6887 1.03025 7.75016 1.17862 7.75016 1.33333V3.08333" stroke="white" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
class VideoEditPage extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoEditPage({super.key, required this.video});

  @override
  State<VideoEditPage> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends State<VideoEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedTag;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchVideoTags();
    _titleController.text = widget.video['title'] ?? 'Untitled Video';
    _descController.text =
        widget.video['description'] ?? 'No description provided.';
    _selectedTag = widget.video['tag'];
  }

  Future<void> _deleteVideo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Video'),
            content: const Text('Are you sure you want to delete this video?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await api.delete('videos/${widget.video['id']}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video deleted successfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error deleting video: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete video")));
    }
  }

  Future<void> _updateVideo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await api.put('videos/${widget.video['id']}', {
        "tag": _selectedTag,
        "title": _titleController.text,
        "description": _descController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video updated successfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error updating video: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update video")));
    }
  }

  Future<void> _fetchVideoTags() async {
    try {
      final tagResponse = await api.get('videos/tags');
      setState(() {
        _tags = List<String>.from(tagResponse);
        _selectedTag = _tags.isNotEmpty ? widget.video['tag'] : _tags.first;
      });
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.video['thumbnail_url'] as String?;
    final duration = widget.video['duration'];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF6F55D3),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          centerTitle: true,
          title: const Text(
            'Edit Video',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(150, 0, 150, 16),
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
                                        const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                loadingBuilder:
                                    (context, child, loadingProgress) =>
                                        loadingProgress == null
                                            ? child
                                            : const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                              )
                              : const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF8A8A8A),
                        ),
                        const SizedBox(width: 6),
                        if (duration != null)
                          Text(
                            '${formatDuration(duration)} min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8A8A),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                    const Text('Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Please enter title'
                                  : null,
                      decoration: const InputDecoration(
                        hintText: 'Name of the video',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTag,
                      items:
                          _tags
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _selectedTag = val),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Please select a category'
                                  : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Please enter description'
                                  : null,
                      decoration: const InputDecoration(
                        hintText: 'Description of the video',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _deleteVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA587E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
              ),
              child: Row(
                children: [
                  const Text('Delete', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  Iconify(svgTrash, color: Colors.white),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _updateVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E56C9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
              ),
              child: Row(
                children: const [
                  Text('Confirm', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Iconify(Ph.check_square_bold, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
