import '../entities/member_notification.dart';

abstract interface class NotificationsRepository {
  Future<List<MemberNotification>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> registerDeviceToken(String token);
}
