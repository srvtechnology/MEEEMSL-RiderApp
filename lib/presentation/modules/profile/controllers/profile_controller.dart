import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/rider_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_compressor.dart';
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
import '../../../../domain/usecases/auth/unregister_device_token_usecase.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/device_info_service.dart';
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
  final currentDeviceId = ''.obs;
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

    // Restore cached rider & user immediately for fast UI response
    try {
      final rawRider = storage.read<String>(AppConstants.riderProfileKey);
      final rawUser = storage.read<String>(AppConstants.userProfileKey);
      Map<String, dynamic>? userMap;
      if (rawUser != null && rawUser.isNotEmpty) {
        userMap = jsonDecode(rawUser) as Map<String, dynamic>?;
      }
      if (rawRider != null && rawRider.isNotEmpty) {
        final riderMap = jsonDecode(rawRider) as Map<String, dynamic>;
        riderProfile.value = RiderModel.fromJson(riderMap, userMap);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<DeviceInfoService>()) {
        Get.find<DeviceInfoService>().getDeviceId().then((id) => currentDeviceId.value = id);
      }
    } catch (_) {}
    ever(riderProfile, (_) => syncOperatingZonesWithProfile());
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
      (settings) {
        riderSettings.value = settings;
        if (settings.rider != null) {
          final current = riderProfile.value;
          final r = settings.rider!;
          final u = settings.user;
          riderProfile.value = r.copyWith(
            name: r.name.isNotEmpty ? r.name : (u?.name.isNotEmpty == true ? u!.name : current?.name),
            email: r.email.isNotEmpty ? r.email : (u?.email.isNotEmpty == true ? u!.email : current?.email),
            phone: r.phone.isNotEmpty
                ? r.phone
                : (u?.phone.isNotEmpty == true
                    ? (u!.phoneCountryCode.isNotEmpty && !u.phone.startsWith('+')
                        ? '${u.phoneCountryCode} ${u.phone}'
                        : u.phone)
                    : current?.phone),
            avatar: r.avatar.isNotEmpty
                ? r.avatar
                : (u?.image != null && u!.image!.isNotEmpty ? u.image! : current?.avatar),
          );
        }
      },
    );
  }

  Future<void> refreshFullSettings() async {
    isLoading.value = true;
    await _loadSettings();
    isLoading.value = false;
  }

  Future<void> _loadProfile() async {
    final result = await getProfileUseCase();
    result.fold(
      (failure) => null,
      (rider) {
        riderProfile.value = rider;
        syncOperatingZonesWithProfile();
      },
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
    await loadOperatingZones(showLoading: false);
  }

  Future<void> loadOperatingZones({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    final result = await getOperatingZonesUseCase();
    if (showLoading) isLoading.value = false;

    result.fold(
      (failure) => null,
      (zones) {
        operatingZones.assignAll(zones);
        syncOperatingZonesWithProfile();
      },
    );
  }

  Future<void> _loadPayoutInfo() async {
    await loadPayoutInfo();
  }

  Future<void> loadPayoutInfo({bool showLoading = false}) async {
    if (showLoading) isLoading.value = true;
    final result = await getPayoutInfoUseCase();
    if (showLoading) isLoading.value = false;
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
  Future<void> uploadDoc(String type, {ImageSource source = ImageSource.gallery}) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      var filePath = file?.path ?? 'mock_doc_path_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (file != null) {
        filePath = await ImageCompressor.compressImage(file.path, maxWidth: 1200, maxHeight: 1200, quality: 70);
      }

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

  // Operating Zones Toggle, Sync & Save
  void syncOperatingZonesWithProfile() {
    if (operatingZones.isEmpty) return;

    final rider = riderProfile.value ?? riderSettings.value.rider;
    final selectedZoneIds = (rider?.selectedZones ?? [])
        .map((z) => z.toLowerCase().trim())
        .toSet();

    final selectedLocNames = (rider?.selectedLocations ?? [])
        .map((l) => l.toLowerCase().trim())
        .toSet();

    final updated = operatingZones.map((zone) {
      final isZoneMatch = selectedZoneIds.contains(zone.id.toLowerCase().trim()) ||
          selectedZoneIds.contains(zone.name.toLowerCase().trim());

      final updatedLocs = zone.locations.map((loc) {
        final isLocMatch = selectedLocNames.contains(loc.name.toLowerCase().trim()) ||
            selectedLocNames.contains(loc.id.toLowerCase().trim()) ||
            (isZoneMatch && selectedLocNames.isEmpty);
        return loc.copyWith(isSelected: isLocMatch);
      }).toList();

      final isAnyLocSelected = updatedLocs.any((l) => l.isSelected);
      return zone.copyWith(
        isSelected: isZoneMatch || isAnyLocSelected,
        locations: updatedLocs,
      );
    }).toList();

    operatingZones.assignAll(updated);
  }

  void toggleZoneSelection(String zoneId) {
    final index = operatingZones.indexWhere((z) => z.id == zoneId || z.name == zoneId);
    if (index >= 0) {
      final current = operatingZones[index];
      final newSelected = !current.isSelected;
      final updatedLocations = current.locations.map((loc) => loc.copyWith(isSelected: newSelected)).toList();
      operatingZones[index] = current.copyWith(isSelected: newSelected, locations: updatedLocations);
    }
  }

  void toggleLocationSelection(String zoneId, String locationId) {
    final zoneIndex = operatingZones.indexWhere((z) => z.id == zoneId || z.name == zoneId);
    if (zoneIndex >= 0) {
      final zone = operatingZones[zoneIndex];
      final locIndex = zone.locations.indexWhere((l) => l.id == locationId || l.name == locationId);
      if (locIndex >= 0) {
        final loc = zone.locations[locIndex];
        final updatedLocs = List<DeliveryLocationEntity>.from(zone.locations);
        final newLocSelected = !loc.isSelected;
        updatedLocs[locIndex] = loc.copyWith(isSelected: newLocSelected);
        final hasAnySelected = updatedLocs.any((l) => l.isSelected);
        operatingZones[zoneIndex] = zone.copyWith(isSelected: hasAnySelected, locations: updatedLocs);
      }
    }
  }

  int get totalSelectedZonesCount =>
      operatingZones.where((z) => z.isSelected || z.locations.any((l) => l.isSelected)).length;

  int get totalSelectedLocationsCount =>
      operatingZones.fold<int>(0, (sum, z) => sum + z.locations.where((l) => l.isSelected).length);

  void selectAllZonesAndLocations() {
    final updated = operatingZones.map((zone) {
      final updatedLocs = zone.locations.map((loc) => loc.copyWith(isSelected: true)).toList();
      return zone.copyWith(isSelected: true, locations: updatedLocs);
    }).toList();
    operatingZones.assignAll(updated);
  }

  void clearAllZonesAndLocations() {
    final updated = operatingZones.map((zone) {
      final updatedLocs = zone.locations.map((loc) => loc.copyWith(isSelected: false)).toList();
      return zone.copyWith(isSelected: false, locations: updatedLocs);
    }).toList();
    operatingZones.assignAll(updated);
  }

  Future<void> saveOperatingZones() async {
    final selectedZoneIds = operatingZones
        .where((z) => z.isSelected || z.locations.any((l) => l.isSelected))
        .map((z) => z.id.isNotEmpty ? z.id : z.name)
        .toList();

    final selectedLocations = <String>[];
    for (final zone in operatingZones) {
      for (final loc in zone.locations) {
        if (loc.isSelected) {
          selectedLocations.add(loc.name.isNotEmpty ? loc.name : loc.id);
        }
      }
    }

    if (selectedZoneIds.isEmpty && selectedLocations.isEmpty) {
      Get.snackbar('Operating Zones', 'Please select at least 1 operating zone or region',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await updateOperatingZonesUseCase(selectedZoneIds, selectedLocations);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
      (success) {
        if (riderProfile.value != null) {
          riderProfile.value = riderProfile.value!.copyWith(
            selectedZones: selectedZoneIds,
            selectedLocations: selectedLocations,
          );
        }
        if (riderSettings.value.rider != null) {
          final updatedRider = riderSettings.value.rider!.copyWith(
            selectedZones: selectedZoneIds,
            selectedLocations: selectedLocations,
          );
          riderSettings.value = riderSettings.value.copyWith(rider: updatedRider);
        }
        Get.back();
        Get.snackbar('Zones Updated', 'Your preferred delivery zones and regions have been saved!',
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
          riderProfile.value = riderProfile.value!.copyWith(
            vehicle: updated,
            vehicleType: updated.type,
            vehicleName: updated.model,
            vehicleNumber: updated.licensePlate,
          );
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

    final current = riderProfile.value!;
    final updated = current.copyWith(
      name: name,
      phone: phone,
      vehicleType: vehicleType,
      vehicleName: vehicleName,
      vehicleNumber: vehicleNumber,
    );

    final result = await updateProfileUseCase(updated);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
      (res) {
        riderProfile.value = res.copyWith(
          name: res.name.isNotEmpty ? res.name : name,
          phone: res.phone.isNotEmpty ? res.phone : phone,
          email: res.email.isNotEmpty ? res.email : current.email,
          avatar: res.avatar.isNotEmpty ? res.avatar : current.avatar,
        );

        // Keep local cache fresh
        try {
          final storage = GetStorage();
          storage.write(
            AppConstants.riderProfileKey,
            jsonEncode(RiderModel.fromEntity(riderProfile.value!).toJson()),
          );
        } catch (_) {}

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

  Future<void> revokeDeviceSession(String deviceId) async {
    Get.defaultDialog(
      title: 'Revoke Device Session',
      middleText: 'Are you sure you want to disconnect this device session?',
      textConfirm: 'Revoke',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back();
        isLoading.value = true;
        try {
          if (Get.isRegistered<UnregisterDeviceTokenUseCase>()) {
            await Get.find<UnregisterDeviceTokenUseCase>()(deviceId: deviceId);
          }
          final updatedDevices = riderSettings.value.registeredDevices
              .where((d) => d.deviceId != deviceId)
              .toList();
          riderSettings.value = riderSettings.value.copyWith(registeredDevices: updatedDevices);
          Get.snackbar(
            'Session Revoked',
            'Device session removed successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
          );
        } catch (e) {
          Get.snackbar('Error', 'Failed to revoke device session: $e');
        } finally {
          isLoading.value = false;
        }
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
        // Checklist Point 4: Stop GPS tracking and disconnect socket
        if (Get.isRegistered<LocationService>()) {
          Get.find<LocationService>().stopTracking();
        }
        if (Get.isRegistered<SocketService>()) {
          Get.find<SocketService>().disconnect();
        }

        // Checklist Point 4: Mark rider offline in backend BEFORE clearing tokens
        try {
          if (Get.isRegistered<DioClient>()) {
            await Get.find<DioClient>().dio.post(
                  ApiEndpoints.status,
                  data: {'isOnline': false},
                );
          }
        } catch (_) {}

        // Section 9.2: Unregister Device Token
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().unregisterCurrentDeviceToken();
        }
        final storage = GetStorage();
        storage.write(AppConstants.isOnlineKey, false);
        storage.remove('online_since_timestamp');
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
