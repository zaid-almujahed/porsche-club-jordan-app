import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/features/user_orders/domain/repositories/user_orders_repository.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';

import '../models/order_model.dart';

class ApiUserOrdersRepository implements UserOrdersRepository {
  ApiUserOrdersRepository({required PcjApiClient apiClient})
    : _apiClient = apiClient;

  final PcjApiClient _apiClient;

  @override
  Future<List<Order>> getOrders({required bool active}) async {
    Object? value = unwrapApiData(await _apiClient.get('/member/orders'));
    if (value is Map && value['orders'] is List) value = value['orders'];
    if (value is! List) {
      throw const AppException(
        'The server returned an invalid orders response.',
      );
    }
    final List<Order> orders = value
        .whereType<Map>()
        .map<Order>((Map item) {
          return OrderModel.fromJson(Map<String, dynamic>.from(item));
        })
        .where((Order order) => order.isActive == active)
        .toList(growable: false);
    orders.sort((Order a, Order b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<Order> getOrder(String orderId) async {
    return OrderModel.fromJson(
      requireJsonMap(
        await _apiClient.get('/member/orders/${Uri.encodeComponent(orderId)}'),
        description: 'order response',
      ),
    );
  }
}
