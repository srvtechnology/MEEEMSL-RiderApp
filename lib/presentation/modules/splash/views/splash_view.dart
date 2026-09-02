import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  VideoPlayerController? _controller;
  bool _hasNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    // Initial fallback timer in case initialization hangs
    _fallbackTimer = Timer(const Duration(seconds: 10), () {
      _navigate();
    });

    try {
      _controller = VideoPlayerController.asset('assets/logo/splash.mp4');
      await _controller!.initialize();
      _controller!.setLooping(false);

      final videoDuration = _controller!.value.duration;
      // Re-set safety fallback timer based on actual video duration + 1.5s margin
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(videoDuration + const Duration(milliseconds: 1500), () {
        _navigate();
      });

      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {});
        await _controller!.play();
      }
    } catch (e) {
      // If video initialization fails, navigate immediately
      _navigate();
    }
  }

  void _videoListener() {
    if (_controller == null || _hasNavigated) return;
    final value = _controller!.value;
    if (value.hasError) {
      _navigate();
    } else if (value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= (value.duration - const Duration(milliseconds: 300))) {
      _navigate();
    }
  }

  Future<void> _navigate() async {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();

    if (!mounted) return;

    final controller = Get.find<SplashController>();
    controller.navigateToNextScreen();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: (_controller != null && _controller!.value.isInitialized)
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            : Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/logo/logo-icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
      ),
    );
  }
}

