import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/courier_request/courier_request_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/courier_request/courier_request_event.dart';

class MediaSection extends StatelessWidget {
  final List<String> attachments;
  const MediaSection({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _mediaButton(context, Icons.camera_alt, 'Камера', () => _showMediaSourceDialog(context, ImageSource.camera)),
            const SizedBox(width: 10),
            _mediaButton(context, Icons.photo_library, 'Галерея', () => _showMediaSourceDialog(context, ImageSource.gallery)),
            const SizedBox(width: 10),
            _mediaButton(context, Icons.file_upload, 'Файл', () => _uploadFile(context)),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Загруженные файлы:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final file = File(attachments[index]);
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildFilePreview(file),
                    ),
                    Positioned(
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          context.read<CourierRequestBloc>().add(RemoveAttachment(file.path));
                        },
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _mediaButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  void _showMediaSourceDialog(BuildContext context, ImageSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тип'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Фото'),
              onTap: () {
                Navigator.of(context).pop();
                _pickMedia(context, source, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Видео'),
              onTap: () {
                Navigator.of(context).pop();
                _pickMedia(context, source, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(BuildContext context, ImageSource source, bool isVideo) async {
    final picker = ImagePicker();
    XFile? file = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);
    if (file != null && context.mounted) {
      context.read<CourierRequestBloc>().add(AddAttachment(file.path));
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && context.mounted) {
      context.read<CourierRequestBloc>().add(AddAttachment(result.files.single.path!));
    }
  }

  Widget _buildFilePreview(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
      return _fileContainer(Icons.videocam, ext);
    } else {
      return _fileContainer(Icons.insert_drive_file, ext);
    }
  }

  Widget _fileContainer(IconData icon, String ext) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          Text('.$ext', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
