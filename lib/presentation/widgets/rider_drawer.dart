import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../modules/main_layout/controllers/main_layout_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../routes/app_routes.dart';

class RiderDrawer extends StatelessWidget {
  const RiderDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final localDataSource = Get.isRegistered<AuthLocalDataSource>()
        ? Get.find<AuthLocalDataSource>()
        : null;
    final rider = localDataSource?.getSavedRider();
    final user = localDataSource?.getSavedUser();

    final name = rider?.name ?? user?.name ?? 'Ibrahim Koroma';
    final email = rider?.email ?? user?.email ?? 'rider.ibrahim@example.com';
    final vehicle = rider?.vehicleType?.replaceAll('_', ' ') ?? '2-Wheeler Partner';

    return Drawer(
      child: Column(
        children: [
          // Rider Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.cardHeaderGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'R',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ),
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(email, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    vehicle,
                    style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  tabIndex: 0,
                  context: context,
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  title: 'Orders',
                  tabIndex: 1,
                  context: context,
                ),
                // Checklist item 1: "My Revenue" menu option
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  title: AppStrings.myRevenue,
                  tabIndex: 2,
                  context: context,
                  isHighlighted: true,
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  title: 'Profile',
                  tabIndex: 3,
                  context: context,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.two_wheeler_outlined, color: AppColors.primary),
                  title: const Text('Vehicle Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.vehicleInfo);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                  title: const Text('Operating Zones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.operatingZones);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  title: const Text('Documents & Verification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.documents);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
                  title: const Text('Payout Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.payoutInfo);
                  },
                ),
              ],
            ),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.errorDark),
            title: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.errorDark, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Get.back();
              if (Get.isRegistered<ProfileController>()) {
                Get.find<ProfileController>().logout();
              } else {
                Get.offAllNamed(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int tabIndex,
    required BuildContext context,
    bool isHighlighted = false,
  }) {
    final hasMainController = Get.isRegistered<MainLayoutController>();
    final isSelected = hasMainController && Get.find<MainLayoutController>().currentIndex.value == tabIndex;

    return ListTile(
      leading: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected || isHighlighted ? AppColors.primary : AppColors.textSecondaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected || isHighlighted ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
        ),
      ),
      trailing: isHighlighted
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Text(
                'Engine',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
              ),
            )
          : null,
      selected: isSelected,
      onTap: () {
        Get.back(); // close drawer
        if (hasMainController) {
          Get.find<MainLayoutController>().changeTab(tabIndex);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      },
    );
  }
}
