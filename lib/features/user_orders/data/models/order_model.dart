import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/features/shop/data/models/cart_model.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.items,
    required super.status,
    required super.createdAt,
    required super.total,
    required super.currency,
    super.estimatedDelivery,
  });

  factory OrderModel.fromJson(Map<String, dynamic> source) {
    final Object? nested = source['order'];
    final Map<String, dynamic> json = nested is Map
        ? Map<String, dynamic>.from(nested)
        : source;
    final Object? rawItems = json['items'] ?? json['order_items'];
    final List<CartItem> items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map<CartItem>((Map item) {
                return CartItemModel.fromJson(Map<String, dynamic>.from(item));
              })
              .toList(growable: false)
        : const <CartItem>[];

    return OrderModel(
      id:
          firstString(json, const <String>['id', 'order_id', 'order_number']) ??
          '',
      items: items,
      status: _status(json['status']),
      createdAt:
          firstDateTime(json, const <String>['created_at', 'ordered_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      estimatedDelivery: firstDateTime(json, const <String>[
        'estimated_delivery',
        'delivery_date',
      ]),
      total:
          firstDouble(json, const <String>[
            'total',
            'total_amount',
            'amount',
          ]) ??
          items.fold<double>(
            0,
            (double total, CartItem item) => total + item.total,
          ),
      currency: firstString(json, const <String>['currency']) ?? 'JOD',
    );
  }

  static OrderStatus _status(Object? value) {
    final String normalized = value?.toString().toLowerCase() ?? '';
    if (normalized.contains('ship')) return OrderStatus.shipped;
    if (normalized.contains('deliver') || normalized.contains('complete')) {
      return OrderStatus.delivered;
    }
    if (normalized.contains('cancel')) return OrderStatus.cancelled;
    return OrderStatus.processing;
  }
}
