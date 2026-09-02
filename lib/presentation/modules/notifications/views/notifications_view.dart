import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
