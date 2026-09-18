import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/features/events/data/models/event_model.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

class EventTicketModel extends EventTicket {
  const EventTicketModel({
    required super.id,
    required super.qrImageUrl,
    required super.holderName,
    super.attendanceStatus,
    super.isPaid,
  });

  factory EventTicketModel.fromJson(Map<String, dynamic> json) {
    final String qrToken =
        firstString(json, const <String>[
          'qr_token',
          'qr_image_url',
          'qr_url',
          'qr_code',
          'url',
        ]) ??
        '';
    return EventTicketModel(
      id:
          firstString(json, const <String>[
            'id',
            'event_id',
            'registration_id',
            'reg_id',
          ]) ??
          '',
      qrImageUrl: qrToken,
      holderName:
          firstString(json, const <String>[
            'holder_name',
            'member_name',
            'name',
          ]) ??
          'Member',
      attendanceStatus:
          firstString(json, const <String>['attendance_status']) ??
          'Not Checked In',
      isPaid: _bool(json['is_paid']),
    );
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    final String normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }
}

class EventBookingModel extends EventBooking {
  const EventBookingModel({
    required super.id,
    required super.event,
    required super.status,
    required super.guestCount,
    super.paymentStatus,
    super.amount,
    super.ticket,
  });

  factory EventBookingModel.fromJson(
    Map<String, dynamic> json, {
    Event? fallbackEvent,
  }) {
    final Object? eventValue = json['event'];
    final Event event = eventValue is Map
        ? EventModel.fromDetailsJson(Map<String, dynamic>.from(eventValue))
        : fallbackEvent ?? EventModel.fromSummaryJson(json);
    final Object? ticketValue = json['ticket'] ?? json['qr'];
    final bool hasAttendanceState = json['attendance_status'] != null;
    final bool hasQrToken = json['qr_token'] != null;

    return EventBookingModel(
      id:
          firstString(json, const <String>[
            'rsvp_id',
            'booking_id',
            'registration_id',
            'id',
          ]) ??
          event.id,
      event: event,
      status: _status(json['status'] ?? json['rsvp_status']),
      guestCount: firstInt(json, const <String>['guest_count', 'guests']) ?? 0,
      paymentStatus: firstString(json, const <String>['payment_status']),
      amount: firstDouble(json, const <String>['amount']),
      ticket: ticketValue is Map
          ? EventTicketModel.fromJson(Map<String, dynamic>.from(ticketValue))
          : hasAttendanceState || hasQrToken
          ? EventTicketModel.fromJson(json)
          : null,
    );
  }

  static EventBookingStatus _status(Object? value) {
    final String normalized = value?.toString().toLowerCase() ?? '';
    if (normalized.isEmpty) return EventBookingStatus.confirmed;
    if (normalized.contains('confirm') || normalized.contains('paid')) {
      return EventBookingStatus.confirmed;
    }
    if (normalized.contains('cancel')) return EventBookingStatus.cancelled;
    if (normalized.contains('attend')) return EventBookingStatus.attended;
    return EventBookingStatus.waitlist;
  }
}
