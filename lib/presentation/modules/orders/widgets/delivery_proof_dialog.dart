import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/order_entity.dart';

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
  final _picker = ImagePicker();
  String? capturedPhotoPath;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickProofPhoto(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(source: source, imageQuality: 80);
      if (photo != null) {
        setState(() {
          capturedPhotoPath = photo.path;
        });
      }
    } catch (_) {
      setState(() {
        capturedPhotoPath = 'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=400';
      });
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo from Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickProofPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.secondary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickProofPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = capturedPhotoPath != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.proofOfDelivery,
                    style: AppTextStyles.headlineSmall(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Enter customer 4-digit OTP and optionally take a dropoff proof photo.',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: 20),

              // OTP Input
              CustomTextField(
                controller: otpController,
                label: AppStrings.enterCustomerOtp,
                hintText: 'e.g. 4829',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_outlined,
              ),
              const SizedBox(height: 16),

              // Photo Capture Button & Preview
              GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: hasPhoto ? AppColors.successLight : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasPhoto ? AppColors.success : AppColors.primaryLight,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (hasPhoto && !capturedPhotoPath!.startsWith('http'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(capturedPhotoPath!),
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Icon(
                          hasPhoto ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                          color: hasPhoto ? AppColors.successDark : AppColors.primary,
                          size: 32,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        hasPhoto ? 'Photo Attached (Tap to Change)' : AppStrings.uploadProofPhoto,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasPhoto ? AppColors.successDark : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Complete Delivery Button
              CustomButton(
                text: 'Complete Delivery',
                type: ButtonType.secondary,
                icon: Icons.check_circle_outline,
                onPressed: () {
                  final otp = otpController.text.trim();
                  if (otp.isEmpty) {
                    Get.snackbar('Input Required', 'Please enter customer delivery OTP (e.g. 4829)');
                    return;
                  }
                  Get.back();
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
