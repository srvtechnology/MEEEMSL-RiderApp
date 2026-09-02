import 'package:get/get.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;
  final unreadNotificationsCount = 2.obs;
  final hasActiveOrder = true.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
