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
            child: AsyncStateView<EventBooking>(
              state: controller.booking,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, EventBooking booking) {
                if (!booking.isPaymentComplete) {
                  return const GradientPanel(
                    padding: EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.lock_clock_outlined,
                          color: AppColors.warning,
                          size: 52,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'PAYMENT PENDING',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sectionTitle,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'The event QR code becomes available only after the '
                          'backend confirms payment.',
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
