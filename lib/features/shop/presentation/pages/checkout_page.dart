import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';
import 'package:pcj_v4/shared/widgets/app_dialog.dart';
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
    final String? address = await showAppTextInputDialog(
      context: context,
      title: 'Delivery Address',
      currentValue: controller.deliveryAddress ?? '',
      confirmLabel: 'Use Address',
      hintText: 'Enter address',
      keyboardType: TextInputType.streetAddress,
    );
    if (address != null) controller.setDeliveryAddress(address);
  }

  Future<void> _placeOrder(BuildContext context) async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Place Order?',
      message: 'Please confirm that you want to place this order.',
      confirmLabel: 'Place Order',
      icon: Icons.shopping_bag_outlined,
    );
    if (!confirmed || !context.mounted) return;
    final Order? order = await controller.placeOrder();
    if (order == null || !context.mounted) return;
    await showAppMessageDialog(
      context: context,
      title: 'Order Placed',
      message: order.message?.trim().isNotEmpty == true
          ? order.message!
          : 'Your order #${order.id} was placed successfully.',
      buttonLabel: 'View Orders',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
    );
    if (context.mounted) onOrderPlaced(order);
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
            onRefresh: () => controller.load(force: true),
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
                        onRemove: () =>
                            controller.removeItem(cart.items[index]),
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
                    const SizedBox(height: 54),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(text: 'Payment Method'),
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
                    PaymentMethodPanel(
                      selectedMethod: controller.paymentMethod,
                      onSelected: controller.selectPaymentMethod,
                    ),
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
                      onPlaceOrder: () => _placeOrder(context),
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
