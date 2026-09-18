import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';

import 'product_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    super.selectedColor,
    super.selectedSize,
    super.variantId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final Object? productValue = json['product'] ?? json['item'];
    final Object? variantValue = json['variant'];
    final Map<String, dynamic> productJson = productValue is Map
        ? <String, dynamic>{
            ...Map<String, dynamic>.from(productValue),
            if (variantValue is Map) 'selected_variant': variantValue,
          }
        : <String, dynamic>{
            ...json,
            if (variantValue is Map) 'selected_variant': variantValue,
          };
    final Product product = ProductModel.fromJson(productJson);
    final Map<String, dynamic> variant = variantValue is Map
        ? Map<String, dynamic>.from(variantValue)
        : const <String, dynamic>{};
    final String? colorName = firstString(
      variant.isEmpty ? json : variant,
      const <String>['color', 'color_name'],
    );

    return CartItemModel(
      id: firstString(json, const <String>['id', 'cart_item_id']) ?? '',
      product: product,
      quantity: firstInt(json, const <String>['quantity', 'qty']) ?? 1,
      variantId:
          firstString(variant, const <String>['id', 'variant_id']) ??
          firstString(json, const <String>['variant_id']),
      selectedColor: colorName == null
          ? null
          : product.colors.cast<ProductColorOption?>().firstWhere(
              (ProductColorOption? color) => color?.name == colorName,
              orElse: () => null,
            ),
      selectedSize:
          firstString(variant, const <String>['size', 'size_name']) ??
          firstString(json, const <String>['size', 'size_name']),
    );
  }
}

class CartModel extends Cart {
  const CartModel({
    required super.items,
    required super.shippingFee,
    required super.currency,
  });

  factory CartModel.fromJson(Map<String, dynamic> source) {
    final Object? nested = source['cart'];
    final Map<String, dynamic> json = nested is Map
        ? Map<String, dynamic>.from(nested)
        : source;
    final Object? rawItems = json['items'] ?? json['cart_items'];
    final List<CartItem> items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map<CartItem>((Map item) {
                return CartItemModel.fromJson(Map<String, dynamic>.from(item));
              })
              .toList(growable: false)
        : const <CartItem>[];
    return CartModel(
      items: items,
      shippingFee:
          firstDouble(json, const <String>['shipping_fee', 'delivery_fee']) ??
          0,
      currency: firstString(json, const <String>['currency']) ?? 'JOD',
    );
  }
}
