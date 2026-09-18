import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/user_orders_controller.dart';
import '../widgets/user_orders_widgets.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key, required this.controller});

  final UserOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'My Orders', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                OrdersTabs(
                  showActive: controller.showActive,
                  onSelected: (bool active) {
                    controller.showTab(active: active);
                  },
                ),
                const SizedBox(height: 36),
                AsyncStateView<List<Order>>(
                  state: controller.orders,
                  onRetry: () => controller.load(force: true),
                  isEmpty: (List<Order> orders) => orders.isEmpty,
                  emptyMessage: 'No orders are available.',
                  builder: (BuildContext context, List<Order> orders) {
                    return Column(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < orders.length;
                          index++
                        ) ...<Widget>[
                          _OrderCardFromEntity(order: orders[index]),
                          if (index != orders.length - 1)
                            const SizedBox(height: 27),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCardFromEntity extends StatelessWidget {
  const _OrderCardFromEntity({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final CartItem? firstItem = order.items.isEmpty ? null : order.items.first;
    final String productName = order.items.length == 1
        ? firstItem!.product.name
        : '${order.items.length} products';
    final String deliveryDate = order.estimatedDelivery == null
        ? 'To be confirmed'
        : AppFormatters.date(order.estimatedDelivery!);

    return OrderCard(
      imagePath: firstItem?.product.primaryImageUrl ?? '',
      orderId: '#${order.id}',
      productName: productName,
      status: order.status.name.toUpperCase(),
      deliveryDate: deliveryDate,
      total: AppFormatters.money(order.total, order.currency),
      accentColor: order.status == OrderStatus.processing
          ? AppColors.primaryBright
          : AppColors.inputBorder,
    );
  }
}
