import 'package:get/get.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;
  final unreadNotificationsCount = 2.obs;
  final hasActiveOrder = true.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1 && Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().loadOrders();
    } else if (index == 2 && Get.isRegistered<EarningsController>()) {
      Get.find<EarningsController>().loadRevenue(showLoading: false);
    } else if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadAllProfileData();
    }
  }
}
