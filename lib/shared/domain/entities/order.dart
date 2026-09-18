import 'cart.dart';

enum OrderStatus { processing, shipped, delivered, cancelled }

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.currency,
    this.estimatedDelivery,
  });

  final String id;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final double total;
  final String currency;

  bool get isActive =>
      status == OrderStatus.processing || status == OrderStatus.shipped;
}
