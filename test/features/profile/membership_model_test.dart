import 'package:flutter_test/flutter_test.dart';
import 'package:pcj_v4/features/profile/data/models/membership_model.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';

void main() {
  test('does not invent a membership fee or validity date', () {
    final MembershipModel membership = MembershipModel.fromJson(
      const <String, dynamic>{'status': 'APPROVED'},
    );

    expect(membership.status, MembershipStatus.inactive);
    expect(membership.annualFee, isNull);
    expect(membership.validUntil, isNull);
  });

  test('parses active membership values supplied by the backend', () {
    final MembershipModel membership = MembershipModel.fromJson(
      const <String, dynamic>{
        'status': 'ACTIVE',
        'annual_fee': '175',
        'currency': 'JOD',
        'end_date': '2027-09-18',
      },
    );

    expect(membership.status, MembershipStatus.active);
    expect(membership.annualFee, 175);
    expect(membership.currency, 'JOD');
    expect(membership.validUntil, DateTime(2027, 9, 18));
  });
}
