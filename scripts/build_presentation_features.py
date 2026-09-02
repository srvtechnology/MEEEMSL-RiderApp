import os

files = {}

# 1. Dashboard Module
files['lib/presentation/modules/dashboard/controllers/dashboard_controller.dart'] = '''import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/dashboard/toggle_online_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/get_incoming_order_usecase.dart';
import '../../../../domain/usecases/orders/accept_order_usecase.dart';
import '../../../../domain/usecases/orders/decline_order_usecase.dart';
import '../widgets/incoming_order_modal.dart';
import '../../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetIncomingOrderUseCase getIncomingOrderUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final DeclineOrderUseCase declineOrderUseCase;

  DashboardController({
    required this.toggleOnlineStatusUseCase,
    required this.getDashboardSummaryUseCase,
    required this.getActiveOrdersUseCase,
    required this.getIncomingOrderUseCase,
    required this.acceptOrderUseCase,
    required this.declineOrderUseCase,
  });

  // State Observables
  final isOnline = true.obs;
  final isLoading = false.obs;
  final todayEarnings = 148.50.obs;
  final todayDeliveries = 9.obs;
  final acceptanceRate = 96.5.obs;
  final rating = 4.92.obs;
  final onlineHours = 5.8.obs;
  
  final activeOrder = Rxn<OrderEntity>();
  final incomingOrder = Rxn<OrderEntity>();
  final countdownSeconds = AppConstants.incomingOrderTimeoutSeconds.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    final summaryResult = await getDashboardSummaryUseCase();
    summaryResult.fold(
      (failure) => null,
      (data) {
        todayEarnings.value = (data['todayEarnings'] as num?)?.toDouble() ?? 148.50;
        todayDeliveries.value = (data['todayDeliveries'] as num?)?.toInt() ?? 9;
        acceptanceRate.value = (data['acceptanceRate'] as num?)?.toDouble() ?? 96.5;
        rating.value = (data['rating'] as num?)?.toDouble() ?? 4.92;
        onlineHours.value = (data['onlineHours'] as num?)?.toDouble() ?? 5.8;
      },
    );

    final activeResult = await getActiveOrdersUseCase();
    activeResult.fold(
      (failure) => null,
      (orders) {
        if (orders.isNotEmpty) {
          activeOrder.value = orders.first;
        }
      },
    );
    isLoading.value = false;
  }

  Future<void> toggleOnline() async {
    final newStatus = !isOnline.value;
    final result = await toggleOnlineStatusUseCase(newStatus);
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (status) {
        isOnline.value = status;
        Get.snackbar(
          status ? "You're Online!" : "You're Offline",
          status ? "Ready to receive new orders" : "You won't receive delivery alerts",
          snackPosition: SnackPosition.TOP,
          backgroundColor: status ? const Color(0xFFE8F8EE) : const Color(0xFFF1F5F9),
          colorText: status ? const Color(0xFF009624) : const Color(0xFF0F172A),
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  // Simulated New Order Ping Trigger
  Future<void> simulateIncomingOrder() async {
    if (!isOnline.value) {
      Get.snackbar('Offline', 'Go online first to receive orders');
      return;
    }
    final result = await getIncomingOrderUseCase();
    result.fold(
      (failure) => null,
      (order) {
        if (order != null) {
          incomingOrder.value = order;
          _showIncomingOrderModal(order);
        }
      },
    );
  }

  void _showIncomingOrderModal(OrderEntity order) {
    _countdownTimer?.cancel();
    countdownSeconds.value = AppConstants.incomingOrderTimeoutSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
        Get.back(); // close modal
        incomingOrder.value = null;
        Get.snackbar('Missed Request', 'The order request has expired.', snackPosition: SnackPosition.TOP);
      }
    });

    Get.bottomSheet(
      IncomingOrderModal(order: order),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }

  Future<void> acceptIncomingOrder() async {
    final order = incomingOrder.value;
    if (order == null) return;

    _countdownTimer?.cancel();
    Get.back(); // close bottom sheet

    isLoading.value = true;
    final result = await acceptOrderUseCase(order.id);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (accepted) {
        activeOrder.value = accepted;
        incomingOrder.value = null;
        Get.toNamed(AppRoutes.activeOrder);
      },
    );
  }

  Future<void> declineIncomingOrder(String reason) async {
    final order = incomingOrder.value;
    if (order == null) return;

    _countdownTimer?.cancel();
    Get.back();

    await declineOrderUseCase(order.id, reason);
    incomingOrder.value = null;
    Get.snackbar('Declined', 'Order declined', snackPosition: SnackPosition.BOTTOM);
  }
}
'''

