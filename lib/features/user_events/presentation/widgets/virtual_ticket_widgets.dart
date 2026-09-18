import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

abstract final class VirtualTicketStyles {
  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: <Color>[
      Color(0x331A1A1A),
      Color(0xCC000000),
      Color(0x8C000000),
      Color(0x191A1A1A),
    ],
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    gradient: panelGradient,
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(27)),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 56,
        offset: Offset(0, 28),
        spreadRadius: -13.5,
      ),
    ],
  );

  static const TextStyle accessLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 12.4,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 1.24,
  );

  static const TextStyle eventTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 31.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.79,
  );

  static const TextStyle date = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w300,
    height: 1.6,
  );

  static const TextStyle scanLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 0.78,
    letterSpacing: 2.48,
  );

  static const TextStyle informationLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Color(0xFFA0A0A0),
    fontSize: 12.4,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 1.86,
  );

  static const TextStyle emphasizedInformationLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 12.4,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 1.86,
  );

  static const TextStyle informationValue = TextStyle(
    fontFamily: 'Inter',
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w300,
    height: 1.6,
  );

  static const TextStyle compactValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 12.4,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 1.24,
  );

  static const TextStyle guestValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 27,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.booking, required this.ticket});

  final EventBooking booking;
  final EventTicket ticket;

  @override
  Widget build(BuildContext context) {
    if (!ticket.canDisplayQr) {
      return Container(
        color: const Color(0xFF181817),
        padding: const EdgeInsets.all(36),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.verified_outlined,
              color: AppColors.success,
              size: 52,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'ATTENDANCE RECORDED',
              textAlign: TextAlign.center,
              style: VirtualTicketStyles.scanLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This ticket has already been checked in and its QR code can no '
              'longer be generated.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: VirtualTicketStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TicketHeader(booking: booking),
          _TicketQrSection(ticket: ticket),
          _TicketInformation(booking: booking, ticket: ticket),
        ],
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.booking});

  final EventBooking booking;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: VirtualTicketStyles.panelGradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 36, 36, 18),
        child: Column(
          children: <Widget>[
            const Text(
              'CONFIRMED ACCESS',
              textAlign: TextAlign.center,
              style: VirtualTicketStyles.accessLabel,
            ),
            const SizedBox(height: 9),
            Text(
              booking.event.title,
              textAlign: TextAlign.center,
              style: VirtualTicketStyles.eventTitle,
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.date(booking.event.startsAt),
              textAlign: TextAlign.center,
              style: VirtualTicketStyles.date,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketQrSection extends StatelessWidget {
  const _TicketQrSection({required this.ticket});

  final EventTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF181817),
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 54),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(12.5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF222222), width: 1.4),
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
              child: ticket.qrToken.trim().isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.qr_code_2,
                        color: Colors.black,
                        size: 64,
                      ),
                    )
                  : QrImageView(
                      data: ticket.qrToken,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        color: Colors.black,
                        eyeShape: QrEyeShape.square,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        color: Colors.black,
                        dataModuleShape: QrDataModuleShape.square,
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      errorStateBuilder: (BuildContext context, Object? error) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 44,
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 36),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'SCAN AT ENTRANCE',
              textAlign: TextAlign.center,
              style: VirtualTicketStyles.scanLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInformation extends StatelessWidget {
  const _TicketInformation({required this.booking, required this.ticket});

  final EventBooking booking;
  final EventTicket ticket;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: VirtualTicketStyles.panelGradient,
        border: Border(top: BorderSide(color: Color(0xFF222222), width: 1.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 18, 36, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _TicketValue(
                    label: 'TIME',
                    value: AppFormatters.time(booking.event.startsAt),
                    emphasizeLabel: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                _TicketValue(
                  label: 'REG ID',
                  value: ticket.id,
                  alignEnd: true,
                  compactValue: true,
                ),
              ],
            ),
            const SizedBox(height: 27),
            _TicketValue(label: 'LOCATION', value: booking.event.location),
            const SizedBox(height: 36),
            const Divider(
              height: 1.1,
              thickness: 1.1,
              color: Color(0xFF222222),
            ),
            const SizedBox(height: 27),
            _TicketValue(
              label: 'GUEST',
              value: ticket.holderName,
              largeValue: true,
              valueSpacing: 9,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketValue extends StatelessWidget {
  const _TicketValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.emphasizeLabel = false,
    this.compactValue = false,
    this.largeValue = false,
    this.valueSpacing = 3.5,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final bool emphasizeLabel;
  final bool compactValue;
  final bool largeValue;
  final double valueSpacing;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment crossAxisAlignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final TextAlign textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    final TextStyle valueStyle;
    if (largeValue) {
      valueStyle = VirtualTicketStyles.guestValue;
    } else if (compactValue) {
      valueStyle = VirtualTicketStyles.compactValue;
    } else {
      valueStyle = VirtualTicketStyles.informationValue;
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        Text(
          label,
          textAlign: textAlign,
          style: emphasizeLabel
              ? VirtualTicketStyles.emphasizedInformationLabel
              : VirtualTicketStyles.informationLabel,
        ),
        SizedBox(height: valueSpacing),
        Text(value, textAlign: textAlign, style: valueStyle),
      ],
    );
  }
}
