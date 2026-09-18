import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

BoxDecoration profilePanelDecoration({
  required double radius,
  bool includeShadow = false,
}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0x331A1A1A),
        Color(0xCC000000),
        Color(0x8C000000),
        Color(0x191A1A1A),
      ],
    ),
    border: Border.all(color: const Color(0x33FBFCFF), width: 1.13),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: includeShadow
        ? const <BoxShadow>[
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 56.41,
              offset: Offset(0, 28.21),
              spreadRadius: -13.54,
            ),
          ]
        : null,
  );
}

class ProfileMemberCard extends StatelessWidget {
  const ProfileMemberCard({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  final User user;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final bool active = user.membershipStatus == MembershipStatus.active;
    final Color statusColor = switch (user.membershipStatus) {
      MembershipStatus.active => AppColors.success,
      MembershipStatus.inactive => AppColors.warning,
      MembershipStatus.expired => AppColors.danger,
    };
    final String statusLabel = user.membershipStatus.name.toUpperCase();
    final String validity = user.membershipValidUntil == null
        ? 'Membership date unavailable'
        : 'Valid until ${AppFormatters.date(user.membershipValidUntil!)}';

    return Container(
      height: 249,
      padding: const EdgeInsets.fromLTRB(28, 29, 28, 27),
      decoration: profilePanelDecoration(
        radius: AppRadii.medium,
        includeShadow: true,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 290;
          final double avatarSize = compact ? 80 : 108;
          final double editSize = compact ? 40 : 45;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.6),
                        width: 2.26,
                      ),
                    ),
                    child: AppAssetImage(
                      path: user.avatarUrl ?? '',
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadii.pill),
                      ),
                      fallbackIcon: Icons.person_outline,
                    ),
                  ),
                  SizedBox(width: compact ? 12 : 27),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: compact ? 10 : 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'MEMBER STATUS',
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.28,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              letterSpacing: 2.26,
                            ),
                          ),
                          const SizedBox(height: 4.5),
                          Row(
                            children: <Widget>[
                              Icon(
                                active
                                    ? Icons.verified_user_outlined
                                    : Icons.info_outline,
                                size: 18,
                                color: statusColor,
                              ),
                              const SizedBox(width: 5.5),
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 14.67,
                                    fontWeight: FontWeight.w600,
                                    height: 1.23,
                                    letterSpacing: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.5),
                          Text(
                            '• $validity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textFaint,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Semantics(
                    button: true,
                    label: 'Edit profile',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Ink(
                        width: editSize,
                        height: editSize,
                        decoration: profilePanelDecoration(
                          radius: AppRadii.pill,
                        ),
                        child: InkWell(
                          onTap: onEditPressed,
                          customBorder: const CircleBorder(),
                          child: const Center(
                            child: Icon(Icons.edit_outlined, size: 19),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: _ProfileMemberValue(
                      label: 'MEMBER NAME',
                      value: user.name,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: _ProfileMemberValue(
                      label: 'ID NUMBER',
                      value: user.memberId ?? '—',
                      alignEnd: true,
                      mutedValue: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileMemberValue extends StatelessWidget {
  const _ProfileMemberValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.mutedValue = false,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final bool mutedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Color(0x99E7BCB8),
            fontSize: 11.28,
            fontWeight: FontWeight.w600,
            height: 1.5,
            letterSpacing: 2.26,
          ),
        ),
        const SizedBox(height: 4.5),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: mutedValue ? AppColors.textFaint : AppColors.textSecondary,
            fontSize: mutedValue ? 18 : 27,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: mutedValue ? 2.26 : 0,
          ),
        ),
      ],
    );
  }
}

class AccountOptionsPanel extends StatelessWidget {
  const AccountOptionsPanel({
    super.key,
    required this.onMembershipPressed,
    required this.onSettingsPressed,
    required this.onSupportPressed,
    required this.onLogOutPressed,
  });

  final VoidCallback onMembershipPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onSupportPressed;
  final VoidCallback onLogOutPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: profilePanelDecoration(radius: AppRadii.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 18),
            child: Text(
              'Account Options',
              style: AppTextStyles.pageTitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 27,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ColoredBox(
            color: const Color(0xFF181818),
            child: Column(
              children: <Widget>[
                AccountOptionTile(
                  icon: Icons.credit_card_outlined,
                  label: 'Manage Membership',
                  onTap: onMembershipPressed,
                ),
                AccountOptionTile(
                  icon: Icons.settings_outlined,
                  label: 'Account Settings',
                  onTap: onSettingsPressed,
                ),
                AccountOptionTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: onSupportPressed,
                ),
                AccountOptionTile(
                  icon: Icons.logout,
                  label: 'Log Out',
                  showDivider: false,
                  onTap: onLogOutPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountOptionTile extends StatelessWidget {
  const AccountOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 27),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  )
                : null,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileFeatureCard extends StatelessWidget {
  const ProfileFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundIcon,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData backgroundIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        height: 217,
        decoration: profilePanelDecoration(radius: AppRadii.medium),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(27),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    backgroundIcon,
                    size: 58,
                    color: const Color(0x262A2A2A),
                  ),
                ),
                const Positioned(
                  right: 0,
                  top: 4,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.pageTitle.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
