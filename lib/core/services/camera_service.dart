import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import '../utils/image_compressor.dart';

/// Centralized robust Camera & Media Service.
/// Handles Android 11+ package visibility, runtime permissions,
/// Activity recreation / lost data recovery, and crash-resilient compression.
class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static CameraService get to {
    if (Get.isRegistered<CameraService>()) {
      return Get.find<CameraService>();
    }
    return Get.put<CameraService>(CameraService(), permanent: true);
  }

  /// Checks and requests camera runtime permission.
  /// If permanently denied, presents a dialog guiding the user to App Settings.
  Future<bool> checkAndRequestCameraPermission({
    BuildContext? context,
    bool showSettingsDialog = true,
  }) async {
    try {
      final status = await Permission.camera.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isDenied) {
        final requestResult = await Permission.camera.request();
        if (requestResult.isGranted || requestResult.isLimited) {
          return true;
        }
        if (requestResult.isPermanentlyDenied && showSettingsDialog) {
          _showPermissionSettingsDialog(context);
          return false;
        }
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        if (showSettingsDialog) {
          _showPermissionSettingsDialog(context);
        }
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('[CameraService] Permission check error: $e');
      // On platforms/devices where permission_handler is unsupported, attempt to proceed
      return true;
    }
  }

  /// Displays a user-friendly dialog when camera permission is permanently denied.
  void _showPermissionSettingsDialog(BuildContext? context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Camera Access Required',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Camera permission is needed to take proof photos. Please enable camera access in your device settings, or select a photo from your gallery.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Captures a single photo from camera or gallery with permission checks and safe compression.
  /// Avoids in-plugin native bitmap scaling to prevent OutOfMemory crashes on high-megapixel cameras.
  Future<String?> capturePhoto({
    ImageSource source = ImageSource.camera,
    BuildContext? context,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 70,
    bool showGalleryFallback = true,
  }) async {
    // 1. Check runtime permission for Camera
    if (source == ImageSource.camera) {
      final hasPermission = await checkAndRequestCameraPermission(context: context);
      if (!hasPermission) {
        return null;
      }
    }

    // 2. Launch Image Picker
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (file != null) {
        return await ImageCompressor.compressImage(
          file.path,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
      }

      // 3. If null on Android, check if MainActivity was killed during camera session
      if (Platform.isAndroid && source == ImageSource.camera) {
        final lostPath = await retrieveLostData(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
        if (lostPath != null) {
          return lostPath;
        }
      }

      return null;
    } on PlatformException catch (e) {
      debugPrint('[CameraService] PlatformException picking image: ${e.code} - ${e.message}');
      if (e.code == 'camera_access_denied') {
        _showPermissionSettingsDialog(context);
      } else {
        _notifyFailureAndOfferGallery(
          message: 'Unable to open camera on this device.',
          onPickGallery: showGalleryFallback
              ? () => capturePhoto(
                    source: ImageSource.gallery,
                    context: context,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    quality: quality,
                    showGalleryFallback: false,
                  )
              : null,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[CameraService] Unexpected error picking image: $e');
      _notifyFailureAndOfferGallery(
        message: 'Could not access camera. Please try gallery instead.',
        onPickGallery: showGalleryFallback
            ? () => capturePhoto(
                  source: ImageSource.gallery,
                  context: context,
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  quality: quality,
                  showGalleryFallback: false,
                )
            : null,
      );
      return null;
    }
  }

  /// Recovers image data if Android OS killed the MainActivity while camera was active.
  Future<String?> retrieveLostData({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 70,
  }) async {
    if (!Platform.isAndroid) return null;

    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;

      if (response.file != null) {
        debugPrint('[CameraService] Successfully retrieved lost camera photo: ${response.file!.path}');
        return await ImageCompressor.compressImage(
          response.file!.path,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
      }

      if (response.exception != null) {
        debugPrint('[CameraService] LostDataResponse exception: ${response.exception}');
      }
    } catch (e) {
      debugPrint('[CameraService] Error checking lost data: $e');
    }
    return null;
  }

  /// Picks multiple images from gallery with limits and compression.
  Future<List<String>> pickMultiplePhotos({
    int maxPhotos = 5,
    int maxWidth = 1200,
    int maxHeight = 1200,
    int quality = 75,
  }) async {
    if (maxPhotos <= 0) return [];

    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        limit: maxPhotos,
      );

      if (picked.isEmpty) return [];

      final List<String> compressedPaths = [];
      for (final xfile in picked.take(maxPhotos)) {
        final compressed = await ImageCompressor.compressImage(
          xfile.path,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
        compressedPaths.add(compressed);
      }
      return compressedPaths;
    } catch (e) {
      debugPrint('[CameraService] Error in pickMultiplePhotos: $e');
      Get.snackbar(
        'Gallery Notice',
        'Could not load selected images. Please try again.',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  /// Informs rider of failure with optional action to switch to Gallery
  void _notifyFailureAndOfferGallery({
    required String message,
    Future<String?> Function()? onPickGallery,
  }) {
    Get.snackbar(
      'Camera Notice',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFFF3CD),
      colorText: const Color(0xFF856404),
      icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404)),
      duration: const Duration(seconds: 4),
      mainButton: onPickGallery != null
          ? TextButton(
              onPressed: () async {
                Get.closeCurrentSnackbar();
                await onPickGallery();
              },
              child: const Text(
                'Use Gallery',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            )
          : null,
    );
  }
}
