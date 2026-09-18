enum MemberNotificationType { event, membership, marketplace, offer, system }

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.sentAt,
  });

  final String id;
  final String title;
  final String message;
  final MemberNotificationType type;
  final bool isRead;
  final DateTime sentAt;
}
