import 'user.dart';

class Membership {
  const Membership({
    required this.memberId,
    required this.memberName,
    required this.status,
    required this.validUntil,
    required this.qrImageUrl,
    required this.annualFee,
    this.currency = 'JOD',
  });

  final String memberId;
  final String memberName;
  final MembershipStatus status;
  /// Null until payment/activation assigns an end date.
  final DateTime? validUntil;
  final String qrImageUrl;
  String get qrToken => qrImageUrl;
  final double? annualFee;
  final String currency;
}
