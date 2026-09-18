import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/validation/password_rules.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

/// Displays the second step of the forgot-password flow after OTP validation.
Future<bool> showNewPasswordDialog({
  required BuildContext context,
  required Listenable animation,
  required TextEditingController passwordController,
  required TextEditingController confirmationController,
  required ValueChanged<String> onChanged,
  required Future<bool> Function() onSubmit,
  required bool Function() isSubmitting,
  required String? Function() errorText,
}) async {
  final bool? completed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext context) => _NewPasswordDialog(
      animation: animation,
      passwordController: passwordController,
      confirmationController: confirmationController,
      onChanged: onChanged,
      onSubmit: onSubmit,
      isSubmitting: isSubmitting,
      errorText: errorText,
    ),
  );
  return completed ?? false;
}

class _NewPasswordDialog extends StatelessWidget {
  const _NewPasswordDialog({
    required this.animation,
    required this.passwordController,
    required this.confirmationController,
    required this.onChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.errorText,
  });

  final Listenable animation;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final ValueChanged<String> onChanged;
  final Future<bool> Function() onSubmit;
  final bool Function() isSubmitting;
  final String? Function() errorText;

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final bool completed = await onSubmit();
    if (!completed || !context.mounted) return;
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.panelDark,
        surfaceTintColor: AppColors.panelDark,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.panelDark,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final String password = passwordController.text;
                  final bool submitting = isSubmitting();
                  final String? error = errorText();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_reset_outlined,
                        color: AppColors.primaryBright,
                        size: 42,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Create New Password',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Enter the new password twice to confirm it.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _PasswordField(
                        controller: passwordController,
                        label: 'NEW PASSWORD',
                        onChanged: onChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PasswordField(
                        controller: confirmationController,
                        label: 'RE-ENTER PASSWORD',
                        onChanged: onChanged,
                        onSubmitted: (_) => _submit(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _Requirement(
                        label:
                            'At least ${PasswordRules.minimumLength} characters',
                        isMet: PasswordRules.hasMinimumLength(password),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _Requirement(
                        label: 'At least one number',
                        isMet: PasswordRules.hasNumber(password),
                      ),
                      if (error != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryActionButton(
                        label: 'Reset Password',
                        onPressed: submitting ? null : () => _submit(context),
                        isLoading: submitting,
                        height: 58,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 12)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: true,
          textInputAction:
              onSubmitted == null ? TextInputAction.next : TextInputAction.done,
          autofillHints: const <String>[AutofillHints.newPassword],
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: AppTextStyles.input,
          cursorColor: AppColors.primaryBright,
          decoration: const InputDecoration(
            hintText: 'Enter password',
            filled: false,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final Color color = isMet ? AppColors.success : AppColors.textFaint;
    return Row(
      children: <Widget>[
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: AppTextStyles.body.copyWith(color: color)),
        ),
      ],
    );
  }
}
