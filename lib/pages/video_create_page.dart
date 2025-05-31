import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

final api = ApiService();

class VideoCreatePage extends StatefulWidget {
  final dynamic file; // File (mobile) or Uint8List (web)
  final String filename;

  const VideoCreatePage({
    super.key,
    required this.file,
    required this.filename,
  });

  @override
  State<VideoCreatePage> createState() => _VideoCreatePageState();
}

class _VideoCreatePageState extends State<VideoCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Uint8List? _thumbnailBytes;
  Duration? _videoDuration;

  String? _selectedTag;
  List<String> _tags = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchVideoTags();
    _generateThumbnailAndDuration();
  }

  Future<void> _fetchVideoTags() async {
    try {
      final tagResponse = await api.get('videos/tags');
      setState(() {
        _tags = List<String>.from(tagResponse);
        _selectedTag = _tags.isNotEmpty ? _tags.first : null;
      });
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  Future<void> _generateThumbnailAndDuration() async {
    try {
      if (kIsWeb) {
        final controller = VideoPlayerController.networkUrl(
          Uri.dataFromBytes(widget.file, mimeType: 'video/mp4'),
        );
        await controller.initialize();
        setState(() {
          _videoDuration = controller.value.duration;
        });
        await controller.dispose();
      } else {
        final bytes = await VideoThumbnail.thumbnailData(
          video: widget.file.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 320,
          maxWidth: 180,
          quality: 75,
        );

        final controller = VideoPlayerController.file(widget.file);
        await controller.initialize();
        setState(() {
          _thumbnailBytes = bytes;
          _videoDuration = controller.value.duration;
        });
        await controller.dispose();
      }
    } catch (e) {
      debugPrint("Failed to extract video info: $e");
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate() || _selectedTag == null) return;
    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('http://10.4.56.28:3000/api/videos');
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['title'] = _titleController.text
            ..fields['description'] = _descController.text
            ..fields['tag'] = _selectedTag!
            ..fields['user_id'] = AuthService().getUserId();

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'video',
            widget.file,
            filename: widget.filename,
            contentType: MediaType('video', 'mp4'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('video', widget.file.path),
        );
        if (_thumbnailBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'thumbnail',
              _thumbnailBytes!,
              filename: 'thumb.jpg',
            ),
          );
        }
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload successful')));
          Navigator.pop(context, true);
        }
      } else {
        debugPrint("Upload failed with status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload failed')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Upload Video',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
                    child:
                        _thumbnailBytes != null
                            ? Image.memory(
                              _thumbnailBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                            : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFormFields(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadVideo,
        label:
            _isUploading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text('Upload', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.upload, color: Colors.white),
        backgroundColor: const Color(0xFF6E56C9),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_videoDuration != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFF8A8A8A)),
                const SizedBox(width: 6),
                Text(
                  '${_videoDuration!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_videoDuration!.inSeconds.remainder(60).toString().padLeft(2, '0')} min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          const Text('Title'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            validator:
                (val) =>
                    val == null || val.isEmpty ? 'Please enter title' : null,
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
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (val) => setState(() => _selectedTag = val),
            validator:
                (val) =>
                    val == null || val.isEmpty
                        ? 'Please select a category'
                        : null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
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
    );
  }
}
