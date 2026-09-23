import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/widgets/app_dialog.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/user_events_controller.dart';
import '../widgets/member_events_widgets.dart';

class MemberEventsPage extends StatelessWidget {
  const MemberEventsPage({super.key, required this.controller});

  final UserEventsController controller;

  Future<void> _cancel(BuildContext context, EventBooking booking) async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Cancel registration?',
      message:
          'Your registration for ${booking.event.title} will be cancelled.',
      confirmLabel: 'Cancel RSVP',
      cancelLabel: 'Keep Registration',
      icon: Icons.event_busy_outlined,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final bool cancelled = await controller.cancelRegistration(booking);
    if (!cancelled || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event registration cancelled.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(
        title: 'My Events',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.profile);
          }
        },
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: 40,
            bottomPadding: 50,
            onRefresh: () => controller.load(force: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const PageHeading(),
                const SizedBox(height: 27),
                EventTabs(
                  showUpcoming: controller.showUpcoming,
                  onSelected: (bool upcoming) {
                    controller.showTab(upcoming: upcoming);
                  },
                ),
                const SizedBox(height: 36),
                if (controller.actionError != null) ...<Widget>[
                  Text(
                    readableError(controller.actionError!),
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AsyncStateView<List<EventBooking>>(
                  state: controller.bookings,
                  onRetry: () => controller.load(force: true),
                  isEmpty: (List<EventBooking> bookings) => bookings.isEmpty,
                  emptyMessage: controller.showUpcoming
                      ? 'No upcoming event registrations.'
                      : 'No past event registrations.',
                  builder: (BuildContext context, List<EventBooking> bookings) {
                    return Column(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < bookings.length;
                          index++
                        ) ...<Widget>[
                          _BookingCard(
                            booking: bookings[index],
                            isCancelling: controller.isCancelling(
                              bookings[index].event.id,
                            ),
                            onCancel:
                                controller.showUpcoming &&
                                    !bookings[index].event.hasEndedAt(
                                      DateTime.now(),
                                    )
                                ? () => _cancel(context, bookings[index])
                                : null,
                          ),
                          if (index != bookings.length - 1)
                            const SizedBox(height: 18),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isCancelling,
    this.onCancel,
  });

  final EventBooking booking;
  final bool isCancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final Event event = booking.event;
    final DateTime now = DateTime.now();
    final bool eventHasEnded = event.hasEndedAt(now);
    final bool isHappeningNow = event.isHappeningAt(now);
    final bool canOpenTicket =
        !eventHasEnded &&
        booking.status == EventBookingStatus.confirmed;
    return MemberEventCard(
      status: isHappeningNow
          ? 'HAPPENING NOW'
          : booking.status.name.toUpperCase(),
      type: event.category.toUpperCase(),
      typeIcon: Icons.location_on_outlined,
      title: event.title,
      date: AppFormatters.date(event.startsAt),
      time: AppFormatters.timeRange(event.startsAt, event.endsAt),
      location: event.location,
      isTicketAvailable: canOpenTicket,
      isHappeningNow: isHappeningNow,
      onTicketPressed: canOpenTicket
          ? () => context.push(
              AppRoutes.ticketLocation(booking.id),
              extra: booking,
            )
          : null,
      onCancelPressed: onCancel,
      isCancelling: isCancelling,
    );
  }
}
