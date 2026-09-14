import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../domain/entities/order_entity.dart';

/// Package Pickup Proof Modal
/// Allows capturing 1 to 5 photos (parcel sealed, shipping label, packaging condition)
/// Conforms to MOBILE_RIDER_AND_SELLER_PACKAGE_PICKUP_AND_DISPATCH_API_DOC.md Part 1
class PickupProofDialog extends StatefulWidget {
  final OrderEntity order;
  final Function(List<String> photoPaths) onConfirmed;

  const PickupProofDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<PickupProofDialog> createState() => _PickupProofDialogState();
}

class _PickupProofDialogState extends State<PickupProofDialog> {
  final _picker = ImagePicker();
  final List<String> _capturedPhotos = [];
  bool _isCompressing = false;
  bool _isSubmitting = false;
  static const int _minPhotos = 2;
  static const int _maxPhotos = 5;

  Future<void> _pickSingleImage(ImageSource source) async {
    if (_capturedPhotos.length >= _maxPhotos) {
      Get.snackbar(
        'Maximum Photos Reached',
        'You can upload up to $_maxPhotos pickup proof photos.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      setState(() => _isCompressing = true);
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );
      if (photo != null) {
        final compressed = await ImageCompressor.compressImage(
          photo.path,
          maxWidth: 1200,
          maxHeight: 1200,
          quality: 75,
        );
        setState(() {
          _capturedPhotos.add(compressed);
          _isCompressing = false;
        });
      } else {
        setState(() => _isCompressing = false);
      }
    } catch (e) {
      debugPrint('[PickupProofDialog] Error picking image: $e');
      setState(() => _isCompressing = false);
    }
  }

  Future<void> _pickMultiFromGallery() async {
    final remaining = _maxPhotos - _capturedPhotos.length;
    if (remaining <= 0) {
      Get.snackbar(
        'Maximum Photos Reached',
        'You can upload up to $_maxPhotos pickup proof photos.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      setState(() => _isCompressing = true);
      final List<XFile> pickedList = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
        limit: remaining,
      );

      if (pickedList.isNotEmpty) {
        for (final xfile in pickedList.take(remaining)) {
          final compressed = await ImageCompressor.compressImage(
            xfile.path,
            maxWidth: 1200,
            maxHeight: 1200,
            quality: 75,
          );
          _capturedPhotos.add(compressed);
        }
      }
      setState(() => _isCompressing = false);
    } catch (e) {
      debugPrint('[PickupProofDialog] Error picking multi-images: $e');
      setState(() => _isCompressing = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoCount = _capturedPhotos.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Package Pickup Proof',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            widget.order.orderNumber.startsWith('#')
                                ? widget.order.orderNumber
                                : '#${widget.order.orderNumber}',
                            style: AppTextStyles.labelSmall(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () {
                      if (Navigator.of(context, rootNavigator: true).canPop()) {
                        Navigator.of(context, rootNavigator: true).pop();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                'Please capture at least 2 photos (up to 5) showing the sealed parcel, shipping label, and packaging condition before confirming collection from the store.',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: 14),

              // Photo counter pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Captured Photos ($photoCount/$_maxPhotos)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: photoCount >= _minPhotos
                          ? AppColors.successLight
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      photoCount >= _minPhotos
                          ? '$photoCount added'
                          : (photoCount == 0 ? 'Min $_minPhotos required' : '1 more required'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: photoCount >= _minPhotos
                            ? AppColors.successDark
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Thumbnails display
              if (photoCount > 0) ...[
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoCount,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final path = _capturedPhotos[index];
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 88,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: path.startsWith('http')
                                  ? Image.network(path, fit: BoxFit.cover)
                                  : Image.file(File(path), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 13, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(160),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textTertiaryLight),
                      SizedBox(height: 6),
                      Text(
                        'No photos captured yet',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Minimum 2 photos required to confirm pickup',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Camera and Gallery buttons
              if (photoCount < _maxPhotos) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        key: const Key('pickup_proof_camera_button'),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isCompressing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(
                          photoCount == 0 ? 'Take Photo' : 'Add More (Camera)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        onPressed: (_isCompressing || _isSubmitting) ? null : () => _pickSingleImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        key: const Key('pickup_proof_gallery_button'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.photo_library_outlined, size: 17),
                        label: const Text(
                          'Gallery',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        onPressed: (_isCompressing || _isSubmitting) ? null : _pickMultiFromGallery,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // Confirm and Submit Button
              CustomButton(
                key: const Key('pickup_proof_confirm_button'),
                text: 'Confirm Pickup & Upload Photos',
                type: ButtonType.secondary,
                icon: Icons.check_circle_rounded,
                isLoading: _isCompressing || _isSubmitting,
                onPressed: (_isCompressing || _isSubmitting)
                    ? null
                    : () async {
                        if (_capturedPhotos.length < _minPhotos) {
                          Get.snackbar(
                            'Minimum 2 Photos Required',
                            'Please capture at least 2 photos (e.g. sealed parcel & shipping label) before confirming pickup.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: const Color(0xFFFEE2E2),
                            colorText: const Color(0xFF991B1B),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        try {
                          final res = await widget.onConfirmed(List.from(_capturedPhotos));
                          final isSuccess = res is bool ? res : true;
                          if (!context.mounted) return;
                          if (isSuccess) {
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Get.back();
                            }
                          }
                        } catch (e) {
                          debugPrint('[PickupProofDialog] Error confirming pickup: $e');
                        } finally {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
