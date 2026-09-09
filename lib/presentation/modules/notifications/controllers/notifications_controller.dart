import 'package:get/get.dart';
import '../../../../domain/entities/notification_entity.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationEntity>[
    NotificationEntity(
      id: 'notif_1',
      title: '🎉 Payout Transferred',
      message: 'Your payout request of Nle 250.00 has been sent to your bank.',
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
