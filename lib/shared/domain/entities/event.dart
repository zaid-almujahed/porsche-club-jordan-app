class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    required this.category,
    required this.posterUrl,
    required this.capacity,
    required this.registeredCount,
    required this.guestLimit,
    required this.registrationFee,
    required this.guestFee,
    this.currency = 'JOD',
    this.sponsors = const <String>[],
    this.galleryUrls = const <String>[],
    this.mapImageUrl,
    this.latitude,
    this.longitude,
    this.availableCount,
    this.weatherCelsius,
    this.isPaid = false,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;
  final DateTime endsAt;
  final String category;
  final String posterUrl;
  final int capacity;
  final int registeredCount;
  final int guestLimit;
  final double registrationFee;
  final double guestFee;
  final String currency;
  final List<String> sponsors;
  final List<String> galleryUrls;
  final String? mapImageUrl;
  final double? latitude;
  final double? longitude;
  final int? availableCount;
  final int? weatherCelsius;
  final bool isPaid;
  final bool isFeatured;

  /// A missing/zero capacity means the API did not publish a limit. It must
  /// not make every partially populated event look sold out.
  bool get isAtCapacity =>
      availableCount != null
      ? availableCount! <= 0
      : capacity > 0 && registeredCount >= capacity;

  /// Fees are authoritative even when older API responses omit `is_paid`.
  bool get isFree => registrationFee <= 0 && guestFee <= 0;

  Event copyWith({int? weatherCelsius}) {
    return Event(
      id: id,
      title: title,
      description: description,
      location: location,
      startsAt: startsAt,
      endsAt: endsAt,
      category: category,
      posterUrl: posterUrl,
      capacity: capacity,
      registeredCount: registeredCount,
      guestLimit: guestLimit,
      registrationFee: registrationFee,
      guestFee: guestFee,
      currency: currency,
      sponsors: sponsors,
      galleryUrls: galleryUrls,
      mapImageUrl: mapImageUrl,
      latitude: latitude,
      longitude: longitude,
      availableCount: availableCount,
      weatherCelsius: weatherCelsius ?? this.weatherCelsius,
      isPaid: isPaid,
      isFeatured: isFeatured,
    );
  }
}
