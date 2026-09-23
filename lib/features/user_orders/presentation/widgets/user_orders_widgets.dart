import 'package:flutter/material.dart';
import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';
import 'package:pcj_v4/shared/widgets/app_dialog.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/user_orders_controller.dart';
import 'user_orders_styles.dart';

Future<void> showOrderDetailsDialog({
  required BuildContext context,
  required UserOrdersController controller,
  required String orderId,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => _OrderDetailsDialog(
      controller: controller,
      orderId: orderId,
    ),
  );
}

class OrdersTabs extends StatelessWidget {
  const OrdersTabs({
    super.key,
    required this.showActive,
    required this.onSelected,
  });

  final bool showActive;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.1)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _OrdersTab(
              label: 'ACTIVE',
              isSelected: showActive,
              onTap: () => onSelected(true),
            ),
          ),
          Expanded(
            child: _OrdersTab(
              label: 'PAST',
              isSelected: !showActive,
              onTap: () => onSelected(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0x66FBFCFF),
                fontSize: 18,
                height: 1.6,
                letterSpacing: 0.45,
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: AppColors.primaryBright,
                child: SizedBox(height: 2.25),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.imagePath,
    required this.orderId,
    required this.productName,
    required this.status,
    required this.createdDate,
    required this.total,
    required this.accentColor,
    required this.onTap,
  });

  final String imagePath;
  final String orderId;
  final String productName;
  final String status;
  final String createdDate;
  final String total;
  final Color accentColor;
  final VoidCallback onTap;

  static const BorderRadius _cardRadius = BorderRadius.only(
    topRight: Radius.circular(AppRadii.large),
    bottomRight: Radius.circular(AppRadii.large),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: _cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
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
            border: Border.all(color: AppColors.inputBorder, width: 1.1),
            borderRadius: _cardRadius,
          ),
          child: Stack(
            children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ColoredBox(
              color: accentColor,
              child: const SizedBox(width: 4.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 2.34,
                  child: ColoredBox(
                    color: AppColors.panel,
                    child: AppAssetImage(
                      path: imagePath,
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                      fallbackIcon: Icons.checkroom,
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(orderId, style: OrderStyles.orderId),
                          const SizedBox(height: 4),
                          Text(productName, style: OrderStyles.productName),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(label: status),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(
                  height: 1,
                  thickness: 1.1,
                  color: AppColors.border,
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _OrderValue(
                        label: 'Placed',
                        value: createdDate,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _OrderValue(
                        label: 'Total',
                        value: total,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
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
        border: Border.all(color: AppColors.cardBorder, width: 1.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 4.5),
        child: Text(label, style: OrderStyles.badge),
      ),
    );
  }
}

class _OrderValue extends StatelessWidget {
  const _OrderValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment crossAxisAlignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final TextAlign textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        Text(label, textAlign: textAlign, style: OrderStyles.metaLabel),
        const SizedBox(height: 4.5),
        Text(value, textAlign: textAlign, style: OrderStyles.metaValue),
      ],
    );
  }
}

class _OrderDetailsDialog extends StatefulWidget {
  const _OrderDetailsDialog({
    required this.controller,
    required this.orderId,
  });

  final UserOrdersController controller;
  final String orderId;

  @override
  State<_OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<_OrderDetailsDialog> {
  Order? _order;
  Object? _error;
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final Order order = await widget.controller.getOrderDetails(
        widget.orderId,
      );
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    final Order? order = _order;
    if (order == null || !order.canCancel || _isCancelling) return;
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Cancel Order?',
      message:
          'Order #${order.id} is pending and will be cancelled immediately.',
      confirmLabel: 'Cancel Order',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isCancelling = true;
      _error = null;
    });
    try {
      final OrderCancellationResult result = await widget.controller
          .cancelOrder(order);
      if (!mounted) return;
      await showAppMessageDialog(
        context: context,
        title: 'Order Cancelled',
        message: result.message.isEmpty
            ? 'Your order was cancelled successfully.'
            : result.message,
        buttonLabel: 'Done',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isCancelling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Order? order = _order;
    final bool canCancel = order?.canCancel ?? false;
    return AppDialog(
      icon: Icons.receipt_long_outlined,
      title: 'Order #${widget.orderId}',
      content: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : order == null
          ? _OrderDetailsError(error: _error)
          : _OrderDetailsContent(order: order, error: _error),
      primaryLabel: _isLoading
          ? 'Loading...'
          : order == null
          ? 'Retry'
          : canCancel
          ? _isCancelling
                ? 'Cancelling...'
                : 'Cancel Order'
          : 'Close',
      secondaryLabel: order != null && canCancel ? 'Close' : null,
      onPrimaryPressed: _isLoading || _isCancelling
          ? () {}
          : order == null
          ? _load
          : canCancel
          ? _cancelOrder
          : () => Navigator.of(context).pop(),
      onSecondaryPressed: order != null && canCancel
          ? () => Navigator.of(context).pop()
          : null,
    );
  }
}

class _OrderDetailsError extends StatelessWidget {
  const _OrderDetailsError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Text(
      error == null
          ? 'The order details could not be loaded.'
          : readableError(error!),
      style: AppTextStyles.body.copyWith(color: AppColors.danger),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order, required this.error});

  final Order order;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.panel,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          child: Column(
            children: <Widget>[
              _OrderDetailRow(
                label: 'Status',
                value: AppFormatters.initCap(order.status.name),
              ),
              _OrderDetailRow(
                label: 'Placed',
                value: order.createdAt.millisecondsSinceEpoch == 0
                    ? 'Not available'
                    : AppFormatters.dateAndTime(order.createdAt.toLocal()),
              ),
              _OrderDetailRow(
                label: 'Delivery',
                value: AppFormatters.initCap(order.deliveryMethod),
              ),
              _OrderDetailRow(
                label: 'Payment',
                value: AppFormatters.initCap(order.paymentMethod),
              ),
              _OrderDetailRow(
                label: 'Payment Status',
                value: AppFormatters.initCap(order.paymentStatus),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('ITEMS', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        if (order.items.isEmpty)
          Text(
            'No item details were returned for this order.',
            style: AppTextStyles.body.copyWith(color: AppColors.textFaint),
          )
        else
          for (final CartItem item in order.items) ...<Widget>[
            _OrderItemRow(item: item),
            const SizedBox(height: AppSpacing.sm),
          ],
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        _OrderTotalRow(
          label: 'Delivery Fee',
          value: AppFormatters.money(order.deliveryFee, order.currency),
        ),
        const SizedBox(height: AppSpacing.sm),
        _OrderTotalRow(
          label: 'Total',
          value: AppFormatters.money(order.total, order.currency),
          emphasized: true,
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text(
            readableError(error!),
            style: AppTextStyles.body.copyWith(color: AppColors.danger),
          ),
        ],
        if (order.canCancel) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text(
            'This pending cash order is eligible for cancellation.',
            style: AppTextStyles.body.copyWith(color: AppColors.textFaint),
          ),
        ],
      ],
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(label, style: AppTextStyles.body)),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  value.isEmpty ? 'Not available' : value,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final List<String> details = <String>[
      if (item.selectedColor?.name.trim().isNotEmpty == true)
        AppFormatters.initCap(item.selectedColor!.name),
      if (item.selectedSize?.trim().isNotEmpty == true) item.selectedSize!,
      'Qty ${item.quantity}',
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 68,
            height: 68,
            child: AppAssetImage(
              path: item.product.primaryImageUrl ?? '',
              borderRadius: BorderRadius.circular(AppRadii.small),
              fallbackIcon: Icons.shopping_bag_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.product.name, style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details.join(' · '),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textFaint,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppFormatters.money(item.total, item.product.currency),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
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

class _OrderTotalRow extends StatelessWidget {
  const _OrderTotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = emphasized
        ? AppTextStyles.sectionTitle
        : AppTextStyles.body;
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
