import 'event.dart';

enum EventBookingStatus { confirmed, waitlist, cancelled, attended }

class EventTicket {
  const EventTicket({
    required this.id,
    required this.qrImageUrl,
    required this.holderName,
    this.attendanceStatus = 'Not Checked In',
    this.isPaid = true,
  });

  final String id;
  final String qrImageUrl;
  final String holderName;
  final String attendanceStatus;
  final bool isPaid;

  /// The API returns a signed `qr_token`; qr_flutter converts it to pixels.
  /// The legacy field name is retained to avoid breaking existing widgets.
  String get qrToken => qrImageUrl;

  bool get canDisplayQr =>
      attendanceStatus.trim().toLowerCase() == 'not checked in';
}

class EventBooking {
  const EventBooking({
    required this.id,
    required this.event,
    required this.status,
    required this.guestCount,
    this.paymentStatus,
    this.amount,
    this.ticket,
  });

  final String id;
  final Event event;
  final EventBookingStatus status;
  final int guestCount;
  final String? paymentStatus;
  final double? amount;
  final EventTicket? ticket;

  bool get hasTicket => ticket != null;

  bool get isPaymentComplete {
    final double payableAmount =
        amount ?? event.registrationFee + (event.guestFee * guestCount);
    if (payableAmount <= 0) return true;
    final String normalized = paymentStatus?.trim().toLowerCase() ?? '';
    return normalized == 'paid' ||
        normalized == 'completed' ||
        normalized == 'complete' ||
        normalized == 'successful' ||
        normalized == 'success';
  }
}
