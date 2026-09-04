import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rider_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/operating_zone_entity.dart';
import '../../domain/entities/payout_info_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/rider_settings_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/rider_model.dart';
import '../models/payout_info_model.dart';
import '../models/vehicle_model.dart';
import '../models/rider_settings_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, RiderEntity>> getProfile() async {
    try {
      final rider = await remoteDataSource.getProfile();
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> updateProfile(RiderEntity rider) async {
    try {
      final updated = await remoteDataSource.updateProfile(RiderModel.fromEntity(rider));
      await localDataSource.saveRider(updated);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments() async {
    try {
      final docs = await remoteDataSource.getDocuments();
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(String docType, String filePath) async {
    try {
      final doc = await remoteDataSource.uploadDocument(docType, filePath);
      return Right(doc);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OperatingZoneEntity>>> getOperatingZones() async {
    try {
      final zones = await remoteDataSource.getOperatingZones();
      return Right(zones);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOperatingZones(List<String> zoneIds, [List<String>? locationNames]) async {
    try {
      final result = await remoteDataSource.updateOperatingZones(zoneIds, locationNames);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PayoutInfoEntity?>> getPayoutInfo() async {
    try {
      final payoutInfo = await remoteDataSource.getPayoutInfo();
      return Right(payoutInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PayoutInfoEntity>> updatePayoutInfo(PayoutInfoEntity payoutInfo) async {
    try {
      final updated = await remoteDataSource.updatePayoutInfo(PayoutInfoModel.fromEntity(payoutInfo));
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle) async {
    try {
      final updated = await remoteDataSource.updateVehicle(VehicleModel.fromEntity(vehicle));
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderSettingsEntity>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderSettingsEntity>> updateSettings({
    NotificationsSettingsEntity? notifications,
    NavigationSettingsEntity? navigation,
    AppPreferencesSettingsEntity? appPreferences,
    String? currentPassword,
    String? newPassword,
    List<String>? selectedZones,
    List<String>? selectedLocations,
  }) async {
    try {
      final updated = await remoteDataSource.updateSettings(
        notifications: notifications != null ? NotificationsSettingsModel.fromEntity(notifications) : null,
        navigation: navigation != null ? NavigationSettingsModel.fromEntity(navigation) : null,
        appPreferences: appPreferences != null ? AppPreferencesSettingsModel.fromEntity(appPreferences) : null,
        currentPassword: currentPassword,
        newPassword: newPassword,
        selectedZones: selectedZones,
        selectedLocations: selectedLocations,
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
