import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/registration_controller.dart';
import '../widgets/form_widgets.dart';
import '../widgets/password_registration_widgets.dart';

class RegistrationPasswordPage extends StatelessWidget {
  const RegistrationPasswordPage({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  final RegistrationController controller;
  final VoidCallback onSubmitted;

  Future<void> _submit(BuildContext context) async {
    final bool wasSubmitted = await controller.submitApplication();
    if (!wasSubmitted || !context.mounted) return;

    final bool wasVerified = await showRegistrationOtpDialog(
      context: context,
      controller: controller,
    );

    if (wasVerified && controller.isEmailVerified && context.mounted) {
      onSubmitted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Membership Application'),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.lg,
            bottomPadding: AppSpacing.section,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const ProgressHeader(
                  pageNo: '04',
                  title: 'Account Setup',
                  desc:
                      'Enter the email address you will use to sign in and '
                      'create a secure password. We will verify your email '
                      'before completing the application.',
                ),
                const SizedBox(height: AppSpacing.section),
                RegistrationFormPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RegistrationTextField(
                        controller: controller.emailController,
                        label: 'EMAIL ADDRESS',
                        hintText: 'e.g. name@domain.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        onChanged: controller.onEmailChanged,
                      ),
                      const SizedBox(height: 26),
                      RegistrationTextField(
                        controller: controller.passwordController,
                        label: 'ENTER PASSWORD',
                        hintText: 'Enter your password',
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        obscureText: true,
                        onChanged: controller.onPasswordChanged,
                      ),
                      const SizedBox(height: 26),
                      RegistrationTextField(
                        controller: controller.confirmPasswordController,
                        label: 'RE-ENTER PASSWORD',
                        hintText: 'Re-enter your password',
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        obscureText: true,
                        onChanged: controller.onPasswordConfirmationChanged,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'PASSWORD MUST INCLUDE',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRequirement(
                        label: 'At least 8 characters',
                        isMet: controller.hasMinimumPasswordLength,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildRequirement(
                        label: 'At least one number',
                        isMet: controller.hasPasswordNumber,
                      ),
                    ],
                  ),
                ),
                if (controller.passwordFormError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    controller.passwordFormError!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                if (controller.submissionError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    controller.submissionError!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.section),
                RegistrationSubmitActions(
                  isSubmitting: controller.isSubmitting,
                  onBack: () => context.go(AppRoutes.registerReview),
                  onSubmit: () => _submit(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequirement({
    required String label,
    required bool isMet,
  }) {
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
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
