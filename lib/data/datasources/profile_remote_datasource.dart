import '../../domain/entities/document_entity.dart';
import '../../domain/entities/payout_info_entity.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
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
  Future<bool> updateOperatingZones(List<String> zoneIds);
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
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RiderModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.riderProfile);
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final riderData = data['rider'] as Map<String, dynamic>? ?? data;
        return RiderModel.fromJson(riderData);
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
        return RiderModel.fromJson(riderData);
      }
      return rider;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to update profile';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.getDocuments);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw const ServerException(message: 'Failed to load documents');
    }
  }

  @override
  Future<DocumentModel> uploadDocument(String docType, String filePath) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.uploadDocument,
        data: {'docType': docType, 'filePath': filePath},
      );
      return DocumentModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return DocumentModel(
        type: docType,
        title: 'Uploaded Document',
        documentNumber: 'DOC-NEW-2026',
        expiryDate: '2028-12-31',
        status: DocumentStatus.pending,
        fileUrl: filePath,
      );
    }
  }

  @override
  Future<List<OperatingZoneModel>> getOperatingZones() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.operatingZones);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => OperatingZoneModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Mock fallback zones
      return const [
        OperatingZoneModel(id: 'zone_1', name: 'Downtown District', district: 'Central Zone', isSelected: true, surgeMultiplier: 1.2, activeRiders: 45),
        OperatingZoneModel(id: 'zone_2', name: 'North Heights & Uptown', district: 'North Zone', isSelected: true, surgeMultiplier: 1.0, activeRiders: 28),
        OperatingZoneModel(id: 'zone_3', name: 'South Bay & Marina', district: 'South Zone', isSelected: false, surgeMultiplier: 1.15, activeRiders: 32),
        OperatingZoneModel(id: 'zone_4', name: 'Financial Hub & Market St', district: 'East Zone', isSelected: true, surgeMultiplier: 1.3, activeRiders: 56),
        OperatingZoneModel(id: 'zone_5', name: 'Airport Logistics Zone', district: 'Special Hub', isSelected: false, surgeMultiplier: 1.1, activeRiders: 19),
        OperatingZoneModel(id: 'zone_6', name: 'West Campus & University', district: 'West Zone', isSelected: false, surgeMultiplier: 1.05, activeRiders: 24),
      ];
    }
  }

  @override
  Future<bool> updateOperatingZones(List<String> zoneIds) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.operatingZones,
        data: {'zoneIds': zoneIds},
      );
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<PayoutInfoModel?> getPayoutInfo() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.payoutInfo);
      if (response.data != null && response.data['data'] != null) {
        return PayoutInfoModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return const PayoutInfoModel(
        methodType: PayoutMethodType.bank,
        bankName: 'Chase Bank USA',
        accountNumber: '9920184920',
        accountHolderName: 'Alex Johnson',
        routingNumber: '021000021',
      );
    }
  }

  @override
  Future<PayoutInfoModel> updatePayoutInfo(PayoutInfoModel payoutInfo) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.payoutInfo,
        data: payoutInfo.toJson(),
      );
      return PayoutInfoModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return payoutInfo;
    }
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updateVehicle,
        data: vehicle.toJson(),
      );
      return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return vehicle;
    }
  }

  @override
  Future<RiderSettingsModel> getSettings() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.settings);
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final settingsData = data['settings'] as Map<String, dynamic>? ?? data;
        return RiderSettingsModel.fromJson(settingsData);
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
  }) async {
    try {
      final patchData = <String, dynamic>{
        if (notifications != null) 'notifications': notifications.toJson(),
        if (navigation != null) 'navigation': navigation.toJson(),
        if (appPreferences != null) 'appPreferences': appPreferences.toJson(),
        if (currentPassword != null && currentPassword.isNotEmpty && newPassword != null && newPassword.isNotEmpty)
          'security': {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
      };

      final response = await _dioClient.dio.patch(
        ApiEndpoints.settings,
        data: patchData,
      );

      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final settingsData = data['settings'] as Map<String, dynamic>? ?? data;
        return RiderSettingsModel.fromJson(settingsData);
      }
      return const RiderSettingsModel();
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to update settings';
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }
}
