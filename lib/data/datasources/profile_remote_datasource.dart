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
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RiderModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.riderProfile);
      return RiderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      // Mock fallback
      return const RiderModel(
        id: 'rider_9082',
        name: 'Alex Johnson',
        phone: '+1 555 234 5678',
        email: 'alex.rider@meeem.com',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        rating: 4.92,
        totalTrips: 1420,
        isOnline: true,
        walletBalance: 184.50,
        approvalStatus: 'approved',
      );
    }
  }

  @override
  Future<RiderModel> updateProfile(RiderModel rider) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.updateProfile,
        data: rider.toJson(),
      );
      return RiderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to update profile',
        statusCode: e.response?.statusCode,
      );
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
}
