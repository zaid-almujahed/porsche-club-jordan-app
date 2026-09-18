import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/core/cache/memory_cache.dart';
import 'package:pcj_v4/features/events/domain/repositories/events_repository.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

import '../models/event_model.dart';
import '../../../user_events/data/models/event_booking_model.dart';

class ApiEventsRepository implements EventsRepository {
  ApiEventsRepository({
    required PcjApiClient apiClient,
    required MemoryCache cache,
  }) : _apiClient = apiClient,
       _cache = cache;

  final PcjApiClient _apiClient;
  final MemoryCache _cache;
  static const Duration _listTtl = Duration(minutes: 2);
  static const Duration _detailsTtl = Duration(minutes: 5);

  @override
  Future<List<Event>> getEvents({String? category, String? search}) async {
    final String searchKey = search?.trim().toLowerCase() ?? '';
    final List<Event> events = await _cache.getOrLoad<List<Event>>(
      'events:list:$searchKey',
      () async => requireJsonMapList(
        await _apiClient.get(
          '/member/allevents',
          query: <String, Object?>{'search': search},
        ),
        description: 'events response',
      ).map<Event>(EventModel.fromSummaryJson).toList(growable: false),
      ttl: _listTtl,
    );

    final String normalized = category?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty || normalized == 'all events') return events;
    return events
        .where((Event event) => event.category.toLowerCase() == normalized)
        .toList(growable: false);
  }

  @override
  Future<Event> getEvent(String eventId) async {
    final Event event = await _cache.getOrLoad<Event>(
      'events:details:$eventId',
      () async => EventModel.fromDetailsJson(
        requireJsonMap(
          await _apiClient.get(
            '/member/events/${Uri.encodeComponent(eventId)}',
          ),
          description: 'event response',
        ),
      ),
      ttl: _detailsTtl,
    );
    return _withWeather(event);
  }

  @override
  Future<List<Event>> getRecentEvents() {
    return _cache.getOrLoad<List<Event>>(
      'events:recent',
      () async => requireJsonMapList(
        await _apiClient.get('/member/events/last-3-months'),
        description: 'recent events response',
      ).map<Event>(EventModel.fromSummaryJson).toList(growable: false),
      ttl: _listTtl,
    );
  }

  @override
  Future<EventBooking> registerForEvent(
    EventRegistrationRequest request,
  ) async {
    final Event event = await getEvent(request.eventId);
    final Object? response = await _apiClient.postJson(
      '/member/events/${Uri.encodeComponent(request.eventId)}/rsvp',
      body: <String, Object?>{'guest_count': request.guestCount},
    );
    _cache.removeWhere((String key) => key.startsWith('events:'));
    _cache.removeWhere((String key) => key.startsWith('user-events:'));
    if (unwrapApiData(response) is Map) {
      return EventBookingModel.fromJson(
        requireJsonMap(response, description: 'event registration response'),
        fallbackEvent: event,
      );
    }
    return EventBooking(
      id: request.eventId,
      event: event,
      status: EventBookingStatus.confirmed,
      guestCount: request.guestCount,
    );
  }

  @override
  Future<void> cancelRegistration(String eventId) async {
    await _apiClient.delete(
      '/member/events/${Uri.encodeComponent(eventId)}/rsvp',
    );
    _cache.removeWhere((String key) => key.startsWith('events:'));
    _cache.removeWhere((String key) => key.startsWith('user-events:'));
  }

  @override
  Future<Object?> startEventPayment(String rsvpId) {
    return _apiClient.post(
      '/member/events/${Uri.encodeComponent(rsvpId)}/payment',
    );
  }

  Future<Event> _withWeather(Event event) async {
    if (event.weatherCelsius != null) return event;
    if (event.location.trim().length < 2) return event;
    return _cache.getOrLoad<Event>(
      'events:weather:${event.id}',
      () async {
        final DateTime localStart = event.startsAt.toLocal();
        try {
          final Map<String, dynamic> response = requireJsonMap(
            await _apiClient.get(
              '/weather',
              query: <String, Object?>{
                'location': event.location.trim(),
                'date': _date(localStart),
                'hour': localStart.hour,
              },
              authenticated: false,
            ),
            description: 'weather response',
          );
          final Object? weatherValue = response['weather'];
          final Map<String, dynamic> weather = weatherValue is Map
              ? Map<String, dynamic>.from(weatherValue)
              : response;
          final double? temperature = firstDouble(weather, const <String>[
            'temperature',
            'temperature_celsius',
          ]);
          return temperature == null
              ? event
              : event.copyWith(weatherCelsius: temperature.round());
        } catch (_) {
          // Weather is supplementary; event details stay available if the
          // forecast provider rejects the date or is unavailable.
          return event;
        }
      },
      ttl: const Duration(minutes: 15),
    );
  }

  static String _date(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
