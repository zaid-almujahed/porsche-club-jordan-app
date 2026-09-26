import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/validation/password_rules.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

Future<bool> showCurrentPasswordDialog({
  required BuildContext context,
  required Listenable animation,
  required ValueChanged<String> onChanged,
  required Future<bool> Function(String password) onSubmit,
  required VoidCallback onCancel,
  required bool Function() isSubmitting,
  required String? Function() errorText,
}) async {
  final bool? completed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext context) => _CurrentPasswordDialog(
      animation: animation,
      onChanged: onChanged,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isSubmitting: isSubmitting,
      errorText: errorText,
    ),
  );
  return completed ?? false;
}

class _CurrentPasswordDialog extends StatefulWidget {
  const _CurrentPasswordDialog({
    required this.animation,
    required this.onChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.isSubmitting,
    required this.errorText,
  });

  final Listenable animation;
  final ValueChanged<String> onChanged;
  final Future<bool> Function(String password) onSubmit;
  final VoidCallback onCancel;
  final bool Function() isSubmitting;
  final String? Function() errorText;

  @override
  State<_CurrentPasswordDialog> createState() =>
      _CurrentPasswordDialogState();
}

class _CurrentPasswordDialogState extends State<_CurrentPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final bool completed = await widget.onSubmit(_passwordController.text);
    if (!completed || !context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(true);
  }

  void _cancel(BuildContext context) {
    widget.onCancel();
    Navigator.of(context, rootNavigator: true).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
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
              animation: widget.animation,
              builder: (BuildContext context, Widget? child) {
                final bool submitting = widget.isSubmitting();
                final String? error = widget.errorText();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primaryBright,
                      size: 42,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Confirm Current Password',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Enter your current password before choosing a new one.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PasswordField(
                      controller: _passwordController,
                      label: 'CURRENT PASSWORD',
                      onChanged: widget.onChanged,
                      autofillHint: AutofillHints.password,
                      onSubmitted: (_) => _submit(context),
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
                      label: 'Verify Password',
                      onPressed: submitting ? null : () => _submit(context),
                      isLoading: submitting,
                      height: 58,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryActionButton(
                      label: 'Cancel',
                      onPressed: submitting ? null : () => _cancel(context),
                      height: 54,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

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
  VoidCallback? onCancel,
  String title = 'Create New Password',
  String description = 'Enter the new password twice to confirm it.',
  String submitLabel = 'Reset Password',
  String? cancelLabel,
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
      onCancel: onCancel,
      title: title,
      description: description,
      submitLabel: submitLabel,
      cancelLabel: cancelLabel,
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
    required this.onCancel,
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.cancelLabel,
  });

  final Listenable animation;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final ValueChanged<String> onChanged;
  final Future<bool> Function() onSubmit;
  final bool Function() isSubmitting;
  final String? Function() errorText;
  final VoidCallback? onCancel;
  final String title;
  final String description;
  final String submitLabel;
  final String? cancelLabel;

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final bool completed = await onSubmit();
    if (!completed || !context.mounted) return;
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop(true);
  }

  void _cancel(BuildContext context) {
    onCancel?.call();
    Navigator.of(context, rootNavigator: true).pop(false);
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
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description,
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
                        label: submitLabel,
                        onPressed: submitting ? null : () => _submit(context),
                        isLoading: submitting,
                        height: 58,
                      ),
                      if (cancelLabel != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryActionButton(
                          label: cancelLabel!,
                          onPressed: submitting
                              ? null
                              : () => _cancel(context),
                          height: 54,
                        ),
                      ],
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
    this.autofillHint = AutofillHints.newPassword,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final String autofillHint;
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
          autofillHints: <String>[autofillHint],
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
