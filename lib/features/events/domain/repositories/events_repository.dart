import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

class EventRegistrationRequest {
  const EventRegistrationRequest({
    required this.eventId,
    required this.guestCount,
  });

  final String eventId;
  final int guestCount;
}

abstract interface class EventsRepository {
  Future<List<Event>> getEvents({String? category, String? search});

  Future<Event> getEvent(String eventId);

  Future<List<Event>> getRecentEvents();

  Future<EventBooking> registerForEvent(EventRegistrationRequest request);

  Future<void> cancelRegistration(String eventId);

  Future<Object?> startEventPayment(String rsvpId);
}
