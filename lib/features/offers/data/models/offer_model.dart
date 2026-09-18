import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/shared/domain/entities/offer.dart';

export 'package:pcj_v4/shared/domain/entities/offer.dart';

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.category,
    required super.badgeLabel,
    required super.imageUrl,
    super.partnerName,
    super.discountRate,
    super.expiryDate,
    super.isClaimed,
    super.logoUrl,
  });

  factory OfferModel.fromJson(Map<String, dynamic> source) {
    final Object? nested = source['offer'];
    final Map<String, dynamic> json = nested is Map
        ? Map<String, dynamic>.from(nested)
        : source;
    final Object? partnerValue = json['partner'];
    final Map<String, dynamic> partner = partnerValue is Map
        ? Map<String, dynamic>.from(partnerValue)
        : const <String, dynamic>{};
    final String partnerName = partnerValue is String
        ? partnerValue
        : firstString(partner, const <String>[
                'name',
                'title',
                'company_name',
              ]) ??
              '';
    final double? discount = firstDouble(json, const <String>[
      'discount',
      'discount_percentage',
      'discount_percent',
      'discount_rate',
    ]);

    return OfferModel(
      id: firstString(json, const <String>['id', 'offer_id']) ?? '',
      title:
          firstString(json, const <String>['title', 'name']) ?? partnerName,
      description:
          firstString(json, const <String>[
            'description',
            'details',
            'offer_details',
          ]) ??
          '',
      location:
          firstString(json, const <String>['location', 'address']) ??
          firstString(partner, const <String>['location', 'address']) ??
          '',
      category:
          partnerName.toLowerCase().contains('nuqul') ? 'NUQUL' : 'PARTNERS',
      badgeLabel: _badge(json),
      imageUrl:
          firstString(json, const <String>[
            'image_url',
            'cover_image',
            'image',
          ]) ??
          firstString(partner, const <String>['image_url', 'cover_image']) ??
          '',
      partnerName: partnerName,
      discountRate: discount,
      expiryDate: firstDateTime(json, const <String>['expiry_date']),
      isClaimed: _bool(json['claimed'] ?? json['is_claimed']),
      logoUrl:
          firstString(json, const <String>['logo_url', 'logo']) ??
          firstString(partner, const <String>['logo_url', 'logo']),
    );
  }

  static String _badge(Map<String, dynamic> json) {
    final String? label = firstString(json, const <String>[
      'badge_label',
      'badge',
      'discount_label',
    ]);
    if (label != null) return label;
    final double? percentage = firstDouble(json, const <String>[
      'discount',
      'discount_percentage',
      'discount_percent',
      'discount_rate',
    ]);
    if (percentage != null) return '${percentage.toStringAsFixed(0)}% OFF';
    return 'MEMBER OFFER';
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    final String normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }
}
