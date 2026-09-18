import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';

export 'package:pcj_v4/shared/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.price,
    required super.currency,
    required super.stock,
    required super.imageUrls,
    super.colors,
    super.sizes,
    super.badge,
    super.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> source) {
    final Object? nested = source['item'] ?? source['product'];
    final Map<String, dynamic> json = nested is Map
        ? <String, dynamic>{
            ...Map<String, dynamic>.from(nested),
            if (source['variant'] != null)
              'selected_variant': source['variant'],
          }
        : source;
    final List<ProductVariant> variants = _variants(json);
    final List<String> images = _images(json, variants);
    final double price =
        firstDouble(json, const <String>[
          'price',
          'base_price',
          'unit_price',
        ]) ??
        _lowestPrice(variants) ??
        0;
    final int stock =
        firstInt(json, const <String>['stock', 'quantity', 'stock_quantity']) ??
        variants.fold<int>(
          0,
          (int total, ProductVariant variant) => total + variant.stock,
        );

    final Set<String> colorNames = variants
        .map((ProductVariant variant) => variant.colorName)
        .whereType<String>()
        .where((String value) => value.isNotEmpty)
        .toSet();
    final Set<String> sizes = variants
        .map((ProductVariant variant) => variant.size)
        .whereType<String>()
        .where((String value) => value.isNotEmpty)
        .toSet();

    return ProductModel(
      id:
          firstString(json, const <String>['id', 'item_id', 'product_id']) ??
          '',
      name: firstString(json, const <String>['name', 'title']) ?? '',
      description:
          firstString(json, const <String>['description', 'details']) ?? '',
      category:
          _category(json['category']) ??
          firstString(json, const <String>['category_name']) ??
          'All Categories',
      price: price,
      currency: firstString(json, const <String>['currency']) ?? 'JOD',
      stock: stock,
      imageUrls: images,
      colors: colorNames
          .map(
            (String name) =>
                ProductColorOption(name: name, argbValue: _colorValue(name)),
          )
          .toList(growable: false),
      sizes: sizes.toList(growable: false),
      badge: firstString(json, const <String>['badge', 'label']),
      variants: variants,
    );
  }

  static List<ProductVariant> _variants(Map<String, dynamic> json) {
    final Object? raw = json['variants'];
    final List<Object?> values = raw is List
        ? raw.cast<Object?>()
        : json['selected_variant'] is Map
        ? <Object?>[json['selected_variant']]
        : const <Object?>[];
    return values
        .whereType<Map>()
        .map<ProductVariant>((Map value) {
          final Map<String, dynamic> variant = Map<String, dynamic>.from(value);
          final Object? colorValue = variant['color'];
          final String? color = colorValue is Map
              ? firstString(
                  Map<String, dynamic>.from(colorValue),
                  const <String>['name', 'value'],
                )
              : firstString(variant, const <String>['color', 'color_name']);
          return ProductVariant(
            id:
                firstString(variant, const <String>[
                  'id',
                  'variant_id',
                  'item_variant_id',
                ]) ??
                '',
            stock:
                firstInt(variant, const <String>[
                  'stock',
                  'quantity',
                  'stock_quantity',
                ]) ??
                0,
            price: firstDouble(variant, const <String>['price', 'unit_price']),
            colorName: color,
            size: firstString(variant, const <String>['size', 'size_name']),
            imageUrl: firstString(variant, const <String>[
              'image_url',
              'image',
              'photo',
            ]),
          );
        })
        .toList(growable: false);
  }

  static List<String> _images(
    Map<String, dynamic> json,
    List<ProductVariant> variants,
  ) {
    final List<String> values = <String>[];
    final String? cover = firstString(json, const <String>[
      'cover_image',
      'image_url',
      'image',
      'photo',
    ]);
    if (cover != null) values.add(cover);
    final Object? rawImages =
        json['images'] ?? json['image_urls'] ?? json['gallery'];
    if (rawImages is List) {
      for (final Object? raw in rawImages) {
        final String? url = raw is String
            ? raw
            : raw is Map
            ? firstString(Map<String, dynamic>.from(raw), const <String>[
                'image_url',
                'url',
                'path',
              ])
            : null;
        if (url != null) values.add(url);
      }
    }
    values.addAll(
      variants
          .map((ProductVariant variant) => variant.imageUrl)
          .whereType<String>(),
    );
    return values.toSet().toList(growable: false);
  }

  static String? _category(Object? value) {
    if (value is String) return value;
    if (value is Map) {
      return firstString(Map<String, dynamic>.from(value), const <String>[
        'name',
        'title',
      ]);
    }
    return null;
  }

  static double? _lowestPrice(List<ProductVariant> variants) {
    final List<double> prices = variants
        .map((ProductVariant variant) => variant.price)
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return null;
    prices.sort();
    return prices.first;
  }

  static int _colorValue(String value) {
    final String normalized = value.trim().toLowerCase();
    final String hex = normalized.replaceFirst('#', '');
    if (RegExp(r'^[0-9a-f]{6}$').hasMatch(hex)) {
      return int.parse('FF$hex', radix: 16);
    }
    if (normalized.contains('black')) return 0xFF050505;
    if (normalized.contains('red')) return 0xFFB12B28;
    if (normalized.contains('white')) return 0xFFF2F2F2;
    if (normalized.contains('silver')) return 0xFFC0C0C0;
    if (normalized.contains('grey') || normalized.contains('gray')) {
      return 0xFF9E9E9E;
    }
    if (normalized.contains('navy')) return 0xFF0B1F3A;
    if (normalized.contains('blue')) return 0xFF1B3A66;
    if (normalized.contains('green')) return 0xFF315C3B;
    if (normalized.contains('yellow')) return 0xFFF2C94C;
    if (normalized.contains('orange')) return 0xFFE67E22;
    if (normalized.contains('brown')) return 0xFF6F4E37;
    if (normalized.contains('beige')) return 0xFFD8C3A5;
    if (normalized.contains('gold')) return 0xFFD4AF37;
    if (normalized.contains('purple')) return 0xFF6C4A8B;
    if (normalized.contains('pink')) return 0xFFD7859B;
    return 0xFF050505;
  }
}
