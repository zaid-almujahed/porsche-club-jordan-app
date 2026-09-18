import 'package:flutter_test/flutter_test.dart';
import 'package:pcj_v4/features/events/data/models/event_model.dart';
import 'package:pcj_v4/features/user_events/data/models/event_booking_model.dart';

void main() {
  final EventModel paidEvent = EventModel.fromSummaryJson(<String, dynamic>{
    'id': 'event-1',
    'start_at': '2026-10-01T08:00:00Z',
    'registration_fee': 50,
  });

  test('parses the RSVP id, amount, and completed payment status', () {
    final EventBookingModel booking = EventBookingModel.fromJson(
      <String, dynamic>{
        'rsvp_id': 'rsvp-1',
        'guest_count': 1,
        'amount': '60',
        'payment_status': 'PAID',
      },
      fallbackEvent: paidEvent,
    );

    expect(booking.id, 'rsvp-1');
    expect(booking.guestCount, 1);
    expect(booking.amount, 60);
    expect(booking.isPaymentComplete, isTrue);
  });

  test('does not expose a paid registration as complete without confirmation', () {
    final EventBookingModel booking = EventBookingModel.fromJson(
      const <String, dynamic>{
        'rsvp_id': 'rsvp-2',
        'payment_status': 'PENDING',
      },
      fallbackEvent: paidEvent,
    );

    expect(booking.isPaymentComplete, isFalse);
  });

  test('a zero-cost registration is complete without a payment status', () {
    final EventModel freeEvent = EventModel.fromSummaryJson(<String, dynamic>{
      'id': 'event-free',
      'start_at': '2026-10-01T08:00:00Z',
    });
    final EventBookingModel booking = EventBookingModel.fromJson(
      const <String, dynamic>{'rsvp_id': 'rsvp-free'},
      fallbackEvent: freeEvent,
    );

    expect(booking.isPaymentComplete, isTrue);
  });
}
