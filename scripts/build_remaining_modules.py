import os

files = {}

# 1. Order History & Order Details Views
files['lib/presentation/modules/orders/views/order_history_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/orders_controller.dart';
import 'order_details_view.dart';

class OrderHistoryView extends GetView<OrdersController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Delivered', 'delivered'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cancelled', 'cancelled'),
                  ],
                )),
          ),
          const Divider(),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.orderHistory.isEmpty) {
                return Center(
                  child: Text('No orders found', style: AppTextStyles.bodyMedium()),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orderHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = controller.orderHistory[index];
                  return CustomCard(
                    onTap: () => Get.to(() => OrderDetailsView(order: order)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderNumber, style: AppTextStyles.titleMedium()),
                            StatusBadge(
                              text: order.status.displayName,
                              type: BadgeType.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(order.pickupName, style: AppTextStyles.bodyLarge()),
                        const SizedBox(height: 2),
                        Text('To: \${order.dropoffAddress}', style: AppTextStyles.bodySmall()),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatDate(order.createdAt),
                              style: AppTextStyles.bodySmall(),
                            ),
                            Text(
                              Formatters.formatCurrency(order.riderEarnings),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.historyFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => controller.filterHistory(value),
    );
  }
}
'''

files['lib/presentation/modules/orders/views/order_details_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/order_entity.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details \${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fare Summary Hero
            Container(
              padding: const EdgeInsets.all(20),
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
                      Text('Trip Payout', style: AppTextStyles.labelSmall(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(order.riderEarnings),
                        style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 32),
                      ),
                    ],
                  ),
                  const StatusBadge(text: 'COMPLETED', type: BadgeType.success),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Summary
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Route', style: AppTextStyles.titleMedium()),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.pickupName, style: AppTextStyles.titleSmall()),
                            Text(order.pickupAddress, style: AppTextStyles.bodySmall()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.customerName, style: AppTextStyles.titleSmall()),
                            Text(order.dropoffAddress, style: AppTextStyles.bodySmall()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.orderItems, style: AppTextStyles.titleMedium()),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\${item.quantity}x \${item.name}'),
                            const Icon(Icons.check, size: 16, color: AppColors.success),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'''

# 2. Navigation Module
files['lib/presentation/modules/navigation/controllers/navigation_controller.dart'] = '''import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../orders/controllers/orders_controller.dart';

class NavigationController extends GetxController {
  final currentStepInstruction = 'In 250m, Turn Right onto Broadway St'.obs;
  final remainingDistance = 2.4.obs;
  final remainingMinutes = 8.obs;
  final currentSpeedKmh = 34.obs;

  OrderEntity? get activeOrder => Get.find<OrdersController>().selectedOrder.value;

  Future<void> openExternalGoogleMaps() async {
    final order = activeOrder;
    if (order == null) return;

    final lat = order.dropoffLat;
    final lng = order.dropoffLng;
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=\$lat,\$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Maps', 'Could not launch external maps.');
    }
  }
}
'''

files['lib/presentation/modules/navigation/bindings/navigation_binding.dart'] = '''import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
  }
}
'''

files['lib/presentation/modules/navigation/views/navigation_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/navigation_controller.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.activeOrder;

    return Scaffold(
      body: Stack(
        children: [
          // Realistic Stylized Vector Map Canvas
          _buildStylizedMap(context),

          // Top Turn Instruction Banner
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTurnBanner(context),
                ],
              ),
            ),
          ),

          // Bottom Navigation Summary Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomTripCard(context, order),
          ),
        ],
      ),
    );
  }

  Widget _buildStylizedMap(BuildContext context) {
    return Container(
      color: const Color(0xFFE5ECF4),
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: MapGridPainter(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Polyline Path Graphic
            Positioned(
              top: 250,
              left: 100,
              right: 100,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(120),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Rider Live Marker (Arrow Pulsing)
            Positioned(
              top: 360,
              left: 170,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            // Destination Pin
            Positioned(
              top: 200,
              right: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.turn_right_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.currentStepInstruction.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                const SizedBox(height: 2),
                Text(
                  'Then continue straight for 1.2 km',
                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTripCard(BuildContext context, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ETA, Remaining Distance & Speed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() => Column(
                      children: [
                        Text(
                          '\${controller.remainingMinutes.value} mins',
                          style: AppTextStyles.navigationEta(color: AppColors.primary),
                        ),
                        Text('ETA', style: AppTextStyles.labelSmall()),
                      ],
                    )),
                Obx(() => Column(
                      children: [
                        Text(
                          Formatters.formatDistance(controller.remainingDistance.value),
                          style: AppTextStyles.navigationEta(),
                        ),
                        Text('Distance', style: AppTextStyles.labelSmall()),
                      ],
                    )),
                Obx(() => Column(
                      children: [
                        Text(
                          '\${controller.currentSpeedKmh.value} km/h',
                          style: AppTextStyles.navigationEta(),
                        ),
                        Text('Speed', style: AppTextStyles.labelSmall()),
                      ],
                    )),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Open In Google Maps Button
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Google Maps',
                    icon: Icons.open_in_new_rounded,
                    type: ButtonType.outline,
                    onPressed: () => controller.openExternalGoogleMaps(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Back to Order',
                    icon: Icons.arrow_back,
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6E2EE)
      ..strokeWidth = 1.5;

    // Draw stylized road grid lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 60) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
'''

# 3. Earnings Module
files['lib/presentation/modules/earnings/controllers/earnings_controller.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/earnings_entity.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../widgets/payout_request_bottom_sheet.dart';

class EarningsController extends GetxController {
  final GetEarningsBreakdownUseCase getEarningsBreakdownUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;

  EarningsController({
    required this.getEarningsBreakdownUseCase,
    required this.requestPayoutUseCase,
  });

  final isLoading = false.obs;
  final selectedPeriod = 'weekly'.obs; // daily, weekly, monthly
  final earningsData = Rxn<EarningsEntity>();

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    isLoading.value = true;
    final result = await getEarningsBreakdownUseCase(selectedPeriod.value);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => earningsData.value = data,
    );
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadEarnings();
  }

  void openPayoutModal() {
    Get.bottomSheet(
      PayoutRequestBottomSheet(
        availableBalance: earningsData.value?.availablePayout ?? 642.50,
        onSubmitted: (amount, method) => _submitPayout(amount, method),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitPayout(double amount, String method) async {
    isLoading.value = true;
    final result = await requestPayoutUseCase(amount, method);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (success) {
        Get.back(); // close modal
        loadEarnings();
        Get.snackbar('Payout Initiated', 'Transfer of \$$amount sent to your bank account',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }
}
'''

files['lib/presentation/modules/earnings/bindings/earnings_binding.dart'] = '''import 'package:get/get.dart';
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
'''

files['lib/presentation/modules/earnings/widgets/payout_request_bottom_sheet.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class PayoutRequestBottomSheet extends StatefulWidget {
  final double availableBalance;
  final Function(double amount, String method) onSubmitted;

  const PayoutRequestBottomSheet({
    super.key,
    required this.availableBalance,
    required this.onSubmitted,
  });

  @override
  State<PayoutRequestBottomSheet> createState() => _PayoutRequestBottomSheetState();
}

class _PayoutRequestBottomSheetState extends State<PayoutRequestBottomSheet> {
  final amountController = TextEditingController();
  String selectedMethod = 'Direct Bank Transfer (•••• 8829)';

  @override
  void initState() {
    super.initState();
    amountController.text = widget.availableBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Instant Cash Out', style: AppTextStyles.headlineSmall()),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Available: \${Formatters.formatCurrency(widget.availableBalance)}',
            style: AppTextStyles.bodyMedium(color: AppColors.primary),
          ),
          const SizedBox(height: 20),

          // Payout Amount
          CustomTextField(
            controller: amountController,
            label: 'Amount to Withdraw',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money,
          ),
          const SizedBox(height: 16),

          // Bank Account Selection
          const Text('Destination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(selectedMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: 'Confirm Cash Out',
            type: ButtonType.secondary,
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim()) ?? widget.availableBalance;
              widget.onSubmitted(amount, selectedMethod);
            },
          ),
        ],
      ),
    );
  }
}
'''

files['lib/presentation/modules/earnings/views/earnings_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wallet),
      ),
      body: Obx(() {
        final data = controller.earningsData.value;
        if (data == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadEarnings(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Card
                _buildAvailableBalanceCard(data?.availablePayout ?? 642.50),
                const SizedBox(height: 16),

                // Period Switcher
                _buildPeriodSelector(),
                const SizedBox(height: 16),

                // Weekly Bar Chart Graphic
                _buildBarChart(data),
                const SizedBox(height: 16),

                // Earnings Breakdown
                _buildBreakdownCard(data),
                const SizedBox(height: 16),

                // Recent Transactions
                _buildTransactionsList(data),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvailableBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardHeaderGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.availableForPayout, style: AppTextStyles.labelMedium(color: Colors.white70)),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(balance),
            style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 34),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: AppStrings.cashOut,
            type: ButtonType.secondary,
            height: 44,
            icon: Icons.flash_on_rounded,
            onPressed: () => controller.openPayoutModal(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Obx(() => Row(
          children: [
            _buildTabChip('Daily', 'daily'),
            const SizedBox(width: 8),
            _buildTabChip('Weekly', 'weekly'),
            const SizedBox(width: 8),
            _buildTabChip('Monthly', 'monthly'),
          ],
        ));
  }

  Widget _buildTabChip(String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Performance', style: AppTextStyles.titleMedium()),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: (data.dailyData as List).map<Widget>((item) {
                final heightFactor = item.amount > 0 ? (item.amount / 200.0).clamp(0.1, 1.0) : 0.05;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.amount > 0 ? '\$${item.amount.toInt()}' : '',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 90 * heightFactor,
                      decoration: BoxDecoration(
                        color: item.amount > 0 ? AppColors.primary : AppColors.lightCardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(item.day, style: AppTextStyles.labelSmall()),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(dynamic data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout Breakdown', style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          _buildBreakdownRow(AppStrings.baseFare, data?.basePay ?? 598.00),
          _buildBreakdownRow(AppStrings.customerTips, data?.tips ?? 184.20, isHighlight: true),
          _buildBreakdownRow(AppStrings.surgeBonus, data?.surgeBonuses ?? 110.00),
          const Divider(height: 20),
          _buildBreakdownRow('Total Gross', data?.weeklyEarnings ?? 892.20, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String title, double amount, {bool isHighlight = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)
                : AppTextStyles.bodyMedium(),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isHighlight ? AppColors.successDark : (isTotal ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.payoutHistory, style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          if (data?.recentTransactions != null)
            ...((data.recentTransactions as List).map((tx) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: tx.amount > 0 ? AppColors.successLight : AppColors.primaryContainer,
                    child: Icon(
                      tx.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.amount > 0 ? AppColors.successDark : AppColors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(tx.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(Formatters.formatShortDate(tx.date), style: AppTextStyles.bodySmall()),
                  trailing: Text(
                    Formatters.formatCurrency(tx.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tx.amount > 0 ? AppColors.successDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ))),
        ],
      ),
    );
  }
}
'''

# 4. Profile & Documents Module
files['lib/presentation/modules/profile/controllers/profile_controller.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/rider_entity.dart';
import '../../../../domain/entities/document_entity.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../../domain/usecases/profile/get_documents_usecase.dart';
import '../../../../domain/usecases/profile/upload_document_usecase.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetDocumentsUseCase getDocumentsUseCase;
  final UploadDocumentUseCase uploadDocumentUseCase;

  ProfileController({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getDocumentsUseCase,
    required this.uploadDocumentUseCase,
  });

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final riderProfile = Rxn<RiderEntity>();
  final documents = <DocumentEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    isDarkMode.value = storage.read<bool>(AppConstants.isDarkModeKey) ?? false;
    loadProfileAndDocs();
  }

  Future<void> loadProfileAndDocs() async {
    isLoading.value = true;
    final profileResult = await getProfileUseCase();
    profileResult.fold(
      (failure) => null,
      (rider) => riderProfile.value = rider,
    );

    final docsResult = await getDocumentsUseCase();
    docsResult.fold(
      (failure) => null,
      (docList) => documents.assignAll(docList),
    );
    isLoading.value = false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    GetStorage().write(AppConstants.isDarkModeKey, isDarkMode.value);
  }

  Future<void> uploadDoc(String type) async {
    final result = await uploadDocumentUseCase(type, 'dummy_path');
    result.fold(
      (failure) => Get.snackbar('Upload Failed', failure.message),
      (doc) {
        documents.add(doc);
        Get.snackbar('Document Uploaded', '\${doc.title} uploaded for review',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out of Meeem Rider?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        final storage = GetStorage();
        storage.remove(AppConstants.tokenKey);
        storage.remove(AppConstants.riderProfileKey);
        Get.back();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
'''

files['lib/presentation/modules/profile/bindings/profile_binding.dart'] = '''import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController(
          getProfileUseCase: Get.find(),
          updateProfileUseCase: Get.find(),
          getDocumentsUseCase: Get.find(),
          uploadDocumentUseCase: Get.find(),
        ));
  }
}
'''

files['lib/presentation/modules/profile/views/profile_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/profile_controller.dart';
import 'documents_view.dart';
import 'vehicle_info_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rider Avatar & Info Card
            _buildRiderHeader(context),
            const SizedBox(height: 20),

            // Profile Sections
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                    title: const Text('Documents & Verification'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const DocumentsView()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.two_wheeler_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.vehicleDetails),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const VehicleInfoView()),
                  ),
                  const Divider(),
                  Obx(() => SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                        title: const Text(AppStrings.darkMode),
                        value: controller.isDarkMode.value,
                        onChanged: (_) => controller.toggleTheme(),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Support & About
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: const Text(AppStrings.helpSupport),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.snackbar('Support', '24/7 Rider Hotline: +1 800 555 MEEEM'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.termsPrivacy),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.snackbar('Policy', 'Meeem Rider Terms & Privacy Policy 2026'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: AppColors.errorLight,
              leading: const Icon(Icons.logout_rounded, color: AppColors.errorDark),
              title: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.errorDark, fontWeight: FontWeight.w700),
              ),
              onTap: () => controller.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderHeader(BuildContext context) {
    return Obx(() {
      final rider = controller.riderProfile.value;

      return CustomCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: rider?.avatar.isNotEmpty == true ? NetworkImage(rider!.avatar) : null,
              child: rider?.avatar.isEmpty ?? true
                  ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rider?.name ?? 'Alex Johnson', style: AppTextStyles.headlineSmall()),
                  const SizedBox(height: 2),
                  Text(rider?.phone ?? '+1 555 234 5678', style: AppTextStyles.bodySmall()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const StatusBadge(text: '★ 4.92', type: BadgeType.warning),
                      const SizedBox(width: 8),
                      StatusBadge(text: '\${rider?.totalTrips ?? 1420} Trips', type: BadgeType.info),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
'''

files['lib/presentation/modules/profile/views/documents_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/document_entity.dart';
import '../controllers/profile_controller.dart';

class DocumentsView extends GetView<ProfileController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.documents),
      ),
      body: Obx(() {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.documents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = controller.documents[index];
            return CustomCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.title, style: AppTextStyles.titleMedium()),
                        const SizedBox(height: 2),
                        Text('Exp: \${doc.expiryDate}', style: AppTextStyles.bodySmall()),
                      ],
                    ),
                  ),
                  StatusBadge(
                    text: doc.status.name.toUpperCase(),
                    type: doc.status == DocumentStatus.verified ? BadgeType.success : BadgeType.warning,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
'''

files['lib/presentation/modules/profile/views/vehicle_info_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../controllers/profile_controller.dart';

class VehicleInfoView extends GetView<ProfileController> {
  const VehicleInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vehicleDetails),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Honda CB500X', style: AppTextStyles.headlineSmall()),
                      Text('Motorcycle • 2023', style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildRow('License Plate', 'RD-8842-NY'),
              _buildRow('Color', 'Sapphire Blue'),
              _buildRow('Insurance Policy', 'Active (POL-90234-GE)'),
              _buildRow('Registration', 'Valid through 2027'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium()),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
'''

# 5. Notifications Module
files['lib/presentation/modules/notifications/controllers/notifications_controller.dart'] = '''import 'package:get/get.dart';
import '../../../../domain/entities/notification_entity.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationEntity>[
    NotificationEntity(
      id: 'notif_1',
      title: '🎉 Payout Transferred',
      message: 'Your payout request of \$250.00 has been sent to your bank.',
      type: NotificationType.earnings,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationEntity(
      id: 'notif_2',
      title: '🔥 High Demand Area',
      message: 'Midtown area is currently surging with +20% bonus per delivery!',
      type: NotificationType.order,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationEntity(
      id: 'notif_3',
      title: '📋 Document Verified',
      message: "Your vehicle insurance certificate has been approved.",
      type: NotificationType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ].obs;

  void markAllAsRead() {
    notifications.clear();
    Get.snackbar('Notifications', 'All notifications cleared');
  }
}
'''

files['lib/presentation/modules/notifications/bindings/notifications_binding.dart'] = '''import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
'''

files['lib/presentation/modules/notifications/views/notifications_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Text('No new notifications', style: AppTextStyles.bodyMedium()),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: AppTextStyles.titleMedium()),
                      Text(
                        Formatters.formatTime(item.timestamp),
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.message, style: AppTextStyles.bodyMedium()),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
'''

# 6. Main Layout View
files['lib/presentation/modules/main_layout/views/main_layout_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../orders/views/order_history_view.dart';
import '../../earnings/views/earnings_view.dart';
import '../../profile/views/profile_view.dart';
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
                label: 'Earnings',
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
'''

# 7. App Pages
files['lib/presentation/routes/app_pages.dart'] = '''import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/main_layout/bindings/main_layout_binding.dart';
import '../modules/main_layout/views/main_layout_view.dart';
import '../modules/orders/views/active_order_view.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/navigation_view.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/documents_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.activeOrder,
      page: () => const ActiveOrderView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.navigation,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.earnings,
      page: () => const EarningsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

