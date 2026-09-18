import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

abstract interface class UserEventsRepository {
  Future<List<EventBooking>> getBookings({required bool upcoming});

  Future<EventBooking> getBooking(String bookingId);

  Future<EventTicket> getTicket(String eventId);

  Future<void> cancelRegistration(String eventId);
}
