import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../../data/datasources/order_remote_datasource.dart';
import '../../../../data/datasources/earnings_remote_datasource.dart';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../../../../data/repositories/dashboard_repository_impl.dart';
import '../../../../data/repositories/order_repository_impl.dart';
import '../../../../data/repositories/earnings_repository_impl.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/repositories/dashboard_repository.dart';
import '../../../../domain/repositories/order_repository.dart';
import '../../../../domain/repositories/earnings_repository.dart';
import '../../../../domain/repositories/profile_repository.dart';
import '../../../../domain/usecases/dashboard/toggle_online_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_rider_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import '../../../../domain/usecases/dashboard/update_live_location_usecase.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/get_incoming_order_usecase.dart';
import '../../../../domain/usecases/orders/accept_order_usecase.dart';
import '../../../../domain/usecases/orders/decline_order_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/cancel_trip_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/get_rider_revenue_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
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
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());

    // Core Datasources
    final dioClient = Get.find<DioClient>();
    final localDataSource = Get.find<AuthLocalDataSource>();

    Get.lazyPut<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(dioClient));
    Get.lazyPut<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(dioClient));
    Get.lazyPut<EarningsRemoteDataSource>(() => EarningsRemoteDataSourceImpl(dioClient));
    Get.lazyPut<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(dioClient));

    // Repositories
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl(
          remoteDataSource: Get.find<DashboardRemoteDataSource>(),
          localDataSource: localDataSource,
        ));
    Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl(
          remoteDataSource: Get.find<OrderRemoteDataSource>(),
        ));
    Get.lazyPut<EarningsRepository>(() => EarningsRepositoryImpl(
          remoteDataSource: Get.find<EarningsRemoteDataSource>(),
        ));
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(
          remoteDataSource: Get.find<ProfileRemoteDataSource>(),
          localDataSource: localDataSource,
        ));

    // UseCases
    Get.lazyPut(() => ToggleOnlineStatusUseCase(Get.find<DashboardRepository>()));
    Get.lazyPut(() => GetRiderStatusUseCase(Get.find<DashboardRepository>()));
    Get.lazyPut(() => GetDashboardSummaryUseCase(Get.find<DashboardRepository>()));
    Get.lazyPut(() => UpdateLiveLocationUseCase(Get.find<DashboardRepository>()));

    Get.lazyPut(() => GetActiveOrdersUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetIncomingOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => AcceptOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => DeclineOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => UpdateOrderStatusUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => CancelTripUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetOrderHistoryUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetOrderDetailsUseCase(Get.find<OrderRepository>()));

    Get.lazyPut(() => GetEarningsBreakdownUseCase(Get.find<EarningsRepository>()));
    Get.lazyPut(() => GetRiderRevenueUseCase(Get.find<EarningsRepository>()));
    Get.lazyPut(() => RequestPayoutUseCase(Get.find<EarningsRepository>()));

    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetDocumentsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UploadDocumentUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetOperatingZonesUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateOperatingZonesUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetPayoutInfoUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdatePayoutInfoUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateVehicleUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetSettingsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateSettingsUseCase(Get.find<ProfileRepository>()));

    // Module Controllers
    Get.lazyPut<DashboardController>(() => DashboardController(
          toggleOnlineStatusUseCase: Get.find<ToggleOnlineStatusUseCase>(),
          getDashboardSummaryUseCase: Get.find<GetDashboardSummaryUseCase>(),
          getActiveOrdersUseCase: Get.find<GetActiveOrdersUseCase>(),
          getIncomingOrderUseCase: Get.find<GetIncomingOrderUseCase>(),
          acceptOrderUseCase: Get.find<AcceptOrderUseCase>(),
          declineOrderUseCase: Get.find<DeclineOrderUseCase>(),
        ));

    Get.lazyPut<OrdersController>(() => OrdersController(
          getActiveOrdersUseCase: Get.find<GetActiveOrdersUseCase>(),
          updateOrderStatusUseCase: Get.find<UpdateOrderStatusUseCase>(),
          cancelTripUseCase: Get.find<CancelTripUseCase>(),
          getOrderHistoryUseCase: Get.find<GetOrderHistoryUseCase>(),
          getOrderDetailsUseCase: Get.find<GetOrderDetailsUseCase>(),
        ));

    Get.lazyPut<EarningsController>(() => EarningsController(
          getRiderRevenueUseCase: Get.find<GetRiderRevenueUseCase>(),
          getEarningsBreakdownUseCase: Get.find<GetEarningsBreakdownUseCase>(),
          requestPayoutUseCase: Get.find<RequestPayoutUseCase>(),
        ));

    Get.lazyPut<ProfileController>(() => ProfileController(
          getProfileUseCase: Get.find<GetProfileUseCase>(),
          updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
          getDocumentsUseCase: Get.find<GetDocumentsUseCase>(),
          uploadDocumentUseCase: Get.find<UploadDocumentUseCase>(),
          getOperatingZonesUseCase: Get.find<GetOperatingZonesUseCase>(),
          updateOperatingZonesUseCase: Get.find<UpdateOperatingZonesUseCase>(),
          getPayoutInfoUseCase: Get.find<GetPayoutInfoUseCase>(),
          updatePayoutInfoUseCase: Get.find<UpdatePayoutInfoUseCase>(),
          updateVehicleUseCase: Get.find<UpdateVehicleUseCase>(),
          getSettingsUseCase: Get.find<GetSettingsUseCase>(),
          updateSettingsUseCase: Get.find<UpdateSettingsUseCase>(),
        ));
  }
}
