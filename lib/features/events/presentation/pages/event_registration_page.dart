import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';
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
      final bool acknowledged =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              backgroundColor: AppColors.panelDark,
              surfaceTintColor: AppColors.panelDark,
              title: const Text('Guest Admission Notice'),
              content: const Text(
                'For security and capacity control, only guests included in '
                'this registration will be permitted to enter the event. '
                'Please confirm that the selected guest count is accurate.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Review'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('I Understand'),
                ),
              ],
            ),
          ) ??
          false;
      if (!acknowledged || !context.mounted) return;
      controller.acceptGuestNotice();
    }

    final EventBooking? booking = await controller.submit();
    if (booking == null || !context.mounted) return;
    final bool paymentComplete = booking.isPaymentComplete;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        surfaceTintColor: AppColors.panelDark,
        icon: Icon(
          paymentComplete
              ? Icons.check_circle_outline
              : Icons.hourglass_top_rounded,
          color: paymentComplete ? AppColors.success : AppColors.warning,
          size: 42,
        ),
        title: Text(
          paymentComplete ? 'Registration Successful' : 'RSVP Submitted',
        ),
        content: Text(
          paymentComplete
              ? controller.guestCount == 0
                    ? 'Your place at ${event.title} is confirmed.'
                    : 'Your place and ${controller.guestCount} registered '
                          '${controller.guestCount == 1 ? 'guest' : 'guests'} '
                          'are confirmed.'
              : 'Your RSVP was created, but payment is not yet confirmed. '
                    'Your place is not treated as paid until the backend '
                    'confirms the payment.',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('View My Events'),
          ),
        ],
      ),
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
                      amount: event.registrationFee,
                      currency: event.currency,
                    ),
                    const SizedBox(height: 36),
                    const Divider(),
                    const SizedBox(height: 44),
                    Text(
                      'Vehicle Details',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'SELECT REGISTERED VEHICLE',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AsyncStateView<List<Vehicle>>(
                      state: controller.vehicles,
                      onRetry: () => controller.loadVehicles(force: true),
                      isEmpty: (List<Vehicle> vehicles) => vehicles.isEmpty,
                      emptyMessage:
                          'No eligible registered vehicles are available.',
                      builder: (BuildContext context, List<Vehicle> vehicles) {
                        return VehicleSelection(
                          vehicles: vehicles,
                          selectedVehicle: controller.selectedVehicle,
                          onChanged: controller.selectVehicle,
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    if (event.guestLimit > 0) ...<Widget>[
                      Text(
                        'Additional Guests',
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 28),
                      GuestPanel(
                        count: controller.guestCount,
                        limit: event.guestLimit,
                        guestFee: event.guestFee,
                        currency: event.currency,
                        onIncrement: controller.incrementGuests,
                        onDecrement: controller.decrementGuests,
                      ),
                    ],
                    const SizedBox(height: 54),
                    PriceSummary(
                      basePrice: event.registrationFee,
                      guestsPrice: controller.guestsTotal,
                      total: controller.total,
                      currency: event.currency,
                    ),
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
                      onPressed:
                          controller.isSubmitting ||
                              event.isAtCapacity
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
