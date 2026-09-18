import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meeem_rider/core/constants/app_strings.dart';
import 'package:meeem_rider/presentation/modules/profile/views/delete_account_webview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}

  @override
  Future<void> reload() async {}
}

class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnProgress(void Function(int progress) onProgress) async {}

  @override
  Future<void> setOnPageStarted(void Function(String url) onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(void Function(String url) onPageFinished) async {}

  @override
  Future<void> setOnWebResourceError(
      void Function(WebResourceError error) onWebResourceError) async {}

  @override
  Future<void> setOnNavigationRequest(
      FutureOr<NavigationDecision> Function(NavigationRequest request)
          onNavigationRequest) async {}
}

class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(key: Key('mock_web_view_widget'));
  }
}

class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
      PlatformWebViewControllerCreationParams params) {
    return MockPlatformWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
      PlatformNavigationDelegateCreationParams params) {
    return MockPlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
      PlatformWebViewWidgetCreationParams params) {
    return MockPlatformWebViewWidget(params);
  }
}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() {
    WebViewPlatform.instance = MockWebViewPlatform();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (key == 'AssetManifest.bin' || key == 'AssetManifest.bin.json') {
        final manifest = <String, List<Object?>>{
          'google_fonts/Inter-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Regular.ttf'}
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
      return null;
    });
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('DeleteAccountWebView renders AppBar with title, refresh and open-in-browser actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: DeleteAccountWebView(),
      ),
    );

    await tester.pump();

    // Verify title from AppStrings.deleteAccount
    expect(find.text(AppStrings.deleteAccount), findsOneWidget);

    // Verify AppBar action icons
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byIcon(Icons.open_in_browser_rounded), findsOneWidget);

    // Verify mock web view widget renders
    expect(find.byKey(const Key('mock_web_view_widget')), findsOneWidget);

    // Tap refresh button to ensure callback executes cleanly
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
  });

  testWidgets('DeleteAccountWebView accepts custom title and URL parameters',
      (WidgetTester tester) async {
    const customTitle = 'Custom Account Deletion';
    const customUrl = 'https://www.meeemsl.com/delete-account';

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DeleteAccountWebView(
          title: customTitle,
          url: customUrl,
        ),
      ),
    );

    await tester.pump();

    expect(find.text(customTitle), findsOneWidget);
    expect(find.byKey(const Key('mock_web_view_widget')), findsOneWidget);
  });
}
