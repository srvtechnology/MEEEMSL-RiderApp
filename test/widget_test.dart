import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meeem_rider/app.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/data/datasources/auth_local_datasource.dart';
import 'package:meeem_rider/presentation/modules/splash/views/splash_view.dart';

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (key == 'AssetManifest.bin' || key == 'AssetManifest.bin.json') {
        final manifest = <String, List<Object?>>{
          'google_fonts/Inter-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Regular.ttf'}
          ],
          'google_fonts/Inter-Medium.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Medium.ttf'}
          ],
          'google_fonts/Inter-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-SemiBold.ttf'}
          ],
          'google_fonts/Inter-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Bold.ttf'}
          ],
          'google_fonts/Poppins-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Regular.ttf'}
          ],
          'google_fonts/Poppins-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-SemiBold.ttf'}
          ],
          'google_fonts/Poppins-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Bold.ttf'}
          ],
        };
        return const StandardMessageCodec().encodeMessage(manifest);
      }
      if (key == 'AssetManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
      }
      if (key == 'FontManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
      }
      if (key.endsWith('.ttf')) {
        return ByteData.view(Uint8List.fromList(_fontBytes).buffer);
      }
      if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg') || key.endsWith('.mp4')) {
        return ByteData.view(Uint8List.fromList(_kTransparentImage).buffer);
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.io/videoPlayer'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'init') return null;
        if (methodCall.method == 'create') return {'textureId': 0};
        return null;
      },
    );
    await GetStorage.init();
    final storage = GetStorage();
    Get.put<GetStorage>(storage, permanent: true);
    Get.put<DioClient>(DioClient(), permanent: true);
    Get.put<AuthLocalDataSource>(AuthLocalDataSourceImpl(storage), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MeeemRiderApp());
    expect(find.byType(SplashView), findsOneWidget);
  });
}
