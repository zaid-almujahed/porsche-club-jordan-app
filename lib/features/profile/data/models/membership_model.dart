import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/shared/domain/entities/membership.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';

class MembershipModel extends Membership {
  const MembershipModel({
    required super.memberId,
    required super.memberName,
    required super.status,
    required super.validUntil,
    required super.qrImageUrl,
    required super.annualFee,
    super.currency,
  });

  factory MembershipModel.fromJson(
    Map<String, dynamic> source, {
    String? qrImageUrl,
  }) {
    final Object? nested = source['membership'];
    final Map<String, dynamic> json = nested is Map
        ? Map<String, dynamic>.from(nested)
        : source;
    final DateTime? validUntil = firstDateTime(json, const <String>[
      'end_date',
      'valid_until',
      'expires_at',
      'membership_valid_until',
    ]);

    return MembershipModel(
      memberId:
          firstString(json, const <String>[
            'member_id',
            'membership_id',
            'id',
          ]) ??
          '',
      memberName:
          firstString(json, const <String>['member_name', 'name']) ?? '',
      status: _status(json['status'] ?? json['membership_status']),
      validUntil: validUntil,
      qrImageUrl:
          qrImageUrl ??
          firstString(json, const <String>[
            'qr_image_url',
            'qr_url',
            'qr_code',
          ]) ??
          '',
      annualFee: firstDouble(json, const <String>[
        'annual_fee',
        'fee',
        'amount',
      ]),
      currency: firstString(json, const <String>['currency']) ?? 'JOD',
    );
  }

  static MembershipStatus _status(Object? value) {
    final String status = value?.toString().toLowerCase() ?? '';
    if (status.contains('inactive') || status == 'false') {
      return MembershipStatus.inactive;
    }
    if (status == 'active' || status == 'true') {
      return MembershipStatus.active;
    }
    if (status.contains('expired')) return MembershipStatus.expired;
    return MembershipStatus.inactive;
  }
}
