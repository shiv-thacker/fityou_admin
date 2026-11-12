import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_size.dart';
import '../services/cloudinary_service.dart';
import '../utils/cloudinary_url.dart';

/// Form field for an outfit/model/product image.
///
/// Lets the admin either:
///  • tap "Upload image" to pick a local file, which is compressed
///    (see [CloudinaryService]) and uploaded straight into [folder] on
///    Cloudinary, or
///  • paste a ready-made URL directly into the text field.
///
/// Either way the resulting URL ends up in [controller], which the parent
/// form already reads from on submit — no other wiring required.
class ImageUploadField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String folder;
  final bool required;

  const ImageUploadField({
    super.key,
    required this.controller,
    required this.label,
    required this.folder,
    this.required = false,
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  Future<void> _pickAndUpload() async {
    setState(() => _error = null);

    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final picked = files.first;
    final bytes = await picked.readAsBytes();

    setState(() => _uploading = true);
    try {
      final url = await CloudinaryService.uploadImage(
        bytes: bytes,
        folder: widget.folder,
        fileName: picked.name,
      );
      widget.controller.text = url;
    } catch (e) {
      setState(() => _error = 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumbnail(
          url: widget.controller.text,
          uploading: _uploading,
          onTap: _uploading ? null : _pickAndUpload,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.controller,
                style: const TextStyle(color: AppColors.textLight),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: 'Paste a URL, or upload a file below',
                  prefixIcon: const Icon(Icons.image_outlined,
                      color: AppColors.textMuted, size: 18),
                ),
                validator: widget.required
                    ? (v) => (v == null || v.trim().isEmpty)
                        ? 'At least one image is required'
                        : null
                    : null,
              ),
              const SizedBox(height: 2),
              TextButton.icon(
                onPressed: _uploading ? null : _pickAndUpload,
                icon: _uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent),
                      )
                    : const Icon(Icons.upload_outlined, size: 16),
                label: Text(_uploading
                    ? 'Compressing & uploading…'
                    : 'Upload image'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 11)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  final bool uploading;
  final VoidCallback? onTap;

  const _Thumbnail({required this.url, required this.uploading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.radiusSm),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSize.radiusSm),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.trim().isNotEmpty)
              Image.network(
                CloudinaryUrl.deliverable(url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted),
              )
            else
              const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.textMuted),
            if (uploading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
