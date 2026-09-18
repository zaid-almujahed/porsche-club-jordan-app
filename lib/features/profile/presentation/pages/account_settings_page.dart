import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/profile_controller.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({
    super.key,
    required this.controller,
    required this.onAccountDeleted,
  });

  final ProfileController controller;
  final VoidCallback onAccountDeleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(title: 'Account Settings', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: 36,
            bottomPadding: 144,
            child: AsyncStateView<User>(
              state: controller.profile,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, User user) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Credentials',
                      style: _AccountSettingsStyles.sectionTitle,
                    ),
                    const SizedBox(height: 18),
                    _CredentialsPanel(
                      user: user,
                      onPhonePressed: () =>
                          _editPhone(context, user.phoneNumber),
                      onPasswordPressed: () => _passwordHelp(context),
                    ),
                    const SizedBox(height: 45),
                    const Text(
                      'Security',
                      style: _AccountSettingsStyles.sectionTitle,
                    ),
                    const SizedBox(height: 18),
                    _DeleteAccountPanel(
                      onPressed: controller.isPerformingAccountAction
                          ? null
                          : () => _deleteAccount(context),
                    ),
                    if (controller.actionError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.actionError!),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _passwordHelp(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset password'),
        content: const Text(
          'For security, password changes use the Forgot Password flow on the '
          'sign-in screen.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPhone(BuildContext context, String current) async {
    final String? value = await _showValueDialog(
      context,
      title: 'Phone Number',
      currentValue: current,
      keyboardType: TextInputType.phone,
    );
    if (value != null) await controller.updatePhoneNumber(value);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Deleting your account permanently removes your club profile and '
          'cancels your membership. If you change your mind later, you will '
          'need to submit a new membership application and wait for it to be '
          'reviewed again. This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && await controller.deleteAccount()) {
      onAccountDeleted();
    }
  }
}

Future<String?> _showValueDialog(
  BuildContext context, {
  required String title,
  required String currentValue,
  required TextInputType keyboardType,
}) async {
  final TextEditingController fieldController = TextEditingController(
    text: currentValue,
  );
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: fieldController,
        keyboardType: keyboardType,
        autofocus: true,
      ),
      actions: <Widget>[
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => context.pop(fieldController.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  fieldController.dispose();
  return result;
}

class _CredentialsPanel extends StatelessWidget {
  const _CredentialsPanel({
    required this.user,
    required this.onPhonePressed,
    required this.onPasswordPressed,
  });

  final User user;
  final VoidCallback onPhonePressed;
  final VoidCallback onPasswordPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _AccountSettingsStyles.panelDecoration,
      child: Column(
        children: <Widget>[
          _CredentialRow(
            label: 'Email Address',
            value: user.email,
            onPressed: null,
            trailingIcon: Icons.lock_outline,
          ),
          _CredentialRow(
            label: 'Phone Number',
            value: user.phoneNumber,
            onPressed: onPhonePressed,
          ),
          _CredentialRow(
            label: 'Password',
            value: '••••••••••',
            isPassword: true,
            showDivider: false,
            onPressed: onPasswordPressed,
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    this.isPassword = false,
    this.showDivider = true,
    this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final bool isPassword;
  final bool showDivider;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.border, width: 1.1),
                )
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: _AccountSettingsStyles.credentialLabel),
                  const SizedBox(height: 4.5),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isPassword
                        ? _AccountSettingsStyles.passwordValue
                        : _AccountSettingsStyles.credentialValue,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              trailingIcon ?? Icons.chevron_right_rounded,
              size: 28,
              color: onPressed == null
                  ? AppColors.textMuted
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountPanel extends StatelessWidget {
  const _DeleteAccountPanel({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: _AccountSettingsStyles.panelDecoration,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Delete Account',
                      style: _AccountSettingsStyles.deleteTitle,
                    ),
                  ],
                ),
                SizedBox(height: 4.5),
                Text(
                  'Permanently remove your club data and access.',
                  style: _AccountSettingsStyles.deleteDescription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _AccountSettingsStyles {
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 27,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const BoxDecoration panelDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0x331A1A1A),
        Color(0xCC000000),
        Color(0x8C000000),
        Color(0x191A1A1A),
      ],
    ),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.border, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  );

  static const TextStyle credentialLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle credentialValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Color(0xFFC8C6C5),
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle passwordValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Color(0xFFC8C6C5),
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 2.7,
  );

  static const TextStyle deleteTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.primary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle deleteDescription = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.35,
  );
}
