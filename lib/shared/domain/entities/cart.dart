import 'product.dart';

enum DeliveryMethod { pickup, delivery }

class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
    this.variantId,
  });

  final String id;
  final Product product;
  final int quantity;
  final ProductColorOption? selectedColor;
  final String? selectedSize;
  final String? variantId;

  double get unitPrice {
    for (final ProductVariant variant in product.variants) {
      if (variant.id == variantId) return variant.price ?? product.price;
    }
    return product.price;
  }

  int get availableStock {
    for (final ProductVariant variant in product.variants) {
      if (variant.id == variantId) return variant.stock;
    }
    return product.stock;
  }

  double get total => unitPrice * quantity;
}

class Cart {
  const Cart({
    required this.items,
    required this.shippingFee,
    required this.currency,
  });

  final List<CartItem> items;
  final double shippingFee;
  final String currency;

  int get itemCount => items.fold<int>(0, (int sum, CartItem item) {
    return sum + item.quantity;
  });

  double get subtotal => items.fold<double>(0, (double sum, CartItem item) {
    return sum + item.total;
  });

  double get total => subtotal + shippingFee;
}
