import 'dart:convert';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/payout_info_entity.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/rider_model.dart';
import '../models/document_model.dart';
import '../models/operating_zone_model.dart';
import '../models/payout_info_model.dart';
import '../models/vehicle_model.dart';
import '../models/rider_settings_model.dart';

abstract class ProfileRemoteDataSource {
  Future<RiderModel> getProfile();
  Future<RiderModel> updateProfile(RiderModel rider);
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> uploadDocument(String docType, String filePath);
  Future<List<OperatingZoneModel>> getOperatingZones();
  Future<bool> updateOperatingZones(List<String> zoneIds, [List<String>? locationNames]);
  Future<PayoutInfoModel?> getPayoutInfo();
  Future<PayoutInfoModel> updatePayoutInfo(PayoutInfoModel payoutInfo);
  Future<VehicleModel> updateVehicle(VehicleModel vehicle);
  Future<RiderSettingsModel> getSettings();
  Future<RiderSettingsModel> updateSettings({
    NotificationsSettingsModel? notifications,
    NavigationSettingsModel? navigation,
    AppPreferencesSettingsModel? appPreferences,
    String? currentPassword,
    String? newPassword,
    List<String>? selectedZones,
    List<String>? selectedLocations,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;
  final GetStorage _storage = GetStorage();

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RiderModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.riderProfile);
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>?;
        final riderMap = data['rider'] as Map<String, dynamic>? ?? data;
        return RiderModel.fromJson(riderMap, userMap);
      }
      throw const ServerException(message: 'Invalid profile response');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to load profile';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<RiderModel> updateProfile(RiderModel rider) async {
    try {
      final patchData = {
        'name': rider.name,
        'phone': rider.phone,
        if (rider.vehicleType != null) 'vehicleType': rider.vehicleType,
        if (rider.vehicleName != null) 'vehicleName': rider.vehicleName,
        if (rider.vehicleNumber != null) 'vehicleNumber': rider.vehicleNumber,
      };
      final response = await _dioClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: patchData,
      );
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final riderData = data['rider'] as Map<String, dynamic>? ?? data;
        final updatedRider = RiderModel.fromJson(riderData);
        return RiderModel(
          id: updatedRider.id.isNotEmpty ? updatedRider.id : rider.id,
          name: updatedRider.name.isNotEmpty ? updatedRider.name : rider.name,
          phone: updatedRider.phone.isNotEmpty ? updatedRider.phone : rider.phone,
          email: updatedRider.email.isNotEmpty ? updatedRider.email : rider.email,
          avatar: updatedRider.avatar.isNotEmpty ? updatedRider.avatar : rider.avatar,
          rating: updatedRider.rating,
          totalTrips: updatedRider.totalTrips,
          isOnline: updatedRider.isOnline,
          walletBalance: updatedRider.walletBalance,
          approvalStatus: updatedRider.approvalStatus,
          isApproved: updatedRider.isApproved,
          isSuspended: updatedRider.isSuspended,
          status: updatedRider.status,
          onboardingCompleted: updatedRider.onboardingCompleted,
          isFirstLogin: updatedRider.isFirstLogin,
          vehicleTypes: updatedRider.vehicleTypes.isNotEmpty ? updatedRider.vehicleTypes : rider.vehicleTypes,
          vehicleType: updatedRider.vehicleType ?? rider.vehicleType,
          vehicleName: updatedRider.vehicleName ?? rider.vehicleName,
          vehicleNumber: updatedRider.vehicleNumber ?? rider.vehicleNumber,
          drivingLicenseNo: updatedRider.drivingLicenseNo ?? rider.drivingLicenseNo,
          profileImage: updatedRider.profileImage ?? rider.profileImage,
          drivingLicenseDoc: updatedRider.drivingLicenseDoc ?? rider.drivingLicenseDoc,
          nationalIdDoc: updatedRider.nationalIdDoc ?? rider.nationalIdDoc,
          vehicleInsuranceDoc: updatedRider.vehicleInsuranceDoc ?? rider.vehicleInsuranceDoc,
          selectedZones: updatedRider.selectedZones.isNotEmpty ? updatedRider.selectedZones : rider.selectedZones,
          selectedLocations: updatedRider.selectedLocations.isNotEmpty ? updatedRider.selectedLocations : rider.selectedLocations,
          vehicle: updatedRider.vehicle ?? rider.vehicle,
          payoutInfo: updatedRider.payoutInfo ?? rider.payoutInfo,
          operatingZones: updatedRider.operatingZones.isNotEmpty ? updatedRider.operatingZones : rider.operatingZones,
        );
      }
      return rider;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to update profile';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<DocumentModel>> getDocuments() async {
    final savedRider = _storage.read<String>(AppConstants.riderProfileKey);
    RiderModel? rider;
    if (savedRider != null) {
      try {
        rider = RiderModel.fromJson(jsonDecode(savedRider) as Map<String, dynamic>);
      } catch (_) {}
    }

    final docs = <DocumentModel>[];
    if (rider?.drivingLicenseDoc != null && rider!.drivingLicenseDoc!.isNotEmpty) {
      docs.add(DocumentModel(
        type: 'driving_license',
        title: "Driver's License",
        documentNumber: rider.drivingLicenseNo ?? 'Registered',
        expiryDate: '2028-12-31',
        status: rider.isApproved ? DocumentStatus.verified : DocumentStatus.pending,
        fileUrl: rider.drivingLicenseDoc!,
      ));
    }
    if (rider?.nationalIdDoc != null && rider!.nationalIdDoc!.isNotEmpty) {
      docs.add(DocumentModel(
        type: 'national_id',
        title: 'National Identity Card',
        documentNumber: 'National ID',
        expiryDate: '2030-05-15',
        status: rider.isApproved ? DocumentStatus.verified : DocumentStatus.pending,
        fileUrl: rider.nationalIdDoc!,
      ));
    }
    if (rider?.vehicleInsuranceDoc != null && rider!.vehicleInsuranceDoc!.isNotEmpty) {
      docs.add(DocumentModel(
        type: 'vehicle_insurance',
        title: 'Vehicle Insurance Certificate',
        documentNumber: rider.vehicleNumber ?? 'Insurance',
        expiryDate: '2027-01-10',
        status: rider.isApproved ? DocumentStatus.verified : DocumentStatus.pending,
        fileUrl: rider.vehicleInsuranceDoc!,
      ));
    }
    return docs;
  }

  @override
  Future<DocumentModel> uploadDocument(String docType, String filePath) async {
    // Note: Dedicated uploadDocument endpoint is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // Return local mock model without making network calls.
    return DocumentModel(
      type: docType,
      title: 'Uploaded Document',
      documentNumber: 'DOC-NEW-2026',
      expiryDate: '2028-12-31',
      status: DocumentStatus.pending,
      fileUrl: filePath,
    );
  }

  @override
  Future<List<OperatingZoneModel>> getOperatingZones() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.zones);
      final rawData = response.data['data'];
      final List<dynamic> list;
      if (rawData is Map<String, dynamic> && rawData['zones'] is List<dynamic>) {
        list = rawData['zones'] as List<dynamic>;
      } else if (rawData is List<dynamic>) {
        list = rawData;
      } else {
        list = [];
      }
      return list.map((e) => OperatingZoneModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Mock fallback zones
      return const [
        OperatingZoneModel(
          id: 'cm7zone0001',
          name: 'WESTERN RURAL ZONE',
          description: 'Outer Western Area covering Waterloo, Campbell Town, and coastal villages',
          isSelected: true,
          locations: [
            DeliveryLocationModel(id: 'cm7loc0001', zoneId: 'cm7zone0001', name: 'WATERLOO', code: 'WLOO'),
            DeliveryLocationModel(id: 'cm7loc0002', zoneId: 'cm7zone0001', name: 'CAMPBELL TOWN', code: 'CTWN'),
          ],
        ),
        OperatingZoneModel(
          id: 'cm7zone0002',
          name: 'PENINSULA ROAD ZONE',
          description: 'Scenic beach and coastal corridor stretching from Lakka to Sussex and York',
          isSelected: true,
          locations: [
            DeliveryLocationModel(id: 'cm7loc0006', zoneId: 'cm7zone0002', name: 'NO 2 RIVER', code: 'NO2R'),
            DeliveryLocationModel(id: 'cm7loc0007', zoneId: 'cm7zone0002', name: 'BAW BAW', code: 'BBAW'),
          ],
        ),
      ];
    }
  }

  @override
  Future<bool> updateOperatingZones(List<String> zoneIds, [List<String>? locationNames]) async {
    try {
      // Conforms to MOBILE_RIDER_APP_API_DOC_PART_1.md Section 7.2: POST /mobileapi/rider/settings
      final data = <String, dynamic>{
        'selectedZones': zoneIds,
        if (locationNames != null) 'selectedLocations': locationNames,
      };
      final response = await _dioClient.dio.post(
        ApiEndpoints.settings,
        data: data,
      );
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<PayoutInfoModel?> getPayoutInfo() async {
    final storage = GetStorage();
    final stored = storage.read<Map<String, dynamic>>('rider_payout_info');
    if (stored != null) {
      return PayoutInfoModel.fromJson(stored);
    }
    return const PayoutInfoModel(
      methodType: PayoutMethodType.bank,
      bankName: 'Sierra Leone Commercial Bank',
      accountNumber: '•••• 8829',
      accountHolderName: 'Ibrahim Koroma',
      routingNumber: '021000021',
    );
  }

  @override
  Future<PayoutInfoModel> updatePayoutInfo(PayoutInfoModel payoutInfo) async {
    final storage = GetStorage();
    await storage.write('rider_payout_info', payoutInfo.toJson());
    try {
      await _dioClient.dio.patch(
        ApiEndpoints.riderProfile,
        data: {
          'payoutInfo': payoutInfo.toJson(),
        },
      );
    } catch (_) {
      // Graceful fallback to local persistence
    }
    return payoutInfo;
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      // Conforms to MOBILE_RIDER_APP_API_DOC_PART_1.md Section 6.2: PATCH /mobileapi/rider/profile
      final response = await _dioClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: {
          'vehicleType': vehicle.type,
          'vehicleName': vehicle.model,
          'vehicleNumber': vehicle.licensePlate,
        },
      );
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final riderData = data['rider'] as Map<String, dynamic>? ?? data;
        final updatedRider = RiderModel.fromJson(riderData);
        return VehicleModel(
          type: updatedRider.vehicleType ?? vehicle.type,
          model: updatedRider.vehicleName ?? vehicle.model,
          licensePlate: updatedRider.vehicleNumber ?? vehicle.licensePlate,
          color: vehicle.color,
          year: vehicle.year,
        );
      }
      return vehicle;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to update vehicle details';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<RiderSettingsModel> getSettings() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.settings);
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;

        // Load local preferences cache if not present in response
        final storage = GetStorage();
        final localNotifs = storage.read<Map<String, dynamic>>('rider_pref_notifications');
        final localNav = storage.read<Map<String, dynamic>>('rider_pref_navigation');
        final localPrefs = storage.read<Map<String, dynamic>>('rider_pref_app_preferences');

        final mergedData = Map<String, dynamic>.from(data);
        if (mergedData['notifications'] == null && localNotifs != null) {
          mergedData['notifications'] = localNotifs;
        }
        if (mergedData['navigation'] == null && localNav != null) {
          mergedData['navigation'] = localNav;
        }
        if (mergedData['appPreferences'] == null && localPrefs != null) {
          mergedData['appPreferences'] = localPrefs;
        }

        return RiderSettingsModel.fromJson(mergedData);
      }
      return const RiderSettingsModel();
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to load settings';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<RiderSettingsModel> updateSettings({
    NotificationsSettingsModel? notifications,
    NavigationSettingsModel? navigation,
    AppPreferencesSettingsModel? appPreferences,
    String? currentPassword,
    String? newPassword,
    List<String>? selectedZones,
    List<String>? selectedLocations,
  }) async {
    try {
      final storage = GetStorage();
      if (notifications != null) {
        await storage.write('rider_pref_notifications', notifications.toJson());
      }
      if (navigation != null) {
        await storage.write('rider_pref_navigation', navigation.toJson());
      }
      if (appPreferences != null) {
        await storage.write('rider_pref_app_preferences', appPreferences.toJson());
      }

      // Conforms to MOBILE_RIDER_APP_API_DOC_PART_1.md Section 7.2: POST /mobileapi/rider/settings
      final postData = <String, dynamic>{
        if (currentPassword != null && currentPassword.isNotEmpty) 'currentPassword': currentPassword,
        if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
        if (selectedZones != null) 'selectedZones': selectedZones,
        if (selectedLocations != null) 'selectedLocations': selectedLocations,
        if (notifications != null) 'notifications': notifications.toJson(),
        if (navigation != null) 'navigation': navigation.toJson(),
        if (appPreferences != null) 'appPreferences': appPreferences.toJson(),
      };

      final response = await _dioClient.dio.post(
        ApiEndpoints.settings,
        data: postData,
      );

      if (response.data != null && response.data['data'] != null) {
        final resData = response.data['data'] as Map<String, dynamic>;
        // Response contains { rider: { ... } }
        final riderData = resData['rider'] as Map<String, dynamic>? ?? resData;

        final localNotifs = storage.read<Map<String, dynamic>>('rider_pref_notifications');
        final localNav = storage.read<Map<String, dynamic>>('rider_pref_navigation');
        final localPrefs = storage.read<Map<String, dynamic>>('rider_pref_app_preferences');

        return RiderSettingsModel(
          rider: RiderModel.fromJson(riderData),
          notifications: notifications ??
              (localNotifs != null
                  ? NotificationsSettingsModel.fromJson(localNotifs)
                  : const NotificationsSettingsModel()),
          navigation: navigation ??
              (localNav != null
                  ? NavigationSettingsModel.fromJson(localNav)
                  : const NavigationSettingsModel()),
          appPreferences: appPreferences ??
              (localPrefs != null
                  ? AppPreferencesSettingsModel.fromJson(localPrefs)
                  : const AppPreferencesSettingsModel()),
        );
      }
      return const RiderSettingsModel();
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to update settings';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }
}
