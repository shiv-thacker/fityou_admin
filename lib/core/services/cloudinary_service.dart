import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';
import 'image_compressor.dart';

/// Thrown when a Cloudinary upload fails (HTTP error or malformed response).
class CloudinaryUploadException implements Exception {
  final String message;
  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}

/// Thin client for unsigned, direct-from-app uploads to Cloudinary.
///
/// Every image is compressed locally first (see [ImageCompressor]) so a
/// ~2 MB phone photo becomes a lightweight ~300 KB JPEG *before* it ever
/// leaves the device — faster uploads, smaller storage, same look.
abstract final class CloudinaryService {
  /// Compresses [bytes] and uploads them into [folder] on Cloudinary.
  /// Returns the resulting `secure_url`.
  static Future<String> uploadImage({
    required Uint8List bytes,
    required String folder,
    String fileName = 'upload.jpg',
    int targetBytes = 300 * 1024,
  }) async {
    final compressed = ImageCompressor.compress(bytes, targetBytes: targetBytes);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(CloudinaryConfig.uploadUrl()),
    )
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        compressed,
        filename: fileName,
      ));

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } catch (e) {
      throw CloudinaryUploadException('Could not reach Cloudinary: $e');
    }
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw CloudinaryUploadException(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const CloudinaryUploadException(
        'Cloudinary returned an unexpected response.',
      );
    }

    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary response did not include a secure_url.',
      );
    }
    return url;
  }
}
