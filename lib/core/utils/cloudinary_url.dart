/// Cloudinary converts on delivery based on the URL's extension, so swapping
/// e.g. `.avif` for `.jpg` serves the same image as JPEG.
abstract final class CloudinaryUrl {
  /// Formats Flutter decodes on every platform. Others (AVIF, HEIC, TIFF…)
  /// fail on some platforms or files, e.g. Chrome rejects some AVIFs.
  static const Set<String> _flutterSafeFormats = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  };

  /// Returns a JPEG URL for Cloudinary images in formats Flutter can't
  /// reliably decode; any other URL is returned unchanged.
  static String deliverable(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.endsWith('cloudinary.com')) return url;

    final path = uri.path;
    final dot = path.lastIndexOf('.');
    if (dot <= path.lastIndexOf('/')) return url;

    final ext = path.substring(dot + 1).toLowerCase();
    if (_flutterSafeFormats.contains(ext)) return url;
    return uri.replace(path: '${path.substring(0, dot)}.jpg').toString();
  }
}
