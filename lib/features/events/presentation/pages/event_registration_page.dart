import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/widgets/app_dialog.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/event_registration_controller.dart';
import '../widgets/event_registration_widgets.dart';

class EventRegistrationPage extends StatelessWidget {
  const EventRegistrationPage({
    super.key,
    required this.controller,
    required this.onRegistered,
  });

  final EventRegistrationController controller;
  final ValueChanged<EventBooking> onRegistered;

  Future<void> _submit(BuildContext context, Event event) async {
    if (controller.guestCount > 0 && !controller.guestNoticeAccepted) {
      final bool acknowledged = await showAppConfirmationDialog(
        context: context,
        title: 'Guest Admission Notice',
        message:
            'For security and capacity control, only guests included in this '
            'registration will be permitted to enter the event. Please '
            'confirm that the selected guest count is accurate.',
        confirmLabel: 'I Understand',
        cancelLabel: 'Review Guests',
        icon: Icons.groups_2_outlined,
      );
      if (!acknowledged || !context.mounted) return;
      controller.acceptGuestNotice();
    }

    final EventBooking? booking = await controller.submit();
    if (booking == null || !context.mounted) return;
    final bool paymentComplete = booking.isPaymentComplete;
    await showAppMessageDialog(
      context: context,
      title: paymentComplete ? 'Registration Successful' : 'RSVP Submitted',
      message: paymentComplete
          ? controller.guestCount == 0
                ? 'Your place at ${event.title} is confirmed.'
                : 'Your place and ${controller.guestCount} registered '
                      '${controller.guestCount == 1 ? 'guest' : 'guests'} '
                      'are confirmed.'
          : 'Your RSVP was created, but payment is not yet confirmed. Your '
                'place is not treated as paid until the backend confirms the '
                'payment.',
      buttonLabel: 'View My Events',
      icon: paymentComplete
          ? Icons.check_circle_outline
          : Icons.hourglass_top_rounded,
      iconColor: paymentComplete ? AppColors.success : AppColors.warning,
    );
    if (context.mounted) onRegistered(booking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Registration', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            child: AsyncStateView<Event>(
              state: controller.eventState,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, Event event) {
                final bool allowsGuests = event.guestLimit > 0;
                final bool hasRegistrationCost =
                    controller.basePrice > 0 || controller.guestsTotal > 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      AppFormatters.dateAndTime(event.startsAt).toUpperCase(),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      event.title.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 54,
                        fontWeight: FontWeight.w400,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 52),
                    BasePriceBanner(
                      amount: controller.basePrice,
                      currency: event.currency,
                    ),
                    if (allowsGuests) ...<Widget>[
                      const SizedBox(height: 48),
                      Text(
                        'Additional Guests',
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 28),
                      GuestPanel(
                        count: controller.guestCount,
                        limit: event.guestLimit,
                        guestFee: controller.guestPrice,
                        currency: event.currency,
                        onIncrement: controller.incrementGuests,
                        onDecrement: controller.decrementGuests,
                      ),
                    ],
                    if (hasRegistrationCost) ...<Widget>[
                      const SizedBox(height: 54),
                      PriceSummary(
                        basePrice: controller.basePrice,
                        guestsPrice: controller.guestsTotal,
                        total: controller.total,
                        currency: event.currency,
                        showGuests: allowsGuests,
                      ),
                    ],
                    if (controller.submissionError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.submissionError!),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    PrimaryActionButton(
                      label: event.isAtCapacity
                          ? 'Event At Capacity'
                          : controller.isSubmitting
                          ? 'Processing...'
                          : 'Submit RSVP',
                      onPressed: controller.isSubmitting || event.isAtCapacity
                          ? null
                          : () => _submit(context, event),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
