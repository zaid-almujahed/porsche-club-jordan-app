import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/errors/app_exception.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';
import 'package:pcj_v4/shared/widgets/otp_verification_dialog.dart';
import 'package:pcj_v4/shared/widgets/password_reset_dialog.dart';

import '../widgets/inline_link.dart';
import '../widgets/sign_in_field.dart';
import '../controllers/auth_controller.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key, required this.controller});

  final AuthController controller;

  Future<void> _signIn(BuildContext context) async {
    final bool otpWasRequested = await controller.requestSignInOtp();
    if (!context.mounted || !otpWasRequested) return;

    final String? email = controller.signInOtpEmail;
    if (email == null) return;

    final bool wasVerified = await showOtpVerificationDialog(
      context: context,
      animation: controller,
      email: email,
      otpController: controller.otpController,
      onOtpChanged: controller.onOtpChanged,
      onVerify: controller.verifySignInOtp,
      onResend: controller.resendSignInOtp,
      onChangeEmail: controller.cancelSignInOtp,
      isVerifying: () => controller.isVerifyingSignInOtp,
      isResending: () => controller.isResendingSignInOtp,
      errorText: () => controller.otpError,
      instructions: 'Enter it below to complete sign in.',
      verifyButtonLabel: 'Verify and Sign In',
    );
    if (!context.mounted || !wasVerified) return;

    // Publishing the completed session wakes go_router's refreshListenable.
    // Its redirect is the single authority that selects home, application
    // status, or membership payment. A second context.go here can race that
    // redirect and was the source of the post-login black screen.
    controller.completeSignIn();
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final bool otpWasRequested = await controller.requestPasswordReset();
    if (!context.mounted || !otpWasRequested) return;
    final String? email = controller.passwordResetEmail;
    if (email == null) return;

    final bool otpWasVerified = await showOtpVerificationDialog(
      context: context,
      animation: controller,
      email: email,
      otpController: controller.passwordResetOtpController,
      onOtpChanged: controller.onPasswordResetOtpChanged,
      onVerify: controller.verifyPasswordResetOtp,
      onResend: controller.resendPasswordResetOtp,
      onChangeEmail: controller.cancelPasswordReset,
      isVerifying: () => controller.isVerifyingPasswordResetOtp,
      isResending: () => controller.isResendingPasswordResetOtp,
      errorText: () => controller.passwordResetError,
      instructions: 'Enter it below to continue resetting your password.',
      verifyButtonLabel: 'Verify Code',
    );
    if (!context.mounted || !otpWasVerified) return;

    final bool passwordWasReset = await showNewPasswordDialog(
      context: context,
      animation: controller,
      passwordController: controller.newPasswordController,
      confirmationController: controller.confirmNewPasswordController,
      onChanged: controller.onNewPasswordChanged,
      onSubmit: controller.resetPassword,
      isSubmitting: () => controller.isResettingPassword,
      errorText: () => controller.passwordResetError,
    );
    if (!context.mounted || !passwordWasReset) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully. You can now sign in.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      //Safe area guarantees that the page is visible if the device has a camera notch
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) => SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double horizontalPadding = AppLayout.horizontalPadding(
                constraints.maxWidth,
              );
              final double verticalPadding = constraints.maxHeight < 700
                  ? AppSpacing.xl
                  : AppSpacing.xxl;
              final double minimumHeight =
                  constraints.maxHeight > verticalPadding * 2
                  ? constraints.maxHeight - verticalPadding * 2
                  : 0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minimumHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ConstrainedBox(
                              //LOGO
                              constraints: const BoxConstraints(maxHeight: 160),
                              child: Image.asset(
                                'assets/images/porsche_club_jordan_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) {
                                      return const SizedBox(
                                        height: 112,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: AppColors.textFaint,
                                          size: 42,
                                        ),
                                      );
                                    },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            //Sign in fields
                            SignInField(
                              controller: controller.identifierController,
                              label: 'EMAIL ADDRESS',
                              hintText: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: <String>[AutofillHints.username],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SignInField(
                              controller: controller.passwordController,
                              label: 'PASSWORD',
                              hintText: 'Enter your password',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const <String>[
                                AutofillHints.password,
                              ],
                              labelTrailing: InlineLink(
                                label: 'Forgot Password?',
                                onPressed: controller.isRequestingPasswordReset
                                    ? null
                                    : () => _forgotPassword(context),
                              ),
                              onSubmitted: (_) => _signIn(context),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            if (controller.validationError != null ||
                                controller.session.hasError) ...<Widget>[
                              Text(
                                controller.validationError ??
                                    readableError(controller.session.error!),
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],

                            //Action Buttons
                            PrimaryActionButton(
                              label: 'Sign In',
                              onPressed: controller.isRequestingSignInOtp
                                  ? null
                                  : () => _signIn(context),
                              isLoading: controller.isRequestingSignInOtp,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xxs,
                              runSpacing: AppSpacing.xs,
                              children: <Widget>[
                                Text(
                                  "Don't have an account?",
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                InlineLink(
                                  label: 'Join the Club',
                                  onPressed: () =>
                                      context.push(AppRoutes.registerPersonal),
                                  textStyle: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
