import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/membership.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../../../../shared/domain/entities/user.dart';
import '../controllers/membership_payment_controller.dart';
import '../widgets/payment_page_widgets.dart';

class MembershipPaymentPage extends StatelessWidget {
  const MembershipPaymentPage({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onActivated,
  });

  final MembershipPaymentController controller;
  final ValueChanged<Membership> onActivated;
  final Future<void> Function() onClose;

  Future<void> _payAndActivate() async {
    final Membership? membership = await controller.pay();
    if (membership?.status == MembershipStatus.active) {
      onActivated(membership!);
    }
  }

  Future<void> _confirmClose(BuildContext context) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            backgroundColor: AppColors.panelDark,
            surfaceTintColor: AppColors.panelDark,
            title: const Text('Sign out?'),
            content: const Text(
              'Your application is approved, but your membership is not active '
              'until payment is completed. Are you sure you want to sign out?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;
    await onClose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmClose(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => _confirmClose(context),
            icon: const Icon(Icons.close, size: 31),
          ),
        ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const AppAssetImage(
                  path: 'assets/images/membership_payment_texture.png',
                  fit: BoxFit.cover,
                ),
                const ColoredBox(color: Color(0xB3161616)),
                AppPageBody(
                  topPadding: 58,
                  bottomPadding: AppSpacing.xxs,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                    const SizedBox(
                      height: 70,
                      child: AppAssetImage(
                        path: 'assets/images/porsche_club_jordan_logo.png',
                        fit: BoxFit.contain,
                        fallbackIcon: Icons.shield_outlined,
                        fallbackLabel: 'PORSCHE CLUB JORDAN',
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Application Approved',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Complete your payment to activate your Porsche Club '
                      'Jordan membership.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 82),
                    AsyncStateView<Membership>(
                      state: controller.state,
                      onRetry: () => controller.load(force: true),
                      builder: (BuildContext context, Membership membership) {
                        return GradientPanel(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Membership Activation',
                                style: AppTextStyles.pageTitle.copyWith(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const Divider(),
                              const SizedBox(height: 34),
                              MembershipFee(
                                amount: membership.annualFee,
                                currency: membership.currency,
                              ),
                              const SizedBox(height: 34),
                              const Text(
                                'GIFT OR REFERRAL CODE',
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller:
                                          controller.referralCodeController,
                                      style: AppTextStyles.input,
                                      textInputAction: TextInputAction.done,
                                      decoration: const InputDecoration(
                                        hintText: '12-digit code',
                                      ),
                                      onChanged: controller.referralCodeChanged,
                                      onSubmitted: (_) {
                                        controller.applyReferralCode();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: SizedBox(
                                      height: 58,
                                      child: FilledButton(
                                        onPressed: controller.applyReferralCode,
                                        child: Text(
                                          controller.hasAppliedReferralCode
                                              ? 'Applied'
                                              : 'Apply',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 34),
                              const Text(
                                'PAYMENT METHOD',
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              PaymentMethodTile(
                                label: 'Credit / Debit Card\n(MEPS)',
                                selected:
                                    controller.paymentMethod == 'meps_card',
                                onPressed: () =>
                                    controller.selectPaymentMethod('meps_card'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (controller.paymentError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.paymentError!),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    if (controller.paymentNotice != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        controller.paymentNotice!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                    const SizedBox(height: 82),
                    PrimaryActionButton(
                      label: controller.isPaying
                          ? 'Processing Payment...'
                          : 'Start Payment',
                      onPressed:
                          controller.isPaying || !controller.state.hasData
                          ? null
                          : _payAndActivate,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Membership access begins only after the backend '
                      'confirms the payment or activation code.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
