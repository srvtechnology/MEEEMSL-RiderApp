import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/utils/image_compressor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageCompressor Tests', () {
    test('returns empty string when given null or empty filePath', () async {
      expect(await ImageCompressor.compressImage(null), '');
      expect(await ImageCompressor.compressImage(''), '');
    });

    test('returns original URL for remote network images without compressing', () async {
      const url = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';
      expect(await ImageCompressor.compressImage(url), url);
    });

    test('returns original path for PDF documents without error', () async {
      const pdfPath = '/storage/emulated/0/Download/document.pdf';
      expect(await ImageCompressor.compressImage(pdfPath), pdfPath);
    });

    test('returns original path if file does not exist', () async {
      const nonExistent = '/invalid/path/non_existent_image.jpg';
      expect(await ImageCompressor.compressImage(nonExistent), nonExistent);
    });
  });
}
