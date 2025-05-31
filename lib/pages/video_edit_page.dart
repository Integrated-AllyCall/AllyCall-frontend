import 'package:allycall/services/api_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:flutter/material.dart';

final api = ApiService();

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
    _descController.text = widget.video['description'] ?? 'No description provided.';
    _selectedTag = widget.video['tag'];
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateVideo,
        label: const Text('Confirm', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: const Color(0xFF6E56C9),
      ),
    );
  }
}
