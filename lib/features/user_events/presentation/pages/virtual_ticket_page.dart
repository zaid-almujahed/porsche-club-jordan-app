import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/ticket_controller.dart';
import '../widgets/virtual_ticket_widgets.dart';

class VirtualTicketPage extends StatelessWidget {
  const VirtualTicketPage({super.key, required this.controller});

  final TicketController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Virtual Ticket', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: 40,
            bottomPadding: 50,
            onRefresh: () => controller.load(force: true),
            child: AsyncStateView<EventBooking>(
              state: controller.booking,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, EventBooking booking) {
                if (booking.event.hasEndedAt(DateTime.now())) {
                  return const GradientPanel(
                    padding: EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.event_available_outlined,
                          color: AppColors.textMuted,
                          size: 52,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'PAST EVENT',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sectionTitle,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'QR tickets are unavailable after an event ends.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }
                if (booking.status != EventBookingStatus.confirmed) {
                  return const GradientPanel(
                    padding: EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.confirmation_number_outlined,
                          color: AppColors.warning,
                          size: 52,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'TICKET UNAVAILABLE',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sectionTitle,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'A QR ticket is issued only for a confirmed event '
                          'registration.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }
                return AsyncStateView<EventTicket>(
                  state: controller.ticket,
                  onRetry: () => controller.load(force: true),
                  builder: (BuildContext context, EventTicket ticket) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 506),
                        child: TicketCard(booking: booking, ticket: ticket),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
