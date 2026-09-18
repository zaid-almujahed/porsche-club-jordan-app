import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/features/notifications/domain/entities/member_notification.dart';

class MemberNotificationModel extends MemberNotification {
  const MemberNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.sentAt,
  });

  factory MemberNotificationModel.fromJson(Map<String, dynamic> json) {
    return MemberNotificationModel(
      id: firstString(json, const <String>['id']) ?? '',
      title: firstString(json, const <String>['title']) ?? '',
      message: firstString(json, const <String>['message']) ?? '',
      type: _type(firstString(json, const <String>['type'])),
      isRead: json['is_read'] == true,
      sentAt:
          firstDateTime(json, const <String>['sent_date']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static MemberNotificationType _type(String? value) {
    return switch (value?.toUpperCase()) {
      'EVENT' => MemberNotificationType.event,
      'MEMBERSHIP' => MemberNotificationType.membership,
      'MARKETPLACE' => MemberNotificationType.marketplace,
      'OFFER' => MemberNotificationType.offer,
      _ => MemberNotificationType.system,
    };
  }
}
