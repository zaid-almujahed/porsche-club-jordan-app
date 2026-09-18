import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/core/cache/memory_cache.dart';
import 'package:pcj_v4/features/user_events/domain/repositories/user_events_repository.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

import '../models/event_booking_model.dart';

class ApiUserEventsRepository implements UserEventsRepository {
  ApiUserEventsRepository({
    required PcjApiClient apiClient,
    required MemoryCache cache,
  }) : _apiClient = apiClient,
       _cache = cache;

  final PcjApiClient _apiClient;
  final MemoryCache _cache;
  List<EventBooking> _lastBookings = const <EventBooking>[];

  @override
  Future<List<EventBooking>> getBookings({required bool upcoming}) async {
    Object? value = unwrapApiData(
      await _cache.getOrLoad<Object?>(
        'user-events:all',
        () => _apiClient.get('/member/events'),
        ttl: const Duration(minutes: 1),
      ),
    );
    if (value is Map && value['events'] is List) value = value['events'];
    if (value is Map && value['bookings'] is List) value = value['bookings'];
    if (value is! List) {
      throw const AppException(
        'The server returned an invalid registered-events response.',
      );
    }
    final DateTime now = DateTime.now();
    final List<EventBooking> bookings = value
        .whereType<Map>()
        .map((Map item) {
          return EventBookingModel.fromJson(Map<String, dynamic>.from(item));
        })
        .where((EventBooking booking) {
          final bool isUpcoming = booking.event.endsAt.isAfter(now);
          return upcoming ? isUpcoming : !isUpcoming;
        })
        .toList(growable: false);
    _lastBookings = bookings;
    return bookings;
  }

  @override
  Future<EventBooking> getBooking(String bookingId) async {
    EventBooking? match = _find(_lastBookings, bookingId);
    match ??= _find(await getBookings(upcoming: true), bookingId);
    match ??= _find(await getBookings(upcoming: false), bookingId);
    if (match == null) {
      throw const AppException('The event registration could not be found.');
    }
    return match;
  }

  @override
  Future<EventTicket> getTicket(String eventId) async {
    final Object? response = await _apiClient.get(
      '/member/events/${Uri.encodeComponent(eventId)}/qr',
    );
    final Object? value = unwrapApiData(response);
    if (value is String) {
      return EventTicket(
        id: eventId,
        qrImageUrl: value.trim(),
        holderName: '',
      );
    }
    return EventTicketModel.fromJson(
      requireJsonMap(response, description: 'event ticket response'),
    );
  }

  @override
  Future<void> cancelRegistration(String eventId) async {
    await _apiClient.delete(
      '/member/events/${Uri.encodeComponent(eventId)}/rsvp',
    );
    _cache.removeWhere((String key) => key.startsWith('user-events:'));
    _lastBookings = const <EventBooking>[];
  }

  static EventBooking? _find(List<EventBooking> bookings, String id) {
    for (final EventBooking booking in bookings) {
      if (booking.id == id || booking.event.id == id) return booking;
    }
    return null;
  }

}
