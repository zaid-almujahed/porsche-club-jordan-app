import 'cart.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled, unknown }

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.currency,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.deliveryFee,
    this.message,
  });

  final String id;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;
  final String currency;
  final String paymentStatus;
  final String paymentMethod;
  final String deliveryMethod;
  final double deliveryFee;
  final String? message;

  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.processing ||
      status == OrderStatus.shipped;

  bool get canCancel =>
      status == OrderStatus.pending &&
      paymentMethod.trim().toUpperCase() == 'CASH';
}

class OrderCancellationResult {
  const OrderCancellationResult({
    required this.message,
    required this.orderId,
    required this.status,
  });

  final String message;
  final String orderId;
  final OrderStatus status;
}
