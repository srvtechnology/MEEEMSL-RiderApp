import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../orders/views/order_history_view.dart';
import '../../earnings/views/earnings_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../widgets/rider_drawer.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardView(),
      const OrderHistoryView(),
      const EarningsView(),
      const ProfileView(),
    ];

    return Obx(() => Scaffold(
          drawer: const RiderDrawer(),
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: (index) => controller.changeTab(index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: AppStrings.myRevenue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}
