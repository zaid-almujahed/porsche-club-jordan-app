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

  MemberNotification copyWith({bool? isRead}) {
    return MemberNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
    );
  }
}
