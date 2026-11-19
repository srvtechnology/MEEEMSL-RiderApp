import 'package:get/get.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;
  final unreadNotificationsCount = 2.obs;
  final hasActiveOrder = true.obs;

  /// Tracks which bottom-nav tabs have been visited so unvisited tabs are
  /// lazy-mounted on first tap instead of firing all 4 modules' APIs at startup.
  final visitedTabs = <int>{0}.obs;

  void changeTab(int index) {
    final wasAlreadyVisited = visitedTabs.contains(index);
    if (!wasAlreadyVisited) {
      visitedTabs.add(index);
    }
    currentIndex.value = index;

    // If the tab is being mounted for the very first time, its controller's
    // onInit() already kicks off the initial load — avoid duplicate fetches!
    if (!wasAlreadyVisited) return;

    if (index == 1 && Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().loadOrdersIfStale();
    } else if (index == 2 && Get.isRegistered<EarningsController>()) {
      Get.find<EarningsController>().refreshIfStale();
    } else if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadAllProfileData(force: false);
    }
  }
}
