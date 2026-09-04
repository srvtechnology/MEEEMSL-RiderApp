import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rider_entity.dart';
import '../entities/document_entity.dart';
import '../entities/operating_zone_entity.dart';
import '../entities/payout_info_entity.dart';
import '../entities/vehicle_entity.dart';
import '../entities/rider_settings_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, RiderEntity>> getProfile();
  Future<Either<Failure, RiderEntity>> updateProfile(RiderEntity rider);
  Future<Either<Failure, List<DocumentEntity>>> getDocuments();
  Future<Either<Failure, DocumentEntity>> uploadDocument(String docType, String filePath);
  Future<Either<Failure, List<OperatingZoneEntity>>> getOperatingZones();
  Future<Either<Failure, bool>> updateOperatingZones(List<String> zoneIds);
  Future<Either<Failure, PayoutInfoEntity?>> getPayoutInfo();
  Future<Either<Failure, PayoutInfoEntity>> updatePayoutInfo(PayoutInfoEntity payoutInfo);
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle);
  Future<Either<Failure, RiderSettingsEntity>> getSettings();
  Future<Either<Failure, RiderSettingsEntity>> updateSettings({
    NotificationsSettingsEntity? notifications,
    NavigationSettingsEntity? navigation,
    AppPreferencesSettingsEntity? appPreferences,
    String? currentPassword,
    String? newPassword,
    List<String>? selectedZones,
    List<String>? selectedLocations,
  });
}
