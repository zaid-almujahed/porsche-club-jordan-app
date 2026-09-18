import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';

import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.cart,
    required this.isPlacingOrder,
    this.onPlaceOrder,
  });

  final Cart cart;
  final bool isPlacingOrder;
  final VoidCallback? onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: checkoutPanelDecoration(radius: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Order Summary',
            style: AppTextStyles.pageTitle.copyWith(
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF2C2C2C)),
          const SizedBox(height: 27),
          _OrderRow(
            label: 'Subtotal (${cart.itemCount} items)',
            value: AppFormatters.money(cart.subtotal, cart.currency),
          ),
          const SizedBox(height: 27),
          _OrderRow(
            label: 'Shipping',
            value: cart.shippingFee == 0
                ? 'Complimentary'
                : AppFormatters.money(cart.shippingFee, cart.currency),
          ),
          const SizedBox(height: 27),
          const Divider(color: Color(0xFF2C2C2C)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'Total',
                style: AppTextStyles.pageTitle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppFormatters.money(cart.total, cart.currency),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 31,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'INCL. TAXES',
                style: AppTextStyles.label.copyWith(
                  color: const Color(0xFFC8C6C5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          PrimaryActionButton(
            label: isPlacingOrder ? 'Placing Order...' : 'Place Order',
            onPressed: isPlacingOrder ? null : onPlaceOrder,
            height: 58,
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

BoxDecoration checkoutPanelDecoration({
  required double radius,
  Color borderColor = const Color(0x33FBFCFF),
}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0x331A1A1A),
        Color(0xCC000000),
        Color(0x8C000000),
        Color(0x191A1A1A),
      ],
    ),
    border: Border.all(color: borderColor, width: 1.13),
    borderRadius: BorderRadius.circular(radius),
  );
}

class CheckoutItemCard extends StatelessWidget {
  const CheckoutItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(27),
      decoration: checkoutPanelDecoration(
        radius: 25,
        borderColor: const Color(0xFF2C2C2C),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2.33,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border.all(color: const Color(0xFF2C2C2C), width: 1.13),
                borderRadius: BorderRadius.circular(24),
              ),
              child: AppAssetImage(
                path: item.product.primaryImageUrl ?? '',
                fallbackIcon: Icons.shopping_bag_outlined,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  item.product.name,
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.product.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 27),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children:
                <String>[
                  if (item.selectedSize != null) 'SIZE: ${item.selectedSize}',
                  if (item.selectedColor != null)
                    'COLOR: ${item.selectedColor!.name.toUpperCase()}',
                ].map((String tag) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4.5,
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: 1.35,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              _InlineQuantity(
                value: item.quantity,
                onIncrement: item.quantity < item.availableStock
                    ? onIncrement
                    : null,
                onDecrement: onDecrement,
              ),
              const SizedBox(width: 27),
              Text(
                AppFormatters.money(item.total, item.product.currency),
                style: AppTextStyles.pageTitle.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineQuantity extends StatelessWidget {
  const _InlineQuantity({
    required this.value,
    this.onIncrement,
    required this.onDecrement,
  });

  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ColoredBox(
            color: Color(0x00000000),
            child: IconButton(
              onPressed: value <= 1 ? null : onDecrement,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30),
              icon: const Icon(Icons.remove, size: 15),
            ),
          ),
          SizedBox(
            width: 36,
            child: ColoredBox(
              color: AppColors.canvas,
              child: Center(child: Text('$value', style: AppTextStyles.label)),
            ),
          ),
          ColoredBox(
            color: Color(0x00000000),
            child: IconButton(
              onPressed: onIncrement,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30),
              icon: const Icon(Icons.add, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryMethodPanel extends StatelessWidget {
  const DeliveryMethodPanel({
    super.key,
    required this.selectedMethod,
    required this.onSelected,
    this.deliveryAddress,
    this.onAddressPressed,
  });

  final DeliveryMethod selectedMethod;
  final ValueChanged<DeliveryMethod> onSelected;
  final String? deliveryAddress;
  final VoidCallback? onAddressPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: checkoutPanelDecoration(radius: 12),
      child: Column(
        children: <Widget>[
          _DeliveryChoice(
            icon: Icons.storefront_outlined,
            label: 'PICK UP',
            selected: selectedMethod == DeliveryMethod.pickup,
            showBorder: true,
            onTap: () => onSelected(DeliveryMethod.pickup),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181817),
              border: Border.all(color: const Color(0x33FBFCFF), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: <Widget>[
                _DeliveryChoice(
                  icon: Icons.local_shipping_outlined,
                  label: 'DELIVERY',
                  selected: selectedMethod == DeliveryMethod.delivery,
                  onTap: () => onSelected(DeliveryMethod.delivery),
                ),
                const Divider(color: Color(0x7FC8C6C5)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 18, 15, 16),
                  child: Column(
                    children: <Widget>[
                      _DeliveryDetail(
                        label: 'DESTINATION',
                        value: deliveryAddress?.isNotEmpty == true
                            ? deliveryAddress!.toUpperCase()
                            : 'SELECT ADDRESS',
                        valueIcon: Icons.edit_outlined,
                        onPressed: onAddressPressed,
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice({
    required this.icon,
    required this.label,
    this.selected = false,
    this.showBorder = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool showBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 25,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.primary : AppColors.cardBorder,
            ),
          ],
        ),
      ),
    );

    final Widget interactive = InkWell(onTap: onTap, child: content);

    if (!showBorder) return interactive;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181817),
        border: Border.all(color: const Color(0x33FBFCFF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: interactive,
    );
  }
}

class _DeliveryDetail extends StatelessWidget {
  const _DeliveryDetail({
    required this.label,
    required this.value,
    this.valueIcon,
    this.onPressed,
  });

  final String label;
  final String value;
  final IconData? valueIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
            ),
          ),
          const Spacer(),
          if (valueIcon != null) ...<Widget>[
            Icon(valueIcon, size: 16, color: AppColors.textFaint),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textFaint,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryInformationPanel extends StatelessWidget {
  const DeliveryInformationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      decoration: checkoutPanelDecoration(
        radius: 9,
        borderColor: const Color(0xFF2C2C2C),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.local_shipping,
                size: 25,
                color: AppColors.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Club Delivery Service',
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: 27,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Items will be delivered directly by the club logistics team '
            'to your registered address. You will receive notifications '
            'once your order is on its way. Ensure your profile details '
            'are up to date.',
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}
