import 'dart:io';
import 'dart:typed_data';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  String? _selectedCategory;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchVideoTags();
    _titleController.text = widget.video['title'] ?? '';
    _descController.text = widget.video['description'] ?? '';
    _selectedCategory = widget.video['tag'];
  }

  Future<void> _updateVideo() async {
    await api.put('videos', {
      "tag": _selectedCategory,
      "title": _titleController,
      "description": _descController,
    });
  }

  Future<void> _fetchVideoTags() async {
    try {
      final tagResponse = await api.get('videos/tags');
      setState(() {
        _tags = List<String>.from(tagResponse);
        _selectedCategory = _tags.isNotEmpty ? _tags.first : null;
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
          leading: const BackButton(color: Colors.white),
          centerTitle: true,
          title: const Text(
            'Video Details',
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
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
                      value: _selectedCategory,
                      items:
                          _tags
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => _selectedCategory = val),
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
