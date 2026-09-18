import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';

export 'package:pcj_v4/shared/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.startsAt,
    required super.endsAt,
    required super.category,
    required super.posterUrl,
    required super.capacity,
    required super.registeredCount,
    required super.guestLimit,
    required super.registrationFee,
    required super.guestFee,
    super.currency,
    super.sponsors,
    super.galleryUrls,
    super.mapImageUrl,
    super.latitude,
    super.longitude,
    super.availableCount,
    super.weatherCelsius,
    super.isPaid,
    super.isFeatured,
  });

  factory EventModel.fromSummaryJson(Map<String, dynamic> json) {
    return EventModel._fromJson(json, detailed: false);
  }

  factory EventModel.fromDetailsJson(Map<String, dynamic> json) {
    return EventModel._fromJson(json, detailed: true);
  }

  factory EventModel._fromJson(
    Map<String, dynamic> source, {
    required bool detailed,
  }) {
    final Object? nested = source['event'];
    final Map<String, dynamic> json = nested is Map
        ? Map<String, dynamic>.from(nested)
        : source;
    final DateTime startsAt =
        firstDateTime(json, const <String>['start_at', 'starts_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return EventModel(
      id: firstString(json, const <String>['id', 'event_id']) ?? '',
      title: firstString(json, const <String>['title', 'name']) ?? '',
      description:
          firstString(json, const <String>['description', 'overview']) ?? '',
      location: firstString(json, const <String>['location', 'venue']) ?? '',
      startsAt: startsAt,
      endsAt:
          firstDateTime(json, const <String>['end_at', 'ends_at']) ?? startsAt,
      category:
          firstString(json, const <String>['category', 'event_type', 'type']) ??
          'Event',
      posterUrl:
          firstString(json, const <String>[
            'cover_image',
            'poster_url',
            'image_url',
          ]) ??
          '',
      capacity: firstInt(json, const <String>['capacity']) ?? 0,
      registeredCount:
          firstInt(json, const <String>[
            'registered',
            'registered_count',
            'rsvp_count',
            'attendees_count',
          ]) ??
          0,
      guestLimit:
          firstInt(json, const <String>[
            'guest_limit',
            'max_guests',
            'max_guest_count',
          ]) ??
          0,
      registrationFee:
          firstDouble(json, const <String>[
            'registration_fee',
            'base_price',
            'price',
          ]) ??
          0,
      guestFee:
          firstDouble(json, const <String>['guest_fee', 'guest_price']) ?? 0,
      currency: firstString(json, const <String>['currency']) ?? 'JOD',
      sponsors: detailed
          ? _sponsors(json['sponsors'] ?? json['sponsor'])
          : const <String>[],
      galleryUrls: detailed
          ? _imageUrls(json['gallery'] ?? json['images'] ?? json['photos'])
          : const <String>[],
      mapImageUrl: firstString(json, const <String>[
        'map_image_url',
        'map_url',
      ]),
      latitude: firstDouble(json, const <String>['latitude', 'lat']),
      longitude: firstDouble(json, const <String>['longitude', 'lng', 'lon']),
      availableCount: firstInt(json, const <String>['available']),
      weatherCelsius: firstInt(json, const <String>[
        'weather_celsius',
        'temperature',
      ]),
      isPaid:
          _bool(json['is_paid']) ||
          (firstDouble(json, const <String>[
                    'registration_fee',
                    'base_price',
                    'price',
                  ]) ??
                  0) >
              0 ||
          (firstDouble(json, const <String>['guest_fee', 'guest_price']) ??
                  0) >
              0,
      isFeatured: _bool(json['is_featured'] ?? json['featured']),
    );
  }

  static List<String> _sponsors(Object? value) {
    final List<Object?> values = value is List
        ? value.cast<Object?>()
        : value is Map
        ? <Object?>[value]
        : const <Object?>[];
    return values
        .map<String>((Object? sponsor) {
          if (sponsor is String) return sponsor;
          if (sponsor is Map) {
            final Map<String, dynamic> json = Map<String, dynamic>.from(
              sponsor,
            );
            final Object? nested = json['sponsor'];
            if (nested is Map) {
              final String? name = firstString(
                Map<String, dynamic>.from(nested),
                const <String>['name', 'title'],
              );
              if (name != null) return name;
            }
            return firstString(json, const <String>[
                  'name',
                  'sponsor_name',
                  'title',
                  'tier',
                ]) ??
                'Sponsor ${json['sponsor_id'] ?? ''}'.trim();
          }
          return sponsor?.toString() ?? '';
        })
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _imageUrls(Object? value) {
    final List<Object?> values = value is List
        ? value.cast<Object?>()
        : value is Map
        ? <Object?>[value]
        : const <Object?>[];
    return values
        .map<String?>((Object? image) {
          if (image is String) return image;
          if (image is Map) {
            return firstString(Map<String, dynamic>.from(image), const <String>[
              'image_url',
              'url',
              'path',
            ]);
          }
          return null;
        })
        .whereType<String>()
        .toList(growable: false);
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    final String normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }
}
