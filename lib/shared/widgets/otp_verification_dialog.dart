import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

Future<bool> showOtpVerificationDialog({
  required BuildContext context,
  required Listenable animation,
  required String email,
  required TextEditingController otpController,
  required ValueChanged<String> onOtpChanged,
  required Future<bool> Function() onVerify,
  required Future<bool> Function() onResend,
  required VoidCallback onChangeEmail,
  required bool Function() isVerifying,
  required bool Function() isResending,
  required String? Function() errorText,
  required String instructions,
  String verifyButtonLabel = 'Verify Email',
}) async {
  final bool? wasVerified = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return OtpVerificationDialog(
        animation: animation,
        email: email,
        otpController: otpController,
        onOtpChanged: onOtpChanged,
        onVerify: onVerify,
        onResend: onResend,
        onChangeEmail: onChangeEmail,
        isVerifying: isVerifying,
        isResending: isResending,
        errorText: errorText,
        instructions: instructions,
        verifyButtonLabel: verifyButtonLabel,
      );
    },
  );

  return wasVerified ?? false;
}

class OtpVerificationDialog extends StatefulWidget {
  const OtpVerificationDialog({
    super.key,
    required this.animation,
    required this.email,
    required this.otpController,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
    required this.onChangeEmail,
    required this.isVerifying,
    required this.isResending,
    required this.errorText,
    required this.instructions,
    required this.verifyButtonLabel,
  });

  final Listenable animation;
  final String email;
  final TextEditingController otpController;
  final ValueChanged<String> onOtpChanged;
  final Future<bool> Function() onVerify;
  final Future<bool> Function() onResend;
  final VoidCallback onChangeEmail;
  final bool Function() isVerifying;
  final bool Function() isResending;
  final String? Function() errorText;
  final String instructions;
  final String verifyButtonLabel;

  @override
  State<OtpVerificationDialog> createState() =>
      _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  static const Duration _otpLifetime = Duration(minutes: 5);
  static const Duration _resendCooldown = Duration(minutes: 1);

  late DateTime _expiresAt;
  late DateTime _resendAvailableAt;
  late final Timer _ticker;
  String? _notice;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _restartTimers();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  int get _otpSecondsRemaining => _remainingSeconds(_expiresAt);

  int get _resendSecondsRemaining => _remainingSeconds(_resendAvailableAt);

  bool get _hasExpired => _otpSecondsRemaining == 0;

  void _restartTimers() {
    final DateTime now = DateTime.now();
    _expiresAt = now.add(_otpLifetime);
    _resendAvailableAt = now.add(_resendCooldown);
  }

  int _remainingSeconds(DateTime deadline) {
    final int milliseconds = deadline.difference(DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) return 0;
    return (milliseconds / Duration.millisecondsPerSecond).ceil();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    if (_hasExpired) {
      setState(() {
        _notice = 'This code has expired. Request a new code to continue.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    final bool wasVerified = await widget.onVerify();
    if (!wasVerified || !mounted) return;

    setState(() => _allowPop = true);
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop(true);
  }

  Future<void> _resend() async {
    if (_resendSecondsRemaining > 0) return;

    FocusScope.of(context).unfocus();
    final bool wasSent = await widget.onResend();
    if (!wasSent || !mounted) return;

    setState(() {
      _restartTimers();
      _notice = 'A new verification code was sent.';
    });
  }

  void _changeEmail() {
    widget.onChangeEmail();
    setState(() => _allowPop = true);
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
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
                animation: widget.animation,
                builder: (BuildContext context, Widget? child) {
                  final bool verifying = widget.isVerifying();
                  final bool resending = widget.isResending();
                  final bool isBusy = verifying || resending;
                  final String? error = widget.errorText();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.mark_email_read_outlined,
                        color: AppColors.primaryBright,
                        size: 42,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Verify Your Email',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'We sent a one-time verification code to\n'
                        '${widget.email}.\n${widget.instructions}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.panelDark,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppRadii.medium),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.timer_outlined,
                              size: 19,
                              color: _hasExpired
                                  ? AppColors.danger
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _hasExpired
                                  ? 'Code expired'
                                  : 'Code expires in '
                                        '${_formatDuration(_otpSecondsRemaining)}',
                              style: AppTextStyles.body.copyWith(
                                color: _hasExpired
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text.rich(
                        const TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text: 'VERIFICATION CODE'),
                            TextSpan(
                              text: '  *',
                              style: TextStyle(
                                color: AppColors.required,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        style: AppTextStyles.label.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: widget.otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[
                          AutofillHints.oneTimeCode,
                        ],
                        onChanged: widget.onOtpChanged,
                        onFieldSubmitted: (_) => _verify(),
                        style: AppTextStyles.input,
                        cursorColor: AppColors.primaryBright,
                        decoration: const InputDecoration(
                          hintText: 'Enter the code from your email',
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
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
                      ] else if (_notice != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _notice!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: _hasExpired
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryActionButton(
                        label: widget.verifyButtonLabel,
                        onPressed: _hasExpired || isBusy ? null : _verify,
                        isLoading: verifying,
                        height: 58,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _resendSecondsRemaining == 0 && !isBusy
                            ? _resend
                            : null,
                        child: Text(
                          resending
                              ? 'Sending...'
                              : _resendSecondsRemaining > 0
                              ? 'Resend available in '
                                    '${_formatDuration(_resendSecondsRemaining)}'
                              : 'Resend OTP',
                          style: AppTextStyles.body.copyWith(
                            color: _resendSecondsRemaining == 0 && !isBusy
                                ? AppColors.primaryBright
                                : AppColors.textFaint,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      TextButton.icon(
                        onPressed: isBusy ? null : _changeEmail,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Go Back and Change Email'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          textStyle: AppTextStyles.body,
                        ),
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
