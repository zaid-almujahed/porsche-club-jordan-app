import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/checkout_controller.dart';
import '../widgets/checkout_page_widgets.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    super.key,
    required this.controller,
    required this.onOrderPlaced,
  });

  final CheckoutController controller;
  final ValueChanged<Order> onOrderPlaced;

  Future<void> _chooseAddress(BuildContext context) async {
    final TextEditingController fieldController = TextEditingController(
      text: controller.deliveryAddress,
    );
    final String? address = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delivery address'),
          content: TextField(
            controller: fieldController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter address'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(fieldController.text.trim()),
              child: const Text('Use Address'),
            ),
          ],
        );
      },
    );
    fieldController.dispose();
    if (address != null) controller.setDeliveryAddress(address);
  }

  Future<void> _placeOrder() async {
    final Order? order = await controller.placeOrder();
    if (order != null) onOrderPlaced(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Checkout', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: 36,
            child: AsyncStateView<Cart>(
              state: controller.cart,
              onRetry: () => controller.load(force: true),
              isEmpty: (Cart cart) => cart.items.isEmpty,
              emptyMessage: 'Your cart is empty.',
              builder: (BuildContext context, Cart cart) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (
                      int index = 0;
                      index < cart.items.length;
                      index++
                    ) ...<Widget>[
                      CheckoutItemCard(
                        item: cart.items[index],
                        onIncrement: () => controller.changeQuantity(
                          cart.items[index],
                          cart.items[index].quantity + 1,
                        ),
                        onDecrement: () => controller.changeQuantity(
                          cart.items[index],
                          cart.items[index].quantity - 1,
                        ),
                        onRemove: () =>
                            controller.removeItem(cart.items[index].id),
                      ),
                      if (index != cart.items.length - 1)
                        const SizedBox(height: 27),
                    ],
                    const SizedBox(height: 72),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(text: 'Delivery Method'),
                          TextSpan(
                            text: ' *',
                            style: AppTextStyles.pageTitle.copyWith(
                              color: AppColors.required,
                            ),
                          ),
                        ],
                      ),
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    DeliveryMethodPanel(
                      selectedMethod: controller.deliveryMethod,
                      deliveryAddress: controller.deliveryAddress,
                      onSelected: controller.selectDeliveryMethod,
                      onAddressPressed: () => _chooseAddress(context),
                    ),
                    if (controller.deliveryMethod ==
                        DeliveryMethod.delivery) ...<Widget>[
                      const SizedBox(height: AppSpacing.xl),
                      const DeliveryInformationPanel(),
                    ],
                    if (controller.orderError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.orderError!),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 54),
                    OrderSummary(
                      cart: cart,
                      isPlacingOrder:
                          controller.isPlacingOrder ||
                          controller.cart.isLoading,
                      onPlaceOrder: _placeOrder,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
