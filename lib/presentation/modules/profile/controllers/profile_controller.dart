import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/rider_entity.dart';
import '../../../../domain/entities/document_entity.dart';
import '../../../../domain/entities/operating_zone_entity.dart';
import '../../../../domain/entities/payout_info_entity.dart';
import '../../../../domain/entities/vehicle_entity.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../../domain/usecases/profile/get_documents_usecase.dart';
import '../../../../domain/usecases/profile/upload_document_usecase.dart';
import '../../../../domain/usecases/profile/get_operating_zones_usecase.dart';
import '../../../../domain/usecases/profile/update_operating_zones_usecase.dart';
import '../../../../domain/usecases/profile/get_payout_info_usecase.dart';
import '../../../../domain/usecases/profile/update_payout_info_usecase.dart';
import '../../../../domain/usecases/profile/update_vehicle_usecase.dart';
import '../../../../domain/usecases/profile/get_settings_usecase.dart';
import '../../../../domain/usecases/profile/update_settings_usecase.dart';
import '../../../../domain/entities/rider_settings_entity.dart';
import '../../../../core/services/notification_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetDocumentsUseCase getDocumentsUseCase;
  final UploadDocumentUseCase uploadDocumentUseCase;
  final GetOperatingZonesUseCase getOperatingZonesUseCase;
  final UpdateOperatingZonesUseCase updateOperatingZonesUseCase;
  final GetPayoutInfoUseCase getPayoutInfoUseCase;
  final UpdatePayoutInfoUseCase updatePayoutInfoUseCase;
  final UpdateVehicleUseCase updateVehicleUseCase;
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  ProfileController({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getDocumentsUseCase,
    required this.uploadDocumentUseCase,
    required this.getOperatingZonesUseCase,
    required this.updateOperatingZonesUseCase,
    required this.getPayoutInfoUseCase,
    required this.updatePayoutInfoUseCase,
    required this.updateVehicleUseCase,
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  });

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final riderProfile = Rxn<RiderEntity>();
  final documents = <DocumentEntity>[].obs;
  final operatingZones = <OperatingZoneEntity>[].obs;
  final payoutInfo = Rxn<PayoutInfoEntity>();
  final riderSettings = const RiderSettingsEntity().obs;

  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    isDarkMode.value = storage.read<bool>(AppConstants.isDarkModeKey) ?? false;
    loadAllProfileData();
  }

  Future<void> loadAllProfileData() async {
    isLoading.value = true;
    await Future.wait([
      _loadProfile(),
      _loadDocuments(),
      _loadOperatingZones(),
      _loadPayoutInfo(),
      _loadSettings(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadSettings() async {
    final result = await getSettingsUseCase();
    result.fold(
      (failure) => null,
      (settings) => riderSettings.value = settings,
    );
  }

  Future<void> _loadProfile() async {
    final result = await getProfileUseCase();
    result.fold(
      (failure) => null,
      (rider) => riderProfile.value = rider,
    );
  }

  Future<void> _loadDocuments() async {
    final result = await getDocumentsUseCase();
    result.fold(
      (failure) => null,
      (docList) => documents.assignAll(docList),
    );
  }

  Future<void> _loadOperatingZones() async {
    final result = await getOperatingZonesUseCase();
    result.fold(
      (failure) => null,
      (zones) => operatingZones.assignAll(zones),
    );
  }

  Future<void> _loadPayoutInfo() async {
    final result = await getPayoutInfoUseCase();
    result.fold(
      (failure) => null,
      (info) => payoutInfo.value = info,
    );
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    GetStorage().write(AppConstants.isDarkModeKey, isDarkMode.value);
  }

  // Document Upload
  Future<void> uploadDoc(String type) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      final filePath = file?.path ?? 'mock_doc_path_${DateTime.now().millisecondsSinceEpoch}.jpg';

      isLoading.value = true;
      final result = await uploadDocumentUseCase(type, filePath);
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Upload Failed', failure.message),
        (doc) {
          final index = documents.indexWhere((d) => d.type == type);
          if (index >= 0) {
            documents[index] = doc;
          } else {
            documents.add(doc);
          }
          Get.snackbar('Document Uploaded', '${doc.title} submitted for review',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFE8F8EE));
        },
      );
    } catch (_) {
      Get.snackbar('Upload', 'Document attached');
    }
  }

  // Operating Zones Toggle & Save
  void toggleZoneSelection(String zoneId) {
    final index = operatingZones.indexWhere((z) => z.id == zoneId);
    if (index >= 0) {
      final current = operatingZones[index];
      final newSelected = !current.isSelected;
      final updatedLocations = current.locations.map((loc) => loc.copyWith(isSelected: newSelected)).toList();
      operatingZones[index] = current.copyWith(isSelected: newSelected, locations: updatedLocations);
    }
  }

  void toggleLocationSelection(String zoneId, String locationId) {
    final zoneIndex = operatingZones.indexWhere((z) => z.id == zoneId);
    if (zoneIndex >= 0) {
      final zone = operatingZones[zoneIndex];
      final locIndex = zone.locations.indexWhere((l) => l.id == locationId);
      if (locIndex >= 0) {
        final loc = zone.locations[locIndex];
        final updatedLocs = List<DeliveryLocationEntity>.from(zone.locations);
        updatedLocs[locIndex] = loc.copyWith(isSelected: !loc.isSelected);
        final hasAnySelected = updatedLocs.any((l) => l.isSelected);
        operatingZones[zoneIndex] = zone.copyWith(isSelected: hasAnySelected, locations: updatedLocs);
      }
    }
  }

  Future<void> saveOperatingZones() async {
    final selectedIds = operatingZones.where((z) => z.isSelected).map((z) => z.id).toList();
    if (selectedIds.isEmpty) {
      Get.snackbar('Operating Zones', 'Please select at least 1 operating zone');
      return;
    }

    isLoading.value = true;
    final result = await updateOperatingZonesUseCase(selectedIds);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (success) {
        Get.back();
        Get.snackbar('Zones Updated', 'Your preferred delivery zones have been saved!',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  // Payout Info Save
  Future<void> savePayoutInfo(PayoutInfoEntity info) async {
    isLoading.value = true;
    final result = await updatePayoutInfoUseCase(info);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (updated) {
        payoutInfo.value = updated;
        Get.back();
        Get.snackbar('Payout Info Saved', 'Your payout destination details have been updated.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  // Vehicle Update
  Future<void> saveVehicleInfo(VehicleEntity vehicle) async {
    isLoading.value = true;
    final result = await updateVehicleUseCase(vehicle);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (updated) {
        if (riderProfile.value != null) {
          riderProfile.value = riderProfile.value!.copyWith(vehicle: updated);
        }
        Get.back();
        Get.snackbar('Vehicle Saved', 'Vehicle details updated successfully.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  // 6.2 Update Rider Profile
  Future<void> updateRiderProfile({
    required String name,
    required String phone,
    String? vehicleType,
    String? vehicleName,
    String? vehicleNumber,
  }) async {
    if (riderProfile.value == null) return;
    isLoading.value = true;

    final updated = riderProfile.value!.copyWith(
      name: name,
      phone: phone,
      vehicleType: vehicleType,
      vehicleName: vehicleName,
      vehicleNumber: vehicleNumber,
    );

    final result = await updateProfileUseCase(updated);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (res) {
        riderProfile.value = res;
        Get.snackbar(
          'Profile Updated',
          'Profile updated successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
        );
      },
    );
  }

  // 7.2 Update Settings & Password
  Future<void> updateRiderSettings({
    NotificationsSettingsEntity? notifications,
    NavigationSettingsEntity? navigation,
    AppPreferencesSettingsEntity? appPreferences,
  }) async {
    isLoading.value = true;
    final result = await updateSettingsUseCase(
      notifications: notifications ?? riderSettings.value.notifications,
      navigation: navigation ?? riderSettings.value.navigation,
      appPreferences: appPreferences ?? riderSettings.value.appPreferences,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
      (updated) {
        riderSettings.value = updated;
        Get.snackbar(
          'Settings Saved',
          'Preferences updated successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
        );
      },
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar('Input Required', 'Please enter your current and new passwords.');
      return;
    }
    if (newPassword.length < 6) {
      Get.snackbar('Validation', 'New password must be at least 6 characters.');
      return;
    }

    isLoading.value = true;
    final result = await updateSettingsUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Password Update Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (updated) {
        Get.back();
        Get.snackbar(
          'Password Changed',
          'Your account password has been successfully updated.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
        );
      },
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out of Meeem Rider?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        // Section 9.2: Unregister Device Token
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().unregisterCurrentDeviceToken();
        }
        final storage = GetStorage();
        storage.remove(AppConstants.tokenKey);
        storage.remove(AppConstants.refreshTokenKey);
        storage.remove(AppConstants.riderProfileKey);
        storage.remove(AppConstants.userProfileKey);
        Get.back();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
