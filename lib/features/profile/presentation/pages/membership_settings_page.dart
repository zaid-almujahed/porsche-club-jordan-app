import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/membership.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/membership_controller.dart';

class MembershipSettingsPage extends StatelessWidget {
  const MembershipSettingsPage({super.key, required this.controller});

  final MembershipController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Membership', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) => AppPageBody(
          topPadding: 40,
          bottomPadding: 140,
          child: AsyncStateView<Membership>(
            state: controller.state,
            onRetry: () => controller.load(force: true),
            builder: (BuildContext context, Membership membership) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ValidityPanel(membership: membership),
                  const SizedBox(height: 36),
                  _MembershipCardPanel(membership: membership),
                  const SizedBox(height: 40),
                  const Text(
                    'Manage Membership',
                    style: _MembershipStyles.manageTitle,
                  ),
                  const SizedBox(height: 27),
                  _RenewMembershipTile(
                    isLoading: controller.isRenewing,
                    onPressed: controller.isRenewing ? null : controller.renew,
                  ),
                  if (controller.renewalError != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      readableError(controller.renewalError!),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ValidityPanel extends StatelessWidget {
  const _ValidityPanel({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (membership.status) {
      MembershipStatus.active => AppColors.success,
      MembershipStatus.inactive => AppColors.warning,
      MembershipStatus.expired => AppColors.danger,
    };

    return DecoratedBox(
      decoration: _MembershipStyles.validityDecoration,
      child: Padding(
        padding: const EdgeInsets.all(27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.pill),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13.5,
                  vertical: 4.5,
                ),
                child: Text(
                  '${membership.status.name.toUpperCase()} MEMBER',
                  style: _MembershipStyles.activeMember,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              membership.validUntil == null
                  ? 'Validity date pending'
                  : 'Valid until ${AppFormatters.date(membership.validUntil!)}',
              style: _MembershipStyles.validity,
            ),
          ],
        ),
      ),
    );
  }
}

class _MembershipCardPanel extends StatelessWidget {
  const _MembershipCardPanel({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(36, 44, 36, 20),
      decoration: _MembershipStyles.membershipPanelDecoration,
      child: Column(
        children: <Widget>[
          _DigitalMemberCard(membership: membership),
          const SizedBox(height: 44),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 241),
            child: AspectRatio(
              aspectRatio: 241 / 251,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                child: membership.qrToken.trim().isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 64,
                          color: Colors.black,
                        ),
                      )
                    : QrImageView(
                        data: membership.qrToken,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'SCAN TO VERIFY MEMBERSHIP',
              textAlign: TextAlign.center,
              style: _MembershipStyles.scanLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitalMemberCard extends StatelessWidget {
  const _DigitalMemberCard({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 185,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(27),
      decoration: _MembershipStyles.digitalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('PORSCHE', style: _MembershipStyles.brand),
                    Text('Club Jordan', style: _MembershipStyles.clubName),
                  ],
                ),
              ),
              const Icon(
                Icons.directions_car,
                size: 21,
                color: AppColors.primary,
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: _CardValue(
                  label: 'MEMBER NAME',
                  value: membership.memberName,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _CardValue(
                    label: 'MEMBER ID',
                    value: membership.memberId,
                    compact: true,
                    alignEnd: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardValue extends StatelessWidget {
  const _CardValue({
    required this.label,
    required this.value,
    this.compact = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool compact;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: _MembershipStyles.cardLabel),
        const SizedBox(height: 3.5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: compact
              ? _MembershipStyles.cardId
              : _MembershipStyles.cardName,
        ),
      ],
    );
  }
}

class _RenewMembershipTile extends StatelessWidget {
  const _RenewMembershipTile({required this.isLoading, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _MembershipStyles.renewDecoration,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(22.5),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 40,
                height: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF201F1F),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.autorenew,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isLoading ? 'Renewing...' : 'Renew Membership',
                      style: _MembershipStyles.renewTitle,
                    ),
                    SizedBox(height: 4.5),
                    Text(
                      'Extend your access for another year',
                      style: _MembershipStyles.renewDescription,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Color(0xFFFFC0C0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _MembershipStyles {
  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: <Color>[
      Color(0x331A1A1A),
      Color(0xCC000000),
      Color(0x8C000000),
      Color(0x191A1A1A),
    ],
  );

  static const BoxDecoration validityDecoration = BoxDecoration(
    gradient: panelGradient,
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(13.5)),
  );

  static const BoxDecoration membershipPanelDecoration = BoxDecoration(
    color: Color(0xFF181817),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
  );

  static const BoxDecoration digitalCardDecoration = BoxDecoration(
    gradient: panelGradient,
    borderRadius: BorderRadius.all(Radius.circular(9)),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x7F000000),
        blurRadius: 34,
        offset: Offset(0, 11),
      ),
    ],
  );

  static const BoxDecoration renewDecoration = BoxDecoration(
    gradient: panelGradient,
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(13.5)),
  );

  static const TextStyle activeMember = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.panel,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 0.68,
  );

  static const TextStyle validity = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 31.5,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle brand = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 27,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 2.7,
  );

  static const TextStyle clubName = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle cardLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle cardName = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle cardId = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle scanLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle manageTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 27,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle renewTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle renewDescription = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );
}