# 2. Dashboard Widgets & View
files['lib/presentation/modules/dashboard/widgets/incoming_order_modal.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/dashboard_controller.dart';

class IncomingOrderModal extends GetView<DashboardController> {
  final OrderEntity order;

  const IncomingOrderModal({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Countdown Ring
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.newOrderRequest,
                    style: AppTextStyles.headlineMedium(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order \${order.orderNumber}',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              // Circular Countdown Widget
              Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: controller.countdownSeconds.value / 30.0,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          backgroundColor: AppColors.secondaryContainer,
                        ),
                      ),
                      Text(
                        '\${controller.countdownSeconds.value}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 20),

          // Earnings Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.cardHeaderGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.estimatedEarnings,
                      style: AppTextStyles.labelSmall(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(order.riderEarnings),
                      style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 30),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDistance(order.distanceKm),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDuration(order.estimatedDurationMin),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pickup & Dropoff Route Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.pickupName,
                            style: AppTextStyles.titleMedium(),
                          ),
                          Text(
                            order.pickupAddress,
                            style: AppTextStyles.bodySmall(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: AppTextStyles.titleMedium(),
                          ),
                          Text(
                            order.dropoffAddress,
                            style: AppTextStyles.bodySmall(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Accept (Warm Amber CTA) & Decline
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: AppStrings.declineOrder,
                  type: ButtonType.outline,
                  customColor: AppColors.error,
                  onPressed: () => controller.declineIncomingOrder('Rider busy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: AppStrings.acceptOrder,
                  type: ButtonType.secondary,
                  icon: Icons.check_circle_rounded,
                  onPressed: () => controller.acceptIncomingOrder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
'''

files['lib/presentation/modules/dashboard/views/dashboard_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.two_wheeler_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meeem Rider',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Obx(() => Text(
                      controller.isOnline.value ? 'Online • Ready' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        color: controller.isOnline.value ? AppColors.success : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online / Offline Switch Hero Card
              _buildOnlineStatusCard(context),
              const SizedBox(height: 16),

              // Active Order Banner (If on a trip)
              _buildActiveOrderBanner(context),

              // Today's Earnings Summary Card
              _buildEarningsCard(context),
              const SizedBox(height: 16),

              // 4-Grid Metrics Overview
              _buildMetricsGrid(context),
              const SizedBox(height: 20),

              // Simulated Test Order Trigger (Convenient for Pair-Programming & Demo)
              _buildSimulatedOrderTrigger(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineStatusCard(BuildContext context) {
    return Obx(() {
      final isOnline = controller.isOnline.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.successLight : Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline ? AppColors.success.withAlpha(80) : AppColors.lightCardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.offlineGray,
                    shape: BoxShape.circle,
                    boxShadow: isOnline
                        ? [
                            BoxShadow(
                              color: AppColors.success.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isOnline ? AppColors.successDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      isOnline ? AppStrings.onlineFindingOrders : AppStrings.goOnlineToEarn,
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ],
            ),
            Switch.adaptive(
              value: isOnline,
              activeColor: AppColors.success,
              onChanged: (_) => controller.toggleOnline(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActiveOrderBanner(BuildContext context) {
    return Obx(() {
      final order = controller.activeOrder.value;
      if (order == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CustomCard(
          backgroundColor: AppColors.primaryContainer,
          border: Border.all(color: AppColors.primaryLight.withAlpha(60), width: 1.5),
          onTap: () => Get.toNamed(AppRoutes.activeOrder),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const StatusBadge(
                    text: 'CURRENT ACTIVE TRIP',
                    type: BadgeType.info,
                    icon: Icons.navigation_rounded,
                  ),
                  Text(
                    Formatters.formatCurrency(order.riderEarnings),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'To: \${order.dropoffAddress}',
                style: AppTextStyles.titleMedium(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer: \${order.customerName}',
                    style: AppTextStyles.bodySmall(),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: AppTextStyles.labelSmall(color: AppColors.primary),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardHeaderGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.todaysEarnings,
                style: AppTextStyles.labelMedium(color: Colors.white70),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.earnings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Wallet',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                Formatters.formatCurrency(controller.todayEarnings.value),
                style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 36),
              )),
          const SizedBox(height: 8),
          Text(
            'Updated just now • Instant payout available',
            style: AppTextStyles.bodySmall(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _buildMetricItem(
              context,
              title: AppStrings.completedOrders,
              value: '\${controller.todayDeliveries.value} Trips',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.onlineHours,
              value: '\${controller.onlineHours.value} hrs',
              icon: Icons.access_time_rounded,
              color: AppColors.info,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.acceptanceRate,
              value: '\${controller.acceptanceRate.value}%',
              icon: Icons.thumb_up_alt_outlined,
              color: AppColors.secondary,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.rating,
              value: '★ \${controller.rating.value}',
              icon: Icons.star_border_rounded,
              color: Colors.amber,
            ),
          ],
        ));
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall(),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedOrderTrigger(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Test Incoming Order Alert',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  'Trigger a live order ping with 30s countdown',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(80, 36),
            ),
            onPressed: () => controller.simulateIncomingOrder(),
            child: const Text('Simulate', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
'''

# 3. Orders Module
files['lib/presentation/modules/orders/controllers/orders_controller.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../widgets/delivery_proof_dialog.dart';
import '../../../routes/app_routes.dart';

class OrdersController extends GetxController {
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  OrdersController({
    required this.getActiveOrdersUseCase,
    required this.updateOrderStatusUseCase,
    required this.getOrderHistoryUseCase,
    required this.getOrderDetailsUseCase,
  });

  // State Observables
  final isLoading = false.obs;
  final activeOrders = <OrderEntity>[].obs;
  final orderHistory = <OrderEntity>[].obs;
  final selectedOrder = Rxn<OrderEntity>();
  final historyFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    await Future.wait([
      _loadActiveOrders(),
      _loadHistory(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadActiveOrders() async {
    final result = await getActiveOrdersUseCase();
    result.fold(
      (failure) => null,
      (orders) {
        activeOrders.assignAll(orders);
        if (orders.isNotEmpty) {
          selectedOrder.value = orders.first;
        }
      },
    );
  }

  Future<void> _loadHistory() async {
    final result = await getOrderHistoryUseCase(
      statusFilter: historyFilter.value == 'all' ? null : historyFilter.value,
    );
    result.fold(
      (failure) => null,
      (orders) => orderHistory.assignAll(orders),
    );
  }

  void filterHistory(String filter) {
    historyFilter.value = filter;
    _loadHistory();
  }

  // Order Lifecycle Progression
  Future<void> advanceActiveOrderStatus() async {
    final current = selectedOrder.value;
    if (current == null) return;

    OrderStatus nextStatus;
    switch (current.status) {
      case OrderStatus.accepted:
        nextStatus = OrderStatus.arrivedAtPickup;
        break;
      case OrderStatus.arrivedAtPickup:
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        nextStatus = OrderStatus.inTransit;
        break;
      case OrderStatus.inTransit:
        nextStatus = OrderStatus.arrivedAtDropoff;
        break;
      case OrderStatus.arrivedAtDropoff:
        // Requires Proof of Delivery Dialog
        Get.dialog(DeliveryProofDialog(
          order: current,
          onConfirmed: (photoUrl, otp) => _completeDelivery(current.id, photoUrl, otp),
        ));
        return;
      default:
        return;
    }

    isLoading.value = true;
    final result = await updateOrderStatusUseCase(current.id, nextStatus);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (updated) {
        selectedOrder.value = updated;
        _loadActiveOrders();
        Get.snackbar('Status Updated', updated.status.displayName, snackPosition: SnackPosition.TOP);
      },
    );
  }

  Future<void> _completeDelivery(String orderId, String? photoUrl, String? otp) async {
    isLoading.value = true;
    final result = await updateOrderStatusUseCase(
      orderId,
      OrderStatus.delivered,
      proofPhotoUrl: photoUrl,
      customerOtp: otp,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Delivery Failed', failure.message),
      (updated) {
        selectedOrder.value = null;
        _loadActiveOrders();
        _loadHistory();
        Get.offNamed(AppRoutes.main);
        Get.snackbar('🎉 Delivered Successfully!', 'Great job! Earnings have been credited to your wallet.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  // Customer Contact Actions
  Future<void> callContact(String phone) async {
    final uri = Uri.parse('tel:\$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Calling \$phone...');
    }
  }

  Future<void> messageContact(String phone) async {
    final uri = Uri.parse('sms:\$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Opening SMS for \$phone...');
    }
  }
}
'''

files['lib/presentation/modules/orders/widgets/delivery_proof_dialog.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/order_entity.dart';

class DeliveryProofDialog extends StatefulWidget {
  final OrderEntity order;
  final Function(String? photoUrl, String? otp) onConfirmed;

  const DeliveryProofDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<DeliveryProofDialog> createState() => _DeliveryProofDialogState();
}

class _DeliveryProofDialogState extends State<DeliveryProofDialog> {
  final otpController = TextEditingController();
  bool hasPhoto = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.proofOfDelivery,
                  style: AppTextStyles.headlineSmall(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Collect customer 4-digit OTP or snap a dropoff photo.',
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: 20),

            // OTP Input
            CustomTextField(
              controller: otpController,
              label: AppStrings.enterCustomerOtp,
              hintText: 'e.g. 4829',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.pin_outlined,
            ),
            const SizedBox(height: 16),

            // Photo Capture Mock Button
            GestureDetector(
              onTap: () {
                setState(() {
                  hasPhoto = !hasPhoto;
                });
                Get.snackbar('Photo Captured', 'Proof photo attached successfully');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: hasPhoto ? AppColors.successLight : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasPhoto ? AppColors.success : AppColors.primaryLight,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      hasPhoto ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                      color: hasPhoto ? AppColors.successDark : AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPhoto ? 'Photo Attached (Tap to change)' : AppStrings.uploadProofPhoto,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasPhoto ? AppColors.successDark : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Complete Delivery Button
            CustomButton(
              text: 'Confirm & Complete',
              type: ButtonType.secondary,
              onPressed: () {
                Get.back();
                widget.onConfirmed(
                  hasPhoto ? 'https://images.unsplash.com/photo-1526367790999-0150786686a2' : null,
                  otpController.text.trim().isNotEmpty ? otpController.text.trim() : '4829',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
'''

files['lib/presentation/modules/orders/views/active_order_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/swipe_button.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/orders_controller.dart';
import '../../../routes/app_routes.dart';

class ActiveOrderView extends GetView<OrdersController> {
  const ActiveOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.activeOrder),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Get.toNamed(AppRoutes.navigation),
          ),
        ],
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(
            child: Text('No active delivery order'),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Stepper Card
                    _buildStatusProgressCard(order),
                    const SizedBox(height: 16),

                    // Restaurant / Pickup Details
                    _buildPickupCard(order),
                    const SizedBox(height: 16),

                    // Customer / Dropoff Details
                    _buildDropoffCard(order),
                    const SizedBox(height: 16),

                    // Order Items Checklist
                    _buildItemsCard(order),
                    const SizedBox(height: 16),

                    // Special Instructions
                    if (order.notes.isNotEmpty) ...[
                      _buildInstructionsCard(order),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Swipe Confirmation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                child: SwipeButton(
                  text: order.status.nextStepActionTitle,
                  activeColor: AppColors.primary,
                  onSwiped: () => controller.advanceActiveOrderStatus(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusProgressCard(OrderEntity order) {
    return CustomCard(
      backgroundColor: AppColors.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT STATUS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                order.status.displayName,
                style: AppTextStyles.headlineSmall(color: AppColors.primaryDark),
              ),
            ],
          ),
          StatusBadge(
            text: order.orderNumber,
            type: BadgeType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(OrderEntity order) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(text: 'PICKUP', type: BadgeType.warning, icon: Icons.storefront_rounded),
              IconButton(
                icon: const Icon(Icons.phone, size: 20, color: AppColors.primary),
                onPressed: () => controller.callContact(order.pickupPhone),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.pickupName, style: AppTextStyles.titleLarge()),
          const SizedBox(height: 4),
          Text(order.pickupAddress, style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildDropoffCard(OrderEntity order) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(text: 'DELIVERY DESTINATION', type: BadgeType.success, icon: Icons.location_on_rounded),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primary),
                    onPressed: () => controller.messageContact(order.customerPhone),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, size: 20, color: AppColors.primary),
                    onPressed: () => controller.callContact(order.customerPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerName, style: AppTextStyles.titleLarge()),
          const SizedBox(height: 4),
          Text(order.dropoffAddress, style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderEntity order) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.orderItems, style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.bodyMedium()),
                          if (item.notes.isNotEmpty)
                            Text('Note: \${item.notes}', style: AppTextStyles.bodySmall(color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningDark.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warningDark, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Instructions',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warningDark),
                ),
                const SizedBox(height: 4),
                Text(
                  order.notes,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

