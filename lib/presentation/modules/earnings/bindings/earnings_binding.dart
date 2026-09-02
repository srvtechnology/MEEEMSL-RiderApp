import 'package:get/get.dart';
import '../controllers/earnings_controller.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsController>(() => EarningsController(
          getEarningsBreakdownUseCase: Get.find(),
          requestPayoutUseCase: Get.find(),
        ));
  }
}
