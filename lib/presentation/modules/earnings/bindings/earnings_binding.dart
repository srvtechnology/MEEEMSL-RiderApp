import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/earnings_remote_datasource.dart';
import '../../../../data/repositories/earnings_repository_impl.dart';
import '../../../../domain/repositories/earnings_repository.dart';
import '../../../../domain/usecases/earnings/get_balance_transactions_usecase.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/get_payout_requests_usecase.dart';
import '../../../../domain/usecases/earnings/get_rider_revenue_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../../../../domain/usecases/earnings/submit_payout_request_usecase.dart';
import '../controllers/earnings_controller.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EarningsRemoteDataSource>()) {
      Get.lazyPut<EarningsRemoteDataSource>(
          () => EarningsRemoteDataSourceImpl(Get.find<DioClient>()));
    }
    if (!Get.isRegistered<EarningsRepository>()) {
      Get.lazyPut<EarningsRepository>(() => EarningsRepositoryImpl(
            remoteDataSource: Get.find<EarningsRemoteDataSource>(),
          ));
    }
    if (!Get.isRegistered<GetEarningsBreakdownUseCase>()) {
      Get.lazyPut(() => GetEarningsBreakdownUseCase(Get.find<EarningsRepository>()));
    }
    if (!Get.isRegistered<GetRiderRevenueUseCase>()) {
      Get.lazyPut(() => GetRiderRevenueUseCase(Get.find<EarningsRepository>()));
    }
    if (!Get.isRegistered<RequestPayoutUseCase>()) {
      Get.lazyPut(() => RequestPayoutUseCase(Get.find<EarningsRepository>()));
    }
    if (!Get.isRegistered<GetBalanceTransactionsUseCase>()) {
      Get.lazyPut(
          () => GetBalanceTransactionsUseCase(Get.find<EarningsRepository>()));
    }
    if (!Get.isRegistered<GetPayoutRequestsUseCase>()) {
      Get.lazyPut(
          () => GetPayoutRequestsUseCase(Get.find<EarningsRepository>()));
    }
    if (!Get.isRegistered<SubmitPayoutRequestUseCase>()) {
      Get.lazyPut(
          () => SubmitPayoutRequestUseCase(Get.find<EarningsRepository>()));
    }

    Get.lazyPut<EarningsController>(() => EarningsController(
          getRiderRevenueUseCase: Get.find<GetRiderRevenueUseCase>(),
          getEarningsBreakdownUseCase: Get.find<GetEarningsBreakdownUseCase>(),
          requestPayoutUseCase: Get.find<RequestPayoutUseCase>(),
          getBalanceTransactionsUseCase: Get.find<GetBalanceTransactionsUseCase>(),
          getPayoutRequestsUseCase: Get.find<GetPayoutRequestsUseCase>(),
          submitPayoutRequestUseCase: Get.find<SubmitPayoutRequestUseCase>(),
        ));
  }
}
