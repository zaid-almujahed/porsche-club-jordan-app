class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.badgeLabel,
    required this.imageUrl,
    this.partnerName = '',
    this.discountRate,
    this.expiryDate,
    this.isClaimed = false,
    this.logoUrl,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String badgeLabel;
  final String imageUrl;
  final String partnerName;
  final double? discountRate;
  final DateTime? expiryDate;
  final bool isClaimed;
  final String? logoUrl;

  String get displayPartnerName {
    final String value = partnerName.trim().isEmpty ? title : partnerName;
    return value
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .map((String word) {
          final String lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  bool get isNuqulExclusive =>
      partnerName.trim().toLowerCase().contains('nuqul');

  Offer copyWith({bool? isClaimed}) {
    return Offer(
      id: id,
      title: title,
      description: description,
      location: location,
      category: category,
      badgeLabel: badgeLabel,
      imageUrl: imageUrl,
      partnerName: partnerName,
      discountRate: discountRate,
      expiryDate: expiryDate,
      isClaimed: isClaimed ?? this.isClaimed,
      logoUrl: logoUrl,
    );
  }
}
