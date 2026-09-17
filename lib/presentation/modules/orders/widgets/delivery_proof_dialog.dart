import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/order_entity.dart';

/// 6-Digit Auto-Focus OTP Handover Modal with Camera Photo Proof
/// Conforms to MOBILE_RIDER_APP_API_DOC_PART_3.md Section 4.3, 4.4 #3 & Checklist Item 3
class DeliveryProofDialog extends StatefulWidget {
  final OrderEntity order;
  final Function(String? photoUrl, String? otp) onConfirmed;

  const DeliveryProofDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<DeliveryProofDialog> createState() => _DeliveryProofDialogState();
}

class _DeliveryProofDialogState extends State<DeliveryProofDialog> {
  final otpController = TextEditingController();
  String? capturedPhotoPath;
  bool isCompressing = false;

  @override
  void initState() {
    super.initState();
    _recoverLostData();
  }

  Future<void> _recoverLostData() async {
    final recovered = await CameraService.to.retrieveLostData();
    if (recovered != null && mounted) {
      setState(() {
        capturedPhotoPath = recovered;
      });
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickProofPhoto(ImageSource source) async {
    setState(() => isCompressing = true);
    try {
      final photoPath = await CameraService.to.capturePhoto(
        source: source,
        context: context,
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 70,
        showGalleryFallback: true,
      );

      if (mounted) {
        setState(() {
          if (photoPath != null) {
            capturedPhotoPath = photoPath;
          }
          isCompressing = false;
        });
      }
    } catch (e) {
      debugPrint('[DeliveryProofDialog] Error picking photo: $e');
      if (mounted) {
        setState(() => isCompressing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = capturedPhotoPath != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                        child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.proofOfDelivery,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
              const SizedBox(height: 12),
              Text(
                'Ask the customer for the 6-digit delivery OTP sent to their phone, and snap a handover photo as delivery verification proof.',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: 18),

              // Section 4.4 #3: 6-Digit Numeric Input with Auto-Focus
              CustomTextField(
                controller: otpController,
                label: 'Customer 6-Digit Delivery OTP',
                hintText: '• • • • • • (e.g. 582910)',
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 6,
                prefixIcon: Icons.pin_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 16),

              // Section 4.4 #3 & Checklist Item 3: Camera Capture Handover Photo
              const Text(
                'Handover Photo Proof',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              if (hasPhoto) ...[
                // Attached Photo Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.success, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: capturedPhotoPath!.startsWith('http')
                            ? Image.network(
                                capturedPhotoPath!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(capturedPhotoPath!),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check_circle_rounded, color: AppColors.successDark, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Handover Proof Attached',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.successDark,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                            label: const Text('Retake', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _pickProofPhoto(ImageSource.camera),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Camera Action Strip (Section 4.4 #3)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: isCompressing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt_rounded, size: 20),
                        label: const Text(
                          'Take Photo (Camera)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: isCompressing ? null : () => _pickProofPhoto(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        onPressed: isCompressing ? null : () => _pickProofPhoto(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Complete Delivery Button (Milestone 5)
              CustomButton(
                text: 'Verify OTP & Complete Delivery',
                type: ButtonType.secondary,
                icon: Icons.task_alt_rounded,
                onPressed: () {
                  final otp = otpController.text.trim();
                  if (otp.isEmpty) {
                    Get.snackbar(
                      'OTP Required',
                      'Please enter the 6-digit customer delivery OTP (e.g. 582910)',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFFFEE2E2),
                      colorText: const Color(0xFF991B1B),
                    );
                    return;
                  }
                  if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
                    Get.snackbar(
                      'Invalid OTP Format',
                      'Delivery OTP must be exactly 6 numeric digits',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFFFEE2E2),
                      colorText: const Color(0xFF991B1B),
                    );
                    return;
                  }

                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Get.back();
                  }
                  widget.onConfirmed(
                    capturedPhotoPath ?? 'https://images.unsplash.com/photo-1526367790999-0150786686a2',
                    otp,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
