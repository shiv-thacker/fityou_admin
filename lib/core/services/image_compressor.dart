import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Compresses raw image bytes for upload while keeping the picture looking
/// as close to the original as possible.
///
/// Pure-Dart (no native/platform bindings), so it works identically on
/// Flutter Web and desktop/mobile.
///
/// Strategy:
///  1. Decode the source image.
///  2. Downscale if its longest edge exceeds [maxDimension]. Oversized
///     pixel dimensions are the main reason phone photos are multiple MB —
///     fixing that first preserves visual quality far better than only
///     crushing JPEG quality.
///  3. Re-encode as JPEG, stepping quality down from [_startQuality] until
///     the result fits under [targetBytes] (or [_minQuality] is reached).
abstract final class ImageCompressor {
  static const int _defaultMaxDimension = 1600;
  static const int _startQuality = 90;
  static const int _minQuality = 40;
  static const int _qualityStep = 5;

  /// Compresses [bytes] down to roughly [targetBytes] (default ~300 KB).
  ///
  /// Returns the original [bytes] unchanged if they can't be decoded as a
  /// raster image, or if compression somehow didn't shrink the file.
  static Uint8List compress(
    Uint8List bytes, {
    int targetBytes = 300 * 1024,
    int maxDimension = _defaultMaxDimension,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    img.Image working = decoded;
    final longestEdge =
        working.width > working.height ? working.width : working.height;

    if (longestEdge > maxDimension) {
      working = working.width >= working.height
          ? img.copyResize(working, width: maxDimension)
          : img.copyResize(working, height: maxDimension);
    }

    Uint8List best = Uint8List.fromList(
      img.encodeJpg(working, quality: _startQuality),
    );

    int quality = _startQuality;
    while (best.length > targetBytes && quality > _minQuality) {
      quality -= _qualityStep;
      best = Uint8List.fromList(img.encodeJpg(working, quality: quality));
    }

    // Guard against the rare case where re-encoding ends up bigger than
    // the original (e.g. a tiny, already well-optimized source image).
    return best.length < bytes.length ? best : bytes;
  }
}
