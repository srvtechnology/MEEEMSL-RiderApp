import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  /// Compresses an image file at [filePath] to be lightweight (< 350KB).
  ///
  /// Returns the path to the compressed file.
  /// If compression is unnecessary, unsupported, or fails, gracefully returns [filePath].
  static Future<String> compressImage(
    String? filePath, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int targetMaxBytes = 350 * 1024,
  }) async {
    if (filePath == null || filePath.isEmpty || filePath.startsWith('http')) {
      return filePath ?? '';
    }

    final lower = filePath.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return filePath;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      return filePath;
    }

    try {
      final initialSize = await file.length();
      if (initialSize <= targetMaxBytes) {
        return filePath;
      }

      final tempDir = await getTemporaryDirectory();
      final baseName = file.uri.pathSegments.last
          .replaceAll(RegExp(r'\.(png|jpeg|jpg|webp|heic)$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final targetPath = '${tempDir.path}/comp_${DateTime.now().millisecondsSinceEpoch}_$baseName.jpg';

      // Pass 1: Standard compression
      final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressed != null) {
        final compressedFile = File(compressed.path);
        if (await compressedFile.exists()) {
          final size = await compressedFile.length();

          // Pass 2: If still exceeds targetMaxBytes, compress further
          if (size > targetMaxBytes) {
            final targetPath2 = '${tempDir.path}/comp2_${DateTime.now().millisecondsSinceEpoch}_$baseName.jpg';
            final XFile? compressed2 = await FlutterImageCompress.compressAndGetFile(
              compressedFile.absolute.path,
              targetPath2,
              quality: 50,
              minWidth: (maxWidth * 0.75).toInt(),
              minHeight: (maxHeight * 0.75).toInt(),
              format: CompressFormat.jpeg,
            );

            if (compressed2 != null) {
              final file2 = File(compressed2.path);
              if (await file2.exists() && await file2.length() < size) {
                return compressed2.path;
              }
            }
          }

          if (size < initialSize) {
            return compressed.path;
          }
        }
      }
    } catch (e) {
      debugPrint('[ImageCompressor] Note: Falling back to original path: $e');
    }

    return filePath;
  }

  /// Converts a local image file at [filePath] into a Base64 Data URI
  /// conforming to MOBILE_RIDER_APP_API_DOC_PART_3.md Section 4.3:
  /// `"data:image/jpeg;base64,..."`
  static Future<String> fileToBase64DataUri(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return '';
    if (filePath.startsWith('http') || filePath.startsWith('data:')) {
      return filePath;
    }
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }
    } catch (e) {
      debugPrint('[ImageCompressor] Failed to encode image to base64: $e');
    }
    return filePath;
  }
}
