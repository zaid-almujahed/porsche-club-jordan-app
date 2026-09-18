class Vehicle {
  const Vehicle({
    required this.id,
    required this.model,
    required this.year,
    required this.exteriorColor,
    required this.vin,
    required this.licensePlate,
    this.imageUrl,
  });

  final String id;
  final String model;
  final int year;
  final String exteriorColor;
  final String vin;
  final String licensePlate;
  final String? imageUrl;

  String get displayName => '$model ($licensePlate)';
}
