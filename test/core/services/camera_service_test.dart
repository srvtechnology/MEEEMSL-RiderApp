import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/services/camera_service.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockImagePicker mockImagePicker;
  late CameraService cameraService;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(CameraDevice.rear);
  });

  setUp(() {
    Get.reset();
    mockImagePicker = MockImagePicker();
    cameraService = CameraService(picker: mockImagePicker);
    Get.put<CameraService>(cameraService);
  });

  tearDown(() {
    Get.reset();
  });

  group('CameraService Tests', () {
    test('CameraService.to returns registered instance', () {
      expect(CameraService.to, isA<CameraService>());
      expect(identical(CameraService.to, cameraService), isTrue);
    });

    test('capturePhoto returns null when picker returns null (user cancels)', () async {
      when(() => mockImagePicker.pickImage(
            source: any(named: 'source'),
            preferredCameraDevice: any(named: 'preferredCameraDevice'),
          )).thenAnswer((_) async => null);

      final result = await cameraService.capturePhoto(
        source: ImageSource.gallery,
      );

      expect(result, isNull);
    });

    test('pickMultiplePhotos returns empty list if maxPhotos <= 0', () async {
      final result = await cameraService.pickMultiplePhotos(maxPhotos: 0);
      expect(result, isEmpty);
    });

    test('pickMultiplePhotos returns empty list when picker returns empty', () async {
      when(() => mockImagePicker.pickMultiImage(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      final result = await cameraService.pickMultiplePhotos(maxPhotos: 3);
      expect(result, isEmpty);
    });
  });
}
