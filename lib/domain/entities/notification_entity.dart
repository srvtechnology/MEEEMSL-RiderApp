import 'package:equatable/equatable.dart';

enum NotificationType { order, earnings, system, safety }

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, message, type, timestamp, isRead];
}
